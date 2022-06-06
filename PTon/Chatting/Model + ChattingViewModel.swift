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
}

class ChattingRoomListViewModel:ObservableObject{
    @Published var chatRooms:[chattingRoom] = []
    let fitnessCode:String
    let trainerId:String
    let reference:DatabaseReference
    
    init(fitnessCode:String,trainerId:String){
        self.fitnessCode = fitnessCode
        self.trainerId = trainerId
        
        self.reference = Firebase.Database.database().reference().child("Chats").child(fitnessCode).child(trainerId)
        
        self.observeChats()
    }
    
    func observeChats(){
        reference.observe(.childAdded) { [weak self] snapshot in
            print("child Added \(snapshot)")
            
//            snapshot.childSnapshot(forPath: "chat").ref.queryLimited(toLast: 1)
            
            guard let self = self,let values = snapshot.value as? [String:Any] else{return}
            
            let userId = snapshot.key
            let userName = values["userName"] as? String ?? ""
            let isFavorite = values["isFavorite"] as? Bool ?? false
            self.chatRooms.append(chattingRoom(opponentId: userId, opponentName: userName, favorite: isFavorite))
        }
        
        reference.child("isFavorite").observe(.childChanged) { [weak self] snapshot in
            print("child changed \(snapshot)")
            guard let self = self,let values = snapshot.value as? [String:Any] else{return}
            
            let userId = snapshot.key
            let isFavorite = values["isFavorite"] as? Bool ?? false
            
            guard let index = self.chatRooms.firstIndex(where: { $0.opponentId == userId }) else{return}
            
            self.chatRooms[index].favorite = isFavorite
        }
    }
    
    func ToggleFavorite(_ userId:String){
        guard let room = chatRooms.first(where: { $0.opponentId == userId }) else{ return }
        reference.child(room.opponentId).updateChildValues(["isFavorite":!room.favorite])
    }
}
