//
//  ChattingViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/10.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import Firebase

//MARK: MODEL

enum MessageType:String{
    case text,image
}

struct Message:Hashable{
    var content:String
    var time:String
    var date:String
    var user:ChattingUser
    var data:Data?
}
struct ChattingUser:Hashable{
    var name:String
    var isCurrentUser:Bool = false
}

//MARK: VIEWMODEL
class ChattingViewModel:ObservableObject{
    @Published var Messages:[Message] = []
    @Published var typingMessage:String = ""
    var userid:String
    var fitnessCode:String
    var username:String
    var trainername:String
    let reference = FirebaseDatabase.Database.database().reference()
    
    
    init(_ userid:String,trainername:String,fitnessCode:String,username:String){
        self.userid = userid
        self.trainername = trainername
        self.fitnessCode = fitnessCode
        self.username = username
        self.fetchData()
    }
    
    
    func fetchData(){
        guard let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        reference
            .child("Chats")
            .child(self.fitnessCode)
            .child(trainerid)
            .child(userid)
            .child("chat")
            .observeSingleEvent(of:.value, with: { snapshot in
                self.Messages.removeAll(keepingCapacity: true)
                for child in snapshot.children{
                    let childsnap = child as! DataSnapshot
                    guard let values = childsnap.value as? [String:Any] else{return}
                    guard let message = values["message"] as? String,
                          let senderid = values["sender"] as? String,
                          let sendername = values["sendername"] as? String,
                          let time = values["time"] as? String,
                          let date = values["date"] as? String else{return}
                    
                    if trainerid == senderid{
                        let chattinguser=ChattingUser(name: sendername, isCurrentUser: true)
                        let currentMessage = Message(content: message, time: time, date: date, user: chattinguser)
                        self.Messages.append(currentMessage)
                    }else{
                        let chattinguser = ChattingUser(name: sendername, isCurrentUser: false)
                        let currentMessage = Message(content: message, time: time, date: date, user: chattinguser)
                        self.Messages.append(currentMessage)
                    }
                }
            })
    }
    
    
    func updateData(data:[String:Any]){
        guard let message = data["message"] as? String,
              let senderid = data["sender"] as? String,
              let sendername = data["sendername"] as? String,
              let time = data["time"] as? String,
              let date = data["date"] as? String else{return}
        
        let chattingUser = ChattingUser(name: sendername, isCurrentUser: true)
        let currentMessage = Message(content: message, time: time, date: date, user: chattingUser)
        self.Messages.append(currentMessage)
    }
    
    func updateSelf(_ message:String?){
        
        if message != nil{
            let currentMessage = Message(content: message!, time: getStringTime(), date: getStringTime(),
                                         user: ChattingUser(name: trainername, isCurrentUser: true), data: nil)
            
            self.Messages.append(currentMessage)
        }else{
            if self.typingMessage != ""{
                let currentMessage = Message(content: typingMessage, time: getStringTime(), date: getStringTime(),
                                             user: ChattingUser(name: trainername, isCurrentUser: true), data: nil)
                
                self.Messages.append(currentMessage)
            }
        }
    }
    
    
    func send(){
        guard let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        validationChatList(trainerid:trainerid) { isNewRoom in
            if isNewRoom == true{
                
                let value = [
                    "uid":self.userid
                ]
                
                self.reference
                    .child("ChatList")
                    .child(self.fitnessCode)
                    .child(trainerid)
                    .child(self.userid)
                    .setValue(value)
            }
        }
        
        if self.typingMessage != ""{
            let values = [
                "date":getStringDate(),
                "message":typingMessage,
                "read":"false",
                "sender":trainerid,
                "sendername":trainername,
                "receiver":userid,
                "receivername":username,
                "time":getStringTime()
            ]
            
            
            typingMessage = ""
            print("User Name in send \(trainername)")
            reference
                .child("Chats")
                .child(fitnessCode)
                .child(trainerid)
                .child(userid)
                .child("chat")
                .childByAutoId()
                .setValue(values) { error, reference in
                    if error == nil{
                    }
                }
        }
    }
    

    
    
    func imageAppend(image:Data){
        let message = Message(content: "ChatsImage", time: getStringTime(), date: getStringDate(), user: ChattingUser(name: trainername, isCurrentUser: true), data: image)
        self.Messages.append(message)
    }
    
    
    func uploadImage(_ image:Data,completion:@escaping(String)->Void){
        let storage = Storage.storage().reference()
        
        let path = "ChatsImage_\(userid)_\(getStringDate())_\(getStringTime()).jpg"
        
        storage.child("ChatsImage").child(path)
            .putData(image, metadata: nil) { _, error in
                if error != nil{
                    completion("")
                    
                    return
                }else{
                    completion(path)
                }
            }
    }
    
    func sendImage(path:String){
        guard let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        validationChatList(trainerid:trainerid) { isNewRoom in
            if isNewRoom == true{
                
                let value = [
                    "uid":self.userid
                ]
                
                self.reference
                    .child("ChatList")
                    .child(self.fitnessCode)
                    .child(trainerid)
                    .child(self.userid)
                    .setValue(value)
            }
        }
        
        let values = [
            "date":self.getStringDate(),
            "message":path,
            "read":"false",
            "sender":trainerid,
            "sendername":self.trainername,
            "receiver":self.userid,
            "receivername":self.username,
            "time":self.getStringTime()
        ] as [String : Any]
        
        self.reference
            .child("Chats")
            .child(self.fitnessCode)
            .child(trainerid)
            .child(self.userid)
            .child("chat")
            .childByAutoId()
            .setValue(values) { error, reference in
                if error == nil{
                }
            }
    }
    
    func sendReservation(_ date:Date){
        guard let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        validationChatList(trainerid:trainerid) { isNewRoom in
            if isNewRoom == true{
                
                let value = [
                    "uid":self.userid
                ]
                
                self.reference
                    .child("ChatList")
                    .child(self.fitnessCode)
                    .child(trainerid)
                    .child(self.userid)
                    .setValue(value)
            }
        }
        
        if let dateString = convertString(content: date, dateFormat: "MM월 dd일") as? String,
           let timeString = convertString(content: date, dateFormat: "HH시 mm분") as? String{
            let typingMessage = "\(trainername) 트레이너님이 " + dateString + " " + timeString + "에 PT 일정을 예약하셨습니다."
            let values = [
                "date":getStringDate(),
                "message":typingMessage,
                "read":"false",
                "sender":trainerid,
                "sendername":trainername,
                "receiver":userid,
                "receivername":username,
                "time":getStringTime()
            ]
            print("User Name in send \(trainername)")
            
            reference
                .child("Chats")
                .child(fitnessCode)
                .child(trainerid)
                .child(userid)
                .child("chat")
                .childByAutoId()
                .setValue(values) { error, reference in
                    if error == nil{
                        self.updateSelf(typingMessage)
                    }
                }
        }
    }
    
    func validationChatList(trainerid:String,completion:@escaping(Bool)->Void){
        
        reference
            .child("ChatList")
            .child(fitnessCode)
            .child(trainerid)
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.childSnapshot(forPath: self.userid).exists(){
                    completion(false)
                }else{
                    completion(true)
                }
            }
    }
}

extension ChattingViewModel{
    func getStringDate()->String{
        let date = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd"
        return dateformatter.string(from: date)
    }
    func getStringTime()->String{
        let date = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm"
        return dateformatter.string(from: date)
    }
}
