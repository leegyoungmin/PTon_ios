//
//  LoginViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/03.
//

import Foundation
import FirebaseFunctions
import KakaoSDKAuth
import FirebaseAuth
//import NaverThirdPartyLogin
import Alamofire
import GoogleSignIn
import Firebase
import KakaoSDKUser
import CryptoKit
import SwiftUI
import AuthenticationServices

//MARK: MODEL
struct UserLoginBaseModel{
    var name:String?
    var email:String?
}


//MARK: VIEWMODEL
class LoginViewModel:NSObject, ObservableObject{
    fileprivate var currentNonce:String?
    @Published var userBaseModel = UserLoginBaseModel()
    @Published var isNewUser:Bool = false
    @Published var isNotNewUser:Bool = false
    @Published var isShowLoading:Bool = false
    let functions = Functions.functions()
//    let instance = NaverThirdPartyLoginConnection.getSharedInstance()
    @State var userType:userType?
    @Published var isTrainer:Bool?
    
    func AutoLogin(loginApi:LoginType){
        switch loginApi{
        case .kakao: self.kakaoLogin()
        case .naver: print("Login Naver Error")
        case .google: self.googleLogin()
        case .apple: self.AppleLogin()
        case .none: print("login API None")
        }
    }
    
    var name:String{
        guard let name = userBaseModel.name else{return ""}
        return name
    }
    
    var email:String{
        guard let email = userBaseModel.email else{return ""}
        return email
    }
    
    //카카오 로그인 메소드
    func kakaoLogin(){
        self.isShowLoading = true
        if UserApi.isKakaoTalkLoginAvailable(){
            UserApi.shared.loginWithKakaoTalk{(oauthToken,error) in
                if let error = error {
                    print(error)
                }
                else{
                    self.kakaoCloudFunctions(oauthToken)
                }
            }
        }
        else{
            UserApi.shared.loginWithKakaoAccount{(oauthToken,error) in
                if let error = error {
                    print(error)
                }
                else{
                    self.kakaoCloudFunctions(oauthToken)
                }
            }
        }
        
        

    }//MARK: kakao Login Functions
    
    func kakaoCloudFunctions(_ token:OAuthToken?){
        guard let token = token else {
            return
        }
        
        functions.httpsCallable("kakaoToken").call(["access_token":token.accessToken]) { (result,error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain{
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let detail = error.userInfo[FunctionsErrorDetailsKey]
                    
                    print(code!)
                    print(message)
                    print(detail!)
                }
            }
            if let data = result?.data {
                self.login(data as! String,completion: { newuser in
                    
                    UserApi.shared.me { user, error in
                        
                        if error == nil{
                            self.userBaseModel.email = user?.kakaoAccount?.email
                            self.userBaseModel.name = user?.kakaoAccount?.profile?.nickname
                            print(self.userBaseModel)
                            UserDefaults.standard.set(LoginType.kakao.rawValue, forKey: "LoginApi")
                            self.validNewUser(newuser)
                        }
                    }
                })
            }
        }
    }
    
//    //네이버 데이터 불러오기 메소드
//    func getNaverInfo(){
//        self.isShowLoading = true
//        print("Tapped Get Naver Info")
//
//        guard let isValidToken = instance?.isValidAccessTokenExpireTimeNow() else{return}
//
//        if !isValidToken{
//            print("Not Is Valid Token")
//            return
//        }
//        guard let tokenType = instance?.tokenType else{return}
//        guard let accessToken = instance?.accessToken else{return}
//        let urlStr = "https://openapi.naver.com/v1/nid/me"
//        let url = URL(string: urlStr)!
//
//        let authorization = "\(tokenType) \(accessToken)"
//
//        let request = AF.request(url,
//                                 method: .get,
//                                 parameters: nil,
//                                 encoding: JSONEncoding.default,
//                                 headers: ["Authorization": authorization])
//
//        request.responseData { response in
//            switch response.result{
//            case .success(let data):
//                do{
//                    let asJson = try JSONSerialization.jsonObject(with: data)
//
//                    guard let result = asJson as? [String:Any],
//                          let object = result["response"] as? [String:Any],
//                          let userid = object["id"] as? String,
//                          let name = object["name"] as? String,
//                          let email = object["email"] as? String else{return}
//
//                    let data:[String:String] = [
//                        "access_token":accessToken,
//                        "userid":userid,
//                        "name":name,
//                        "email":email
//                    ]
//
//                    self.userBaseModel.email = email
//                    self.userBaseModel.name = name
//
//                    print(self.userBaseModel)
//                    UserDefaults.standard.set(LoginType.naver.rawValue, forKey: "LoginApi")
//                    self.callNaverFunctions(data)
//                }catch{
//                    print(error.localizedDescription)
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }//MARK: Naver get User Info
//
//    //클라우드 함수 적용 메소드
//    func callNaverFunctions(_ data:[String:String]){
//        functions.httpsCallable("NaverToken").call(data) { result, error in
//            if error == nil{
//                guard let data = result?.data else{return}
//                self.login(data as! String) { isnewuser in
//                    self.validNewUser(isnewuser)
//                }
//            }
//        }
//    }//MARK: Naver Call Cloud Functions
    
    //구글 로그인 설정 및 파이어베이스 로그인 메소드 호출
    func googleLogin(){
        self.isShowLoading = true
        if GIDSignIn.sharedInstance.hasPreviousSignIn(){
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                self.authenticationUser(for: user, with: error) { isnewuser in
                    self.validNewUser(isnewuser)
                }
            }
        }
        else{
            guard let clientID = FirebaseApp.app()?.options.clientID else{return}
            let config = GIDConfiguration(clientID: clientID)
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return}
            guard let rootViewController = windowScene.windows.first?.rootViewController else{return}
            
            GIDSignIn.sharedInstance.signIn(with: config, presenting: rootViewController) { user, error in
                self.authenticationUser(for: user, with: error) { isnewuser in
                    self.validNewUser(isnewuser)
                }
            }
        }
    }//MARK: Google Login Function
    
    //파이어베이스 로그인 메소드(구글)
    private func authenticationUser(for user:GIDGoogleUser?,with error:Error?,completion:@escaping (Bool)->Void){
        if let error = error{
            print(error.localizedDescription)
            return
        }
        guard let authentication = user?.authentication,
              let idToken = authentication.idToken else{return}
        
        self.userBaseModel.name = user?.profile?.name
        self.userBaseModel.email = user?.profile?.email
        print(self.userBaseModel)
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
        
        
        FirebaseAuth.Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                print(error.localizedDescription)
                self.isShowLoading = false
            }else{
                self.isShowLoading = false
                if let isnewuser = result?.additionalUserInfo?.isNewUser{
                    completion(isnewuser)
                }
            }
        }
    }//MARK: Google Login With Firebase
    
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
        self.isShowLoading = true
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
        
    }//MARK: Apple Login Functions
}

