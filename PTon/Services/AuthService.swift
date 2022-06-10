//
//  AuthService.swift
//  PTon
//
//  Created by 이경민 on 2022/06/09.
//

import Foundation
import FirebaseFunctions
import KakaoSDKAuth
import KakaoSDKCommon
import FirebaseAuth
//import NaverThirdPartyLogin
import Alamofire
import GoogleSignIn
import Firebase
import KakaoSDKUser
import CryptoKit
import SwiftUI
import AuthenticationServices

class AuthService:NSObject,ObservableObject{
    fileprivate var currentNonce:String?
    @Published var user:FirebaseAuth.User?
    @Published var usertype:userType?
    @Published var isNotLogged:Bool = false
    
    override init(){
        super.init()
        self.user = Firebase.Auth.auth().currentUser
        
        self.checkUserType()
    }
    
    func checkUserType(){
        if user != nil{
            self.isNotLogged = false
            userType()
        }else{
            self.isNotLogged = true
        }
    }
    
    func userType(){
        guard let userId = user?.uid else{return}
        Firebase.Database.database().reference()
            .child("Trainer")
            .child(userId)
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists(){
                    self.usertype = .trainer
                }
            }
        
        Firebase.Database.database().reference()
            .child("User")
            .child(userId)
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists(){
                    self.usertype = .user
                }
            }
    }

    
    
    
    func customTokenLogIn(_ customToken:String){
        FirebaseAuth.Auth.auth().signIn(withCustomToken: customToken) { result, error in
            print("Error in custom token Login \(error.debugDescription)")
            
            if error == nil{
                self.user = FirebaseAuth.Auth.auth().currentUser
                self.checkUserType()
            }
        }
    }
    
    
    func LogOut(){
        do{
            try FirebaseAuth.Auth.auth().signOut()
            self.user = FirebaseAuth.Auth.auth().currentUser
            self.checkUserType()
        } catch {
            print("Error in Firebase auth LogOut")
        }
    }
}

//MARK: - KAKAO
extension AuthService{
    
    func validationKakaoToke(){
        if AuthApi.hasToken(){
            UserApi.shared.accessTokenInfo { info, err in
                if let err = err {
                    if let sdkErr = err as? SdkError,
                       sdkErr.isInvalidTokenError(){
                        //Login
                    }else{
                        print("Error in kakao Token \(err.localizedDescription)")
                    }
                }else{
                    //에러 없음
                    print("Not error in kakako Token")
                    print(FirebaseAuth.Auth.auth().currentUser)
                    let token = TokenManager.manager.getToken()
                    self.kakaoCloudFunctions(token)
                    
                }
            }
        }else{
            //토큰이 없음
            self.kakoLogin()
        }
    }
    
    func kakoLogin(){
        if UserApi.isKakaoTalkLoginAvailable(){
            
            UserApi.shared.loginWithKakaoTalk { token, err in
                if let err = err {
                    print("Error in login with Kakao \(err.localizedDescription)")
                }else{
                    self.kakaoCloudFunctions(token)
                }
            }
        }else{
            UserApi.shared.loginWithKakaoAccount { token, err in
                if let err = err {
                    print("Error in login with Kakao Auth \(err.localizedDescription)")
                }else{
                    self.kakaoCloudFunctions(token)
                }
            }
        }
    }
    
    func kakaoCloudFunctions(_ token:OAuthToken?){
        guard let token = token else {
            return
        }

        Functions.functions().httpsCallable("kakaoToken").call(["access_token":token.accessToken]) { result, error in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain{
                    print("Error in Functions")
                }
            }
            
            if let data = result?.data{
                self.customTokenLogIn(data as! String)
            }
        }
    }
    
    
    //MARK: APPLE
    func randomNonceString(length:Int = 32)->String{
        precondition(length>0)
        let charset:Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0{
            let randoms:[UInt8] = (0..<16).map { _ in
                var random:UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess{
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0{
                    return
                }
                
                if random<charset.count{
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        print(result)
        return result
    }//MARK: Apple Login Random Nonce
    
    //MARK: APPLE
    func sha256(_ input:String)->String{
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }//MARK: Apple Login SHA256
    
    //애플 로그인 호출 메소드
    func AppleLogin(){
        let nonce = randomNonceString()
        self.currentNonce = nonce
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName,.email]
        request.nonce = sha256(nonce)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
        
    }//MARK: Apple Login Functions
}

//MARK: - GOOGLE
extension AuthService{
    func GoogleLogin(){
        if GIDSignIn.sharedInstance.hasPreviousSignIn(){
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                self.googleFirebaseLogin(for: user, with: error)
            }
        }else{
            guard let clientId = FirebaseApp.app()?.options.clientID else{return}
            let config = GIDConfiguration(clientID: clientId)
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return}
            guard let rootViewController = windowScene.windows.first?.rootViewController else{return}
            
            GIDSignIn.sharedInstance.signIn(with: config, presenting: rootViewController) { [unowned self] user, error in
                self.googleFirebaseLogin(for: user, with: error)
            }
        }
    }
    
    func googleFirebaseLogin(for user:GIDGoogleUser?,with error:Error?){
        if let error = error {
            print("Error in google Firebase Login \(error.localizedDescription)")
            return
        }
        
        guard let auth = user?.authentication,
              let idToken = auth.idToken else{return}
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: auth.accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                print("Error in Google Firebase Login \(error.localizedDescription)")
                
            }else{
                self.user = FirebaseAuth.Auth.auth().currentUser
                self.checkUserType()
            }
        }
    }
}
//MARK: - APPLE
extension AuthService:ASAuthorizationControllerDelegate{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error in Apple Login \(error.localizedDescription)")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential{
            guard let nonce = currentNonce else{
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let idToken = appleCredential.identityToken else{
                print("Unable to fetch Identify token")
                return
            }
            
            guard let token = String(data: idToken, encoding: .utf8) else{
                print("Unable to serialize token string from data")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: token, rawNonce: nonce)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { result, err in
                if let err = err{
                    print("Error in Apple Login Firebase \(err)")
                }else{
                    self.user = FirebaseAuth.Auth.auth().currentUser
                    self.checkUserType()
                }
            }
        }
    }
}
