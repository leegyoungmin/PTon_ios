//
//  UserHomeViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/08.
//

import Foundation
import Firebase
import FirebaseStorage
import GoogleSignIn
import SwiftUI
import KakaoSDKUser
import FirebaseFirestore
import FirebaseFirestoreSwift
//import NaverThirdPartyLogin

//MARK: MODEL
struct UserBaseModel{
    var userid:String?
    var name:String?
    var email:String?
    var age:String?
    var fitnessCode:String?
    var gender:String?
    var trainer:String?
    var trainerName:String?
    var imageUrl:String?
}

//MARK: VIEWMODEL
class UserBaseViewModel:ObservableObject{
    @Published var chattings:[message] = []
    @Published var userBaseModel = UserBaseModel()
    @Published var isShowBadge:Bool = false
    @Environment(\.presentationMode) var presentaionMode
    let reference = FirebaseDatabase.Database.database().reference()
    var rawValue:Int = UserDefaults.standard.integer(forKey: "LoginApi")
    var loginApi:LoginType
    
    init(){
        self.loginApi = LoginType(rawValue: rawValue) ?? .none
        
        self.registerToken {
            self.fetchData {
                self.settingtrainerName()
                self.ObserveChatting()
                self.ObserveMemo()
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
    
    var trainerName:String{
        guard let trainerName = self.userBaseModel.trainerName else{return ""}
        return trainerName
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
    
    var unreadCount:Int{
        return self.chattings.filter({$0.isRead == false && $0.isCurrentUser == false}).count
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
    
    func settingtrainerName(){
        reference
            .child("Trainer")
            .child(self.trainerid)
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.hasChild("name"){
                    let value = snapshot.childSnapshot(forPath: "name").value as? String
                    self.userBaseModel.trainerName = value
                }
            }
    }
    
    func ObserveChatting(){
        guard let userId = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        reference
            .child("Chats")
            .child(fitnessCode)
            .child(trainerid)
            .child(userId)
            .child("chat")
            .observe(.childAdded) { snapshot in
                let key = snapshot.key
                guard let values = snapshot.value as? [String:Any] else{return}
                let currentMessage = self.makeDataForm(values, trainerId: self.trainerid, chatId: key)
                self.chattings.append(currentMessage)
            }
        
        
        reference
            .child("Chats")
            .child(fitnessCode)
            .child(trainerid)
            .child(userId)
            .child("chat")
            .observe(.childChanged) { snapshot in
                let key = snapshot.key
                guard let values = snapshot.value as? [String:Any] else{return}
                let currentMessage = self.makeDataForm(values, trainerId: self.trainerid, chatId: key)
                guard let index = self.chattings.firstIndex(where: {$0.chatId == key}) else{return}
                self.chattings[index] = currentMessage
            }
    }
    
    func ObserveMemo(){
        guard let userId = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        Firestore.firestore().collection("Memo")
            .document(self.trainerid)
            .collection(userId)
            .whereField("isRead", isEqualTo: false)
            .whereField("isPrivate", isEqualTo: false)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else{return}
                if !documents.isEmpty{
                    self.isShowBadge = true
                }else{
                    self.isShowBadge = false
                }
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
    
    func uploadImage(image:UIImage,completion:@escaping(Bool)->Void){
        guard let data = image.jpegData(compressionQuality: 0.8),
              let userId = Firebase.Auth.auth().currentUser?.uid else{return}
        let path = "Profile\(convertString(content: Date(), dateFormat: "yyyyMMdd_HHmmdd"))"
        FirebaseStorage.Storage.storage().reference().child("Profile").child(path)
            .putData(data, metadata: nil) { metadata, error in
                if error == nil{
                    FirebaseStorage.Storage.storage().reference().child("Profile").child(path).downloadURL { url, error in
                        
                        guard let url = url?.absoluteString else{return}
                        self.userBaseModel.imageUrl = url
                        completion(true)
                        
                        self.reference
                            .child("User")
                            .child(userId)
                            .updateChildValues(["photoUri":url])
                    }
                }else{
                    completion(false)
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
            
        case .naver:
            print("Login Error Naver")
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
            
        }
    }
    
    private func makeDataForm(_ values:[String:Any],trainerId:String,chatId:String)->message{
        
        let currentMessage = message(chatId: chatId, content: "", time: "", date: "", data: nil, isRead: false, isCurrentUser: false)
        
        guard let receiver = values["receiver"] as? String,
              let receiverName = values["receivername"] as? String,
              let time = values["time"] as? String,
              let isRead = values["read"] as? String,
              let senderName = values["sendername"] as? String,
              let content = values["message"] as? String,
              let date = values["date"] as? String,
              let sender = values["sender"] as? String else{return currentMessage}
        
        return message(chatId: chatId, content: content, time: time, date: date, data: nil, isRead: isRead.bool, isCurrentUser: sender == userid)
    }
}
