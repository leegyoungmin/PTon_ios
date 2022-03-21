//
//  chattingViewmodel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/20.
//

import Foundation
import Firebase


struct chattingRoom:Hashable{
    var opponentId:String
    var opponentName:String
    var favorite:Bool = false
    var Messages:[message]
}

struct message:Hashable{
    var content:String
    var time:String
    var date:String
    var data:Data?
    var isRead:Bool
    var isCurrentUser:Bool
}

class ChattingViewModel:ObservableObject{
    @Published var ChattingRoom:chattingRoom
    let trainee:trainee
    let trainerId:String
    let trainerName:String
    let fitnessCode:String
    let reference = Firebase.Database.database().reference().child("Chats")
    
    init(trainee:trainee,_ trainerId:String,_ trainerName:String,_ fitnessCode:String){
        self.trainee = trainee
        self.trainerId = trainerId
        self.trainerName = trainerName
        self.fitnessCode = fitnessCode
        _ChattingRoom = Published.init(initialValue: chattingRoom(opponentId: trainee.userId, opponentName: trainee.userName, Messages: []))
        
        ObserveData()
    }
    
    var unReadCount:Int{
        return ChattingRoom.Messages.filter({$0.isRead == false && $0.isCurrentUser == false}).count
    }
    
    func ObserveData(){
        if trainee.userid != nil{
            reference
                .child(fitnessCode)
                .child(trainerId)
                .child(trainee.userId)
                .child("chat")
                .observe(.childAdded) { snapshot in
                    
                    guard let values = snapshot.value as? [String:Any] else{return}
                    
                    let currentMessage = self.makeDataForm(values, trainerId: self.trainerId)
                    self.ChattingRoom.Messages.append(currentMessage)
                }
            
            reference
                .child(fitnessCode)
                .child(trainerId)
                .child(trainee.userId)
                .child("favorite")
                .observe(.value) { snapshot in
                    guard let isFavorite = snapshot.value as? Bool else{return}
                    self.ChattingRoom.favorite = isFavorite
                }
        }
    }
    
    func makeDataForm(_ values:[String:Any],trainerId:String)->message{
        
        let currentMessage = message(content: "", time: "", date: "", data: nil, isRead: false, isCurrentUser: false)
        
        guard let receiver = values["receiver"] as? String,
              let receiverName = values["receivername"] as? String,
              let time = values["time"] as? String,
              let isRead = values["read"] as? String,
              let senderName = values["sendername"] as? String,
              let content = values["message"] as? String,
              let date = values["date"] as? String,
              let sender = values["sender"] as? String else{return currentMessage}
        
        return message(content: content, time: time, date: date, data: nil, isRead: isRead.bool, isCurrentUser: sender == trainerId)
    }
    
    func changeFavorite(){
        reference
            .child(fitnessCode)
            .child(trainerId)
            .child(trainee.userId)
            .child("favorite")
            .setValue(!self.ChattingRoom.favorite)
    }
}
