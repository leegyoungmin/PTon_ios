//
//  UserChattingViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/16.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class UserChattingViewModel:ObservableObject{
    @Published var userMessages:[Message] = []
    @Published var typingMessage:String = ""
    
    var userid:String
    var trainerid:String
    var username:String
    var fitnessCode:String
    var trainerName:String? = ""
    
    let reference = FirebaseDatabase.Database.database().reference()
    
    init(userid:String,trainerid:String,username:String,fitnessCode:String){
        self.userid = userid
        self.trainerid = trainerid
        self.username = username
        self.fitnessCode = fitnessCode
        
        //@escaping 탈출 후 데이터 불러오기 실행
        self.getTrainerName { trainername in
            self.trainerName = trainername
            
            self.fetchData()
        }
    }
    var trainername:String{
        guard let trainerName = trainerName else {
            return ""
        }

        return trainerName
    }
    
    
    func getTrainerName(completion:@escaping(String)->Void){
        
        /*
         트레이너 id로 트레이너 이름 가져오는 함수
         @escaping 메소드로 문자 탈출시킴
         */
        
        reference
            .child("Trainer")
            .child(trainerid)
            .child("name")
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists(){
                    guard let trainername = snapshot.value as? String else {return}
                    completion(trainername)
                }
            }
        
    }
    
    //데이터 불러오기 함수
    func fetchData(){
        
        
        
        reference
            .child("Chats")
            .child(self.fitnessCode)
            .child(self.trainerid)
            .child(self.userid)
            .observe(.value) { snapshot in
                self.userMessages.removeAll(keepingCapacity: true)
                
                for child in snapshot.children{
                    let childsnap = child as! DataSnapshot
                    guard let values = childsnap.value as? [String:Any] else {return}
                    guard let message = values["message"] as? String,
                          let senderid = values["sender"] as? String,
                          let sendername = values["sendername"] as? String,
                          let receivername = values["receivername"] as? String,
                          let time = values["time"] as? String,
                          let date = values["date"] as? String else{return}
                    
                    //trainerid가 보낸 id일 경우 -> Trainer Message
                    if self.trainerid == senderid{
                        let chattingUser = ChattingUser(name: sendername, isCurrentUser: false)
                        let currentMessage = Message(content: message, time: time, date: date, user: chattingUser)
                        
                        self.userMessages.append(currentMessage)
                    }
                    //trainerid가 보낸 id가 아닌 경우 -> User Message
                    else{
                        let chattingUser = ChattingUser(name: receivername, isCurrentUser: true)
                        let currentMessage = Message(content: message, time: time, date: date, user: chattingUser)
                        self.userMessages.append(currentMessage)
                    }
                }
            }
        
    }
    
    //유저 채팅 보내기 함수
    func send(){
        
        //트레이너 이름 nil 검사후 디비 저장 함수
        
        if self.trainername != ""{
            if self.typingMessage != ""{
                let values = [
                    "date":getStringDate(),
                    "message":typingMessage,
                    "read":"false",
                    "sender":userid,
                    "sendername":username,
                    "receiver":trainerid,
                    "receivername":trainername,
                    "time":getStringTime()
                ]
                
                typingMessage = ""
                reference
                    .child("Chats")
                    .child(fitnessCode)
                    .child(trainerid)
                    .child(userid)
                    .childByAutoId()
                    .setValue(values) { error, reference in
                        if error == nil{
                            print("Success Send Button")
                        }
                    }
            }
        }
    }
    
    //TODO: - 채팅방 접근시 읽음 처리 함수 생성
}


extension UserChattingViewModel{
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