extension LoginViewModel{
    
    //카카오,네이버 파이어베이스 로그인 메소드
    func login(_ customToken:String,completion:@escaping (Bool) -> Void){
                
        FirebaseAuth.Auth.auth().signIn(withCustomToken: customToken) { result, error in
            if error != nil{
                print(error?.localizedDescription ?? "")
                self.isShowLoading = false
            }
            else{
                guard let isNewUser = result?.additionalUserInfo?.isNewUser else{return}
                
                completion(isNewUser)
            }
        }
    }//MARK: Firebase Login Functions & getIsNewUser
    
    //새로운 유저 검사 메소드
    func validNewUser(_ newuser:Bool){
        if newuser == true{
            self.isNewUser = true
            self.isNotNewUser = false
        }else{
            self.isNewUser = false
            self.isNotNewUser = true
            self.getUserType()
        }
    }
    
    //유저 타입 검사 메소드
    func getUserType(){
        guard let userid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        FirebaseDatabase.Database.database().reference()
            .observe(.value) { snapshot in
                self.isShowLoading = false
                if snapshot.childSnapshot(forPath: "Trainer").hasChild(userid) {
                    self.isTrainer = true
                }
                else if snapshot.childSnapshot(forPath: "User").hasChild(userid){
                    self.isTrainer = false
                }
                else{
                    self.isTrainer = nil
                    self.isNewUser = true
                    self.isNotNewUser = false
                }
            }
    }
}

////MARK: NAVER DELEGATE
//extension LoginViewModel:UIApplicationDelegate,NaverThirdPartyLoginConnectionDelegate{
//    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
//        print("Success Login ")
//        getNaverInfo()
//    }
//    
//    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
//        print("failed Login")
//        getNaverInfo()
//    }
//    
//    func oauth20ConnectionDidFinishDeleteToken() {
//        print("logout")
//    }
//    
//    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
//        print("error in Naver Delegate \(error.localizedDescription)")
//        self.isShowLoading = false
//    }
//}

//MARK: APPLE DELEGATE
extension LoginViewModel:ASAuthorizationControllerDelegate{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
        self.isShowLoading = false
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential{
            guard let nonce = currentNonce else{
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIdToken = appleIdCredential.identityToken else{
                print("Unable to fetch Identify token")
                return
            }
            
            guard let idTokenString = String(data: appleIdToken, encoding: .utf8) else{
                print("Unable to serialize token string from data: \(appleIdToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
                        

            
            print(self.userBaseModel)
            FirebaseAuth.Auth.auth()
                .signIn(with: credential) { result, error in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                    if let data = result?.additionalUserInfo{
                        if data.isNewUser == true{
                            self.userBaseModel.email = appleIdCredential.email
                            guard let familyname = appleIdCredential.fullName?.familyName,
                                  let givenname = appleIdCredential.fullName?.givenName else{return}
                            self.userBaseModel.name = "\(familyname)\(givenname)"
                        }
                        self.validNewUser(data.isNewUser)
                    }
                }
        }
    }
}
