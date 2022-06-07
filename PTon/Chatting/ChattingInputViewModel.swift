//
//  ChattingInputViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/21.
//
import SwiftUI
import Firebase
import FirebaseStorage

struct message:Hashable{
    var chatId:String
    var content:String
    var time:String
    var date:String
    var isRead:Bool
    var isCurrentUser:Bool
}

class chattingViewModel:ObservableObject{
    @Published var typingMessage:String = ""
    @Published var isUpdate:Bool = false
    @Published var chats:[String:[message]] = [:]
    @Published var lastMessageId = ""
    
    let fitnessCode:String
    let trainerId:String
    let trainerName:String
    let userId:String
    let reference:DatabaseReference
    
    init(fitnessCode:String,trainerId:String,trainerName:String,userId:String,reference:DatabaseReference){
        self.fitnessCode = fitnessCode
        self.trainerId = trainerId
        self.trainerName = trainerName
        self.userId = userId
        
        self.reference = Firebase.Database.database().reference().child("Chats").child(fitnessCode).child(self.trainerId).child(userId).child("chats")
        
        observeData()
    }
    
    var isTrainer:Bool{
        guard let currentUserId = Firebase.Auth.auth().currentUser?.uid else{return false}
        return currentUserId == trainerId
    }
    
    func observeData(){
        reference.observe(.childAdded) { [weak self] snapshot in
            print("Chatting Input View Model child added ::: \(snapshot)")
            
            guard let self = self,
                  let values = snapshot.value as? [String:Any] else{return}
            let chatId = snapshot.key
            let date = values["date"] as? String ?? ""
            let content = values["message"] as? String ?? ""
            let read = values["read"] as? Bool ?? false
            let sender = values["sender"] as? String ?? ""
            let time = values["time"] as? String ?? ""
            
            
            if self.trainerId != sender{
                self.isUpdate = true
            }
            
            
            let currentData = message(chatId: chatId, content: content, time: time, date: date, isRead: read, isCurrentUser: sender == self.trainerId ? true:false)
            
            if self.chats[date] == nil{
                self.chats[date] = [currentData]
            }else{
                self.chats[date]!.append(currentData)
            }
            
            self.lastMessageId = chatId
        }
    }
    
    func uploadchats(_ userName:String,onError:@escaping()->()){
        
        let data:[String:Any] = [
            "date":convertString(content: Date(), dateFormat: "yyyy-MM-dd"),
            "message":typingMessage,
            "read":false,
            "receiver":userId,
            "receiverName":userName,
            "sender":trainerId,
            "senderName":trainerName,
            "time":convertString(content: Date(), dateFormat: "a HH시 mm분")
        ]
        
        reference.childByAutoId().updateChildValues(data) { err, _ in
            guard err == nil else{
                onError()
                return
            }
            self.typingMessage = ""
        }
    }
    
    func uploadImageMessage(resource imageURL:String,with userName:String,onError:@escaping()->()){
        let data:[String:Any] = [
            "date":convertString(content: Date(), dateFormat: "yyyy-MM-dd"),
            "message":imageURL,
            "read":false,
            "receiver":userId,
            "receiverName":userName,
            "sender":trainerId,
            "senderName":trainerName,
            "time":convertString(content: Date(), dateFormat: "a HH시 mm분")
        ]
        reference.childByAutoId().updateChildValues(data) { err, ref in
            guard err == nil else{
                onError()
                return
            }
            
        }
    }
    
    func uploadImage(_ userName:String,imageData:Data,onError:@escaping()->Void) {
        let currentDateString = convertString(content: Date(), dateFormat: "yyyy-MM-dd-hh-mm-ss").split(separator: "-").map{ String($0) }
        let imagePath = "ChatsImage_\(currentDateString.joined(separator: "_"))"
        //        print(imagePath)
        let ref = FirebaseStorage.Storage.storage().reference().child("ChatsImage").child(self.fitnessCode).child(self.trainerId).child(self.userId).child(imagePath)
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        ref.putData(imageData,metadata: meta) { [weak self] meta, error in
            guard let self = self, let _ = meta else{
                onError()
                return
            }
            
            ref.downloadURL { url, err in
                guard let downloadURL = url?.absoluteString else{
                    onError()
                    return
                }
                
                self.uploadImageMessage(resource: downloadURL, with: userName) {
                    onError()
                }
                
            }
        }
    }
    
    func downloadUrl(){
        
    }
}
