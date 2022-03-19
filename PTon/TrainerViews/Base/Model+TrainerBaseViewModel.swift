//
//  TrainerBaseViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/08.
//

import Foundation
import FirebaseAuth
import FirebaseMessaging
import FirebaseDatabase
import GoogleSignIn
import KakaoSDKUser
import NaverThirdPartyLogin

//MARK: MODEL
struct TrainerBaseModel{
    var name:String?
    var email:String?
    var fitnessCode:String?
    var trainee:[trainee]
}

//MARK: VIEWMODEL
class TrainerBaseViewModel:ObservableObject{
    @Published var trainerbasemodel = TrainerBaseModel(trainee: [])
    let reference = FirebaseDatabase.Database.database().reference()
    var rawValue:Int = UserDefaults.standard.integer(forKey: "LoginApi")
    var loginApi:LoginType
    
    init(){
        self.loginApi = LoginType(rawValue: rawValue) ?? .none
        
        self.registerToken {
            self.fetchData {
                print(self.trainerbasemodel)
            }
        }
    }
    
    var trainername: String{
        guard let trainername = trainerbasemodel.name else{return ""}
        return trainername
    }
    
    var fitnessCode:String{
        guard let fitnessCode = trainerbasemodel.fitnessCode else{return ""}
        return fitnessCode
    }
    

    
    //FCM 토큰 저장 메소드
    func registerToken(completion:@escaping()->Void){
        guard let token = FirebaseMessaging.Messaging.messaging().fcmToken,
              let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        reference
            .child("tokens")
            .child(trainerid)
            .setValue(token) { error, snapshot in
                if error == nil{
                    completion()
                }
            }
    }
    
    //기본 데이터 저장 메소드
    func fetchData(completion:@escaping()->Void){
        guard let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        reference
            .child("Trainer")
            .child(trainerid)
            .observeSingleEvent(of: .value) { snapshot in
                guard let values = snapshot.value as? [String:Any] else {return}
                self.trainerbasemodel.email = values["email"] as? String
                self.trainerbasemodel.name = values["name"] as? String
                self.trainerbasemodel.fitnessCode = values["fitnessCode"] as? String
                UserDefaults.standard.set(values["fitnessCode"], forKey: "fitnessCode")
                if values["trainee"] as? String != "default"{
                    let snapshot = snapshot.childSnapshot(forPath: "trainee")
                    for child in snapshot.children{
                        let values = child as? DataSnapshot
                        guard let userid = values?.key,
                              let username = values?.value as? String else{return}
                        
                        let trainee = trainee(username: username, useremail: username, userid: userid)
                        self.trainerbasemodel.trainee.append(trainee)
                        
                    }
                }else{
                    print("Trainee is Empty")
                }
                
                completion()
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
