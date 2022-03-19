//
//  ChattingListViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/10.
//

import Foundation
import Firebase
import SwiftUI

//MARK: MODEL
struct ChatRoom:Hashable{
    var userid:String
    var username:String
    var favorite:Bool = false
    var chattings:[Chat]
}

struct Chat:Hashable{
    var lastMessage:String
    var time:String
    var urlString:String?
    var isRead:String
}



//MARK: VIEWMODEL
//TODO: 1. 채팅 목록 불러오기 함수 및 채팅방 유무 확인 함수 변경
//TODO: 2. 초기화 다음에는 비동기로 사용되도록 변경

class ChattingListViewModel:ObservableObject{
    @Published var ChatLists:ChatRoom
    var useridList:[String] = []
    var fitnessCode:String
    var trainername:String
    var trainee:trainee
    let reference:DatabaseReference
    
    init(trainername:String,fitnessCode:String,trainee:trainee){
        self.trainername = trainername
        self.fitnessCode = fitnessCode
        self.trainee = trainee
        
        self.ChatLists = ChatRoom(userid: trainee.userid!, username: trainee.username!, chattings: [])
        
        self.reference = Firebase.Database.database().reference().child("Chats")
    }
    
    func ObserveData(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid,
              let userid = trainee.userid else{return}
        
        self.ChatLists.chattings.removeAll()
        
        reference
            .child(fitnessCode)
            .child(trainerid)
            .child(userid)
            .child("chat")
            .observe(.childAdded) { snapshot in
                guard let values = snapshot.value as? [String:Any] else{return}
                
                let chatting = self.makeData(userid, values)
                self.ChatLists.chattings.append(chatting)
                
            }
        
        reference
            .child(fitnessCode)
            .child(trainerid)
            .child(userid)
            .child("favorite")
            .observe(.value) { snapshot in
                self.ChatLists.favorite = snapshot.exists()
            }
    }
    
    func setFavorite(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid,
              let userid = trainee.userid else{return}
        if self.ChatLists.favorite{
            reference
                .child(self.fitnessCode)
                .child(trainerid)
                .child(userid)
                .child("favorite")
                .removeValue()
        }else{
            reference
                .child(self.fitnessCode)
                .child(trainerid)
                .child(userid)
                .updateChildValues(["favorite":true])
        }
        

    }
    
    func makeData(_ userid:String,_ values:[String:Any])->Chat{
        guard let date = values["date"] as? String,
              let message = values["message"] as? String,
              let read = values["read"] as? String,
              let time = values["time"] as? String else{return Chat(lastMessage: "", time: "", isRead: "false")}
        
        return Chat(lastMessage: message, time: time, isRead: read)
        
    }
    
    func lastChatting()->Chat{
        var chat = Chat(lastMessage: "", time: "", isRead: "true")
        if ChatLists.chattings.last != nil{
            chat = ChatLists.chattings.last!
        }
        return chat
    }
    
    func profileUrl()->String{
        var url:String = ""
        print(trainee)
        if trainee.userProfile != nil{
            url = trainee.userProfile!
        }
        return url
    }
        
    //view가 사라 질 때 관찰자 지우기
    func onViewDisAppear(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid,
              let userid = self.trainee.userid else{return}
        DispatchQueue.main.async {
            self.reference
                .child(self.fitnessCode)
                .child(trainerid)
                .child(userid)
                .removeAllObservers()
        }
    }
    //
}
