//
//  UserHomeViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/08.
//

import Foundation
import Firebase
import GoogleSignIn
import SwiftUI
import KakaoSDKUser
import NaverThirdPartyLogin

//MARK: MODEL
struct UserBaseModel{
    var userid:String?
    var name:String?
    var email:String?
    var age:String?
    var fitnessCode:String?
    var gender:String?
    var trainer:String?
    var imageUrl:String?
}

//MARK: VIEWMODEL
class UserBaseViewModel:ObservableObject{
    @Published var userBaseModel = UserBaseModel()
    @Environment(\.presentationMode) var presentaionMode
    let reference = FirebaseDatabase.Database.database().reference()
    var rawValue:Int = UserDefaults.standard.integer(forKey: "LoginApi")
    var loginApi:LoginType
    
    init(){
        self.loginApi = LoginType(rawValue: rawValue) ?? .none
        
        self.registerToken {
            self.fetchData {
                print(self.userBaseModel)
            }
        }
        
    }
    
    var userid:String {
        guard let userid = self.userBaseModel.userid else{return ""}
        return userid
    }
    
    var trainerid:String{
        guard let trainerid = self.userBaseModel.trainer else{return ""}
        return trainerid
    }
    
    var fitnessCode:String{
        guard let fitnessCode = self.userBaseModel.fitnessCode else{return ""}
        return fitnessCode
    }
    
    var username:String{
        guard let username = self.userBaseModel.name else{return ""}
        return username
    }
    
    var imageUrl:String{
        guard let url = self.userBaseModel.imageUrl else{return ""}
        return url
    }
    
    //FCM 토큰 저장 메소드
    func registerToken(completion:@escaping()->Void){
        guard let token = FirebaseMessaging.Messaging.messaging().fcmToken,
              let userid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        reference
            .child("tokens")
            .child(userid)
            .setValue(token) { error, snapshot in
                if error == nil{
                    completion()
                }
            }
    }
    
    //데이터 불러오기 메소드
    func fetchData(completion:@escaping()->Void){
        guard let UID = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        reference
            .child("User")
            .child(UID)
            .observeSingleEvent(of: .value) { snapshot in
                
                guard let values = snapshot.value as? [String:Any] else{return}
                
                self.userBaseModel.age = values["age"] as? String
                self.userBaseModel.email = values["email"] as? String
                self.userBaseModel.gender = values["gender"] as? String
                self.userBaseModel.name = values["name"] as? String
                self.userBaseModel.trainer = values["trainer"] as? String
                self.userBaseModel.fitnessCode = values["fitnessCode"] as? String
                self.userBaseModel.userid = values["uid"] as? String
                self.userBaseModel.imageUrl = values["photoUri"] as? String
                completion()
            }
    }
    
    func reloadImage(){
        guard let userid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        reference
            .child("User")
            .child(userid)
            .child("photoUri")
            .observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? String else{return}
                self.userBaseModel.imageUrl = value
                
            }
    }
    
    
    //TODO: 로그 아웃 메소드
    func logout(completion:@escaping()->Void){
        switch loginApi {
        case .kakao:
            UserApi.shared.logout { error in
                if let error = error {
                    print("Error : \(error)")
                }else{
                    do{
                        try FirebaseAuth.Auth.auth().signOut()
                        UserDefaults.standard.set(LoginType.none.rawValue, forKey: "LoginApi")
                        completion()
                    }catch{
                        print("Log Out Fail in Kakao")
                    }
                    
                }
            }
            
        case .naver:
            do{
                NaverThirdPartyLoginConnection.getSharedInstance().requestDeleteToken()
                
                UserDefaults.standard.set(LoginType.none.rawValue, forKey: "LoginApi")
                try FirebaseAuth.Auth.auth().signOut()
                
                completion()
            }catch{
                print("Error in LogOut")
            }
            
        case .google:
            do{
                UserDefaults.standard.set(LoginType.none.rawValue, forKey: "LoginApi")
                try FirebaseAuth.Auth.auth().signOut()
                GIDSignIn.sharedInstance.signOut()
                
                completion()
            }catch{
                print("Error in LogOut")
            }

        case .apple:
            do{
                UserDefaults.standard.set(LoginType.none.rawValue, forKey: "LoginApi")
                try FirebaseAuth.Auth.auth().signOut()
                
                completion()
            }catch{
                print("Error in LogOut")
            }
            
        case .none:
            do{
                try FirebaseAuth.Auth.auth().signOut()
                UserDefaults.standard.set(LoginType.none.rawValue, forKey: "LoginApi")
                completion()
            }
            catch{
                print("Error in Logout")
            }
            
        }
    }
}
