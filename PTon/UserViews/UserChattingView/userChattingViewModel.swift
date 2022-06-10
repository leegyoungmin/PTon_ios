//
//  userChattingViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/06/10.
//

import Foundation
import Firebase
import FirebaseStorage

class UserChattingViewModel:ObservableObject{
    @Published var typeMessage:String = ""
    @Published var chattings:[String:[message]] = [:]
    @Published var lastMessageId = ""
    let userId:String
    let trainerId:String
    let fitnessCode:String
    let userName:String
    let trainerName:String
    let reference:DatabaseReference
    
    init(userId:String,trainerId:String,fitnessCode:String,userName:String,trainerName:String){
        self.userId = userId
        self.trainerId = trainerId
        self.fitnessCode = fitnessCode
        self.userName = userName
        self.trainerName = trainerName
        
        self.reference = Firebase.Database.database().reference().child("Chats").child(self.fitnessCode).child(trainerId).child(userId).child("chats")
        
        observeChatting()
    }
    
    func observeChatting(){
        reference.observe(.childAdded) {[weak self] snapshot in
            print("user Chatting ViewModel update child ::: \(snapshot)")
            guard let self = self,
                  let values = snapshot.value as? [String:Any] else{return}

            let chatId = snapshot.key
            let date = values["date"] as? String ?? ""
            let content = values["message"] as? String ?? ""
            let read = values["read"] as? Bool ?? false
            let sender = values["sender"] as? String ?? ""
            let time = values["time"] as? String ?? ""

            if self.trainerId != sender{
//                self.isUpdate = true
            }

            let currentData = message(chatId: chatId, content: content, time: time, date: date, isRead: read, isCurrentUser: sender == self.userId ? true:false)

            if self.chattings[date] == nil{
                self.chattings[date] = [currentData]
            }else{
                self.chattings[date]!.append(currentData)
            }

            self.lastMessageId = chatId
        }
    }
    
    
    func uploadChats(onError:@escaping()->Void){
        let data:[String:Any] = [
            "date":convertString(content: Date(), dateFormat: "yyyy-MM-dd"),
            "message":typeMessage,
            "read":false,
            "receiver":trainerId,
            "receiverName":trainerName,
            "sender":userId,
            "senderName":trainerName,
            "time":convertString(content: Date(), dateFormat: "HH시 mm분")
        ]
        
        reference.childByAutoId().updateChildValues(data) { err, _ in
            guard err == nil else{
                onError()
                return
            }
            
            self.typeMessage = ""
        }
    }
    func uploadChats(_ message:String,onError:@escaping()->Void){
        let data:[String:Any] = [
            "date":convertString(content: Date(), dateFormat: "yyyy-MM-dd"),
            "message":message,
            "read":false,
            "receiver":trainerId,
            "receiverName":trainerName,
            "sender":userId,
            "senderName":trainerName,
            "time":convertString(content: Date(), dateFormat: "HH시 mm분")
        ]
        
        reference.childByAutoId().updateChildValues(data) { err, _ in
            guard err == nil else{
                onError()
                return
            }
            
            self.typeMessage = ""
        }
    }
    
    func uploadImage(_ imageData:Data){
        let currentDateString = convertString(content: Date(), dateFormat: "yyyy-MM-dd-hh-mm-ss").split(separator: "-").map{ String($0) }
        let imagePath = "ChatsImage_\(currentDateString.joined(separator: "_"))"
        
        let ref = FirebaseStorage.Storage.storage().reference().child("ChatsImage").child(self.fitnessCode).child(self.userId).child(trainerId).child(imagePath)
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        ref.putData(imageData,metadata: meta) { [weak self] meta, err in
            guard let self = self,let _ = meta else{return}
            
            ref.downloadURL { url, err in
                guard let downloadURL = url?.absoluteString else{
                    return
                }
                
                self.uploadChats(downloadURL) {
                    print("Error in upload image")
                }
            }
        }
    }
}
