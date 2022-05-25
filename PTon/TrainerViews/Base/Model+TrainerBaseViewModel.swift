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

//MARK: MODEL
struct TrainerBaseModel{
    var name:String?
    var email:String?
    var fitnessCode:String?
    var trainee:[trainee]
}

//MARK: VIEWMODEL
class TrainerBaseViewModel:ObservableObject{
    @Published var unreadCount:Int = 0
    @Published var trainerbasemodel = TrainerBaseModel(trainee: [])
    let reference = FirebaseDatabase.Database.database().reference()
    var rawValue:Int = UserDefaults.standard.integer(forKey: "LoginApi")
    var loginApi:LoginType
    
    init(){
        self.loginApi = LoginType(rawValue: rawValue) ?? .none
        print("Init tranerBase ViewModel")
        self.registerToken {
            self.fetchData {
                self.ObserveTrainee {
                    self.getUserProfileImage() //회원 이미지
                } //회원 구독

                self.ObserveChat() //채팅 안읽은 개수 구독
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
    
    var trainerId:String{
        
        guard let trainerId = FirebaseAuth.Auth.auth().currentUser?.uid else{return ""}
        
        return trainerId
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
                completion()
            }
        
        

    }
    
    // 트레이너 회원 목록 구독 함수
    func ObserveTrainee(completions:@escaping()->Void){
        reference
            .child("Trainer")
            .child(self.trainerId)
            .child("trainee")
            .observe(.childAdded) { snapshot in
                let userId = snapshot.key
                guard let userName = snapshot.value as? String else{return}
                
                let trainee = trainee(username: userName, useremail: userName, userid: userId)
                self.trainerbasemodel.trainee.append(trainee)
                
                completions()
            }
        
        reference
            .child("Trainer")
            .child(self.trainerId)
            .child("trainee")
            .observe(.childRemoved) { snapshot in
                let userId = snapshot.key
                self.trainerbasemodel.trainee.removeAll(where: {$0.userId == userId})
            }
    }
    
    func getUserProfileImage(){
        for (index,value) in trainerbasemodel.trainee.enumerated(){
            reference
                .child("User")
                .child(value.userId)
                .child("photoUri")
                .observeSingleEvent(of: .value) { snapshot in
                    
                    if snapshot.exists(){
                        guard let url = snapshot.value as? String else{return}
                        
                        self.trainerbasemodel.trainee[index].userProfile = url
                    }

                    
                }
        }
    }
    
    func ObserveChat(){
        
        trainerbasemodel.trainee.forEach{
            
            reference
                .child("Chats")
                .child(self.fitnessCode)
                .child(self.trainerId)
                .child($0.userId)
                .child("chat")
                .observe(.value) { snapshot in
                    self.unreadCount = 0
                    for child in snapshot.children{
                        let childSnap = child as! DataSnapshot
                        if childSnap.childSnapshot(forPath: "receiver").value as? String == self.trainerId,
                           childSnap.childSnapshot(forPath: "read").value as? String == "false"{
                            self.unreadCount += 1
                        }
                    }
                }
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
            
//        case .naver:
//            do{
//                NaverThirdPartyLoginConnection.getSharedInstance().requestDeleteToken()
//
//                UserDefaults.standard.set(LoginType.none.rawValue, forKey: "LoginApi")
//                try FirebaseAuth.Auth.auth().signOut()
//
//                completion()
//            }catch{
//                print("Error in LogOut")
//            }
            
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
        case _:
            print("Naver Login")
        }
    }
}
