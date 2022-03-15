//
//  ChattingListViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/10.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import SwiftUI

//MARK: MODEL
struct Chat:Hashable{
    var userid:String
    var username:String
    var lastMessage:String
    var time:String
    var urlString:String?
}



//MARK: VIEWMODEL
//TODO: 1. 채팅 목록 불러오기 함수 및 채팅방 유무 확인 함수 변경
//TODO: 2. 초기화 다음에는 비동기로 사용되도록 변경

class ChattingListViewModel:ObservableObject{
    @Published var Chats:[Chat] = []
    var useridList:[String] = []
    var fitnessCode:String
    var trainername:String
    let reference = FirebaseDatabase.Database.database().reference()
    
    init(trainername:String,fitnessCode:String){
        self.trainername = trainername
        self.fitnessCode = fitnessCode
    }
    
    //채팅 리스트 내 유저 아이디 찾기 메소드
    func refreshChatList(){
        guard let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        self.useridList.removeAll(keepingCapacity: true)
        reference
            .child("ChatList")
            .child(fitnessCode)
            .child(trainerid)
            .observeSingleEvent(of: .value, with: { snapshot in
                for child in snapshot.children{
                    let childSnap = child as! DataSnapshot
                    let userid = childSnap.key
                    self.getChatData(userid: userid)
                }
            })
    }
    
    //채팅 데이터 불러오기 메소드
    func getChatData(userid:String){
        guard let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        self.Chats.removeAll(keepingCapacity: true)
        
        self.getUserProfileImage(userid) { [self] profileurl in
            reference
                .child("Chats")
                .child(fitnessCode)
                .child(trainerid)
                .child(userid)
                .queryLimited(toLast: 1)
                .getData(completion: { error, snapshot in
                    if error == nil{
                        
                        for child in snapshot.children{
                            let childSnap = child as! DataSnapshot
                            
                            guard let receiverid = childSnap.childSnapshot(forPath: "receiver").value as? String,
                                  let receivername = childSnap.childSnapshot(forPath: "receivername").value as? String,
                                  let senderid = childSnap.childSnapshot(forPath: "sender").value as? String,
                                  let sendername = childSnap.childSnapshot(forPath: "sendername").value as? String,
                                  let message = childSnap.childSnapshot(forPath: "message").value as? String,
                                  let time = childSnap.childSnapshot(forPath: "time").value as? String else{return}
                            
                            if receiverid == trainerid{
                                let chat = Chat(userid:senderid,username: sendername, lastMessage: message, time: time,urlString: profileurl)
                                self.Chats.append(chat)
                            }else{
                                let chat = Chat(userid:receiverid,username: receivername, lastMessage: message, time: time,urlString: profileurl)
                                self.Chats.append(chat)
                            }
                        }
                    }
                })
        }
    }
    
    func getUserProfileImage(_ userid:String,completions:@escaping(String?)->Void){
        reference
            .child("User")
            .child(userid)
            .child("photoUri")
            .observeSingleEvent(of: .value) { snapshot in
                let url = snapshot.value as? String
                completions(url)
            }
    }
    
    //view가 사라 질 때 관찰자 지우기
    func onViewDisAppear(){
        reference.removeAllObservers()
    }
}
