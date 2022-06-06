//
//  ChattingInputViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/21.
//
import SwiftUI
import Firebase

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
    @Published var chats:[message] = []
    
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
            self.chats.append(currentData)
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
}
