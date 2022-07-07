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
import Firebase
import FirebaseDatabase
//import NaverThirdPartyLogin
import Alamofire
import GoogleSignIn
import KakaoSDKUser
import CryptoKit
import SwiftUI
import AuthenticationServices

enum signInState:Identifiable{
    var id : Self {self}
    case signedIn
    case signedOut
}

class AuthService:NSObject,ObservableObject{
    fileprivate var currentNonce:String?
    @Published var user = FirebaseAuth.Auth.auth().currentUser
    @Published var usertype:userType?
    @Published var State:signInState = .signedOut
    @Published var isNewUser:Bool = false
    @Published var authType:String?
    
    override init(){
        super.init()
        self.ChangeState()
    }
    
    func ChangeState(){
        if FirebaseAuth.Auth.auth().currentUser == nil{
            self.State = .signedOut
        }else{
            self.State = .signedIn
            
            guard let userId = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
            
            FirebaseDatabase.Database.database().reference()
                .observeSingleEvent(of: .value) { snapshot in
                    if snapshot.childSnapshot(forPath: "Trainer").childSnapshot(forPath: userId).exists(){
                        self.usertype = .trainer
                        
                        self.registerToken(userId: userId)
                    }else if snapshot.childSnapshot(forPath: "User").childSnapshot(forPath: userId).exists(){
                        self.usertype = .user
                        self.registerToken(userId: userId)
                    }else{
                        self.State = .signedOut
                        self.isNewUser = true
                    }
                }
        }
    }
    
    func registerToken(userId:String){
        Messaging.messaging().token { [weak self] token, err in
            guard err == nil else{return}
            
            if let token = token{
                FirebaseDatabase.Database.database().reference()
                    .child("tokens")
                    .updateChildValues([userId:token])
            }
        }
    }
    
    func userId()->String{
        guard let userid = user?.uid else{return ""}
        return userid
    }
    
    func getuserEmail()->String{
        guard let userEmail = user?.email else{return ""}
        return userEmail
    }
    
    func getauthType()->String{
        guard let authType = authType else {
            return ""
        }
        
        return authType
    }
    
    func userName()->String{
        guard let userName = user?.displayName else{return ""}
        return userName
    }
    
    func customTokenLogIn(_ customToken:String){
        FirebaseAuth.Auth.auth().signIn(withCustomToken: customToken) { result, error in
            print("Error in custom token Login \(error.debugDescription)")
            
            if error == nil{
                guard let isNewUser = result?.additionalUserInfo?.isNewUser,
                      isNewUser == true else{
                    //is not new user
                    self.user = FirebaseAuth.Auth.auth().currentUser
                    self.ChangeState()
                    return
                }
                
                self.user = FirebaseAuth.Auth.auth().currentUser
                self.isNewUser = isNewUser
                self.ChangeState()
            }
        }
    }
    
    
    func LogOut(){
        do{
            try FirebaseAuth.Auth.auth().signOut()
            self.user = FirebaseAuth.Auth.auth().currentUser
            self.ChangeState()
        } catch {
            print("Error in Firebase auth LogOut")
        }
    }
}

//MARK: - KAKAO
extension AuthService{
    
    func validationKakaoToke(){
        self.authType = "Kakao"
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
        self.authType = "Apple"
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
        self.authType = "Google"
        if GIDSignIn.sharedInstance.hasPreviousSignIn(){
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                self.googleFirebaseLogin(for: user, with: error)
            }
        }else{
            guard let clientId = FirebaseOptions.defaultOptions()?.clientID else{return}
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
                guard let isNewUser = result?.additionalUserInfo?.isNewUser,
                      isNewUser == true else {
                    self.user = result?.user
                    self.ChangeState()
                    return
                }
                self.user = result?.user
                self.isNewUser = isNewUser
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
        switch authorization.credential{
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            if let _ = appleIdCredential.email,
               let _ = appleIdCredential.fullName{
                registerNewAccount(credential: appleIdCredential)
            } else{
                signInWithExistingAccount(credential: appleIdCredential)
            }
            
            break
        default:
            break
        }
    }
    
    private func firebaseLogin(credential:ASAuthorizationAppleIDCredential){
        guard let nonce = currentNonce else{
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        
        guard let idToken = credential.identityToken else{
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
                print(result?.user.uid)
                
                guard let isNewUser = result?.additionalUserInfo?.isNewUser,
                      isNewUser == true else{
                    self.user = result?.user
                    self.ChangeState()
                    return
                }
                
                self.user = result?.user
                self.isNewUser = isNewUser
            }
        }
    }
    
    private func registerNewAccount(credential:ASAuthorizationAppleIDCredential){
        self.isNewUser = true
        firebaseLogin(credential: credential)
    }
    
    private func signInWithExistingAccount(credential:ASAuthorizationAppleIDCredential){
        self.firebaseLogin(credential: credential)
    }
}

