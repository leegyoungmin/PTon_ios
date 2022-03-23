//
//  ChattingInputViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/21.
//

import Foundation
import Firebase


class ChattingInputViewModel:ObservableObject{
    let trainerId:String
    let trainerName:String
    let userId:String
    let userName:String
    let fitnessCode:String
    let reference = Firebase.Database.database().reference().child("Chats")
    
    init(_ trainerId:String,trainerName:String,_ userId:String,userName:String,_ fitnessCode:String){
        self.trainerId = trainerId
        self.userId = userId
        self.trainerName = trainerName
        self.userName = userName
        self.fitnessCode = fitnessCode
    }
    
    

    
    
    func sendText(_ message:String){
        let values = [
            "date":getStringDate(),
            "message":message,
            "read":"false",
            "sender":self.trainerId,
            "sendername":self.trainerName,
            "receiver":self.userId,
            "receivername":self.userName,
            "time":getStringTime()
        ]
        reference
            .child(fitnessCode)
            .child(trainerId)
            .child(userId)
            .child("chat")
            .childByAutoId()
            .setValue(values)
    }
    
    func uploadImage(_ image:Data){
        let storage = FirebaseStorage.Storage.storage().reference()
        let path = "ChatsImage_\(userId)_\(trainerId)_\(convertString(content: Date(), dateFormat: "yyyy_MM_dd_HH_mm_ss")).jpg"
        
        storage.child("ChatsImage").child(path)
            .putData(image, metadata: nil){ _, error in
                if error == nil{
                    self.sendText(path)
                }
            }
    }
    
    func sendReservation(_ date:Date){
        if let dateString = convertString(content: date, dateFormat: "MM월 dd일") as? String,
           let timeString = convertString(content: date, dateFormat: "HH시 mm분") as? String{
            let message = "\(self.trainerName) 트레이너님이 " + dateString + " " + timeString + "에 PT 일정을 예약하셨습니다."
            
            let data:[String:Any] = [
                "Checked":false,
                "Time":convertString(content: date, dateFormat: "HH:mm")
            ]
            
            Firebase.Database.database().reference()
                .child("Reservation")
                .child(trainerId)
                .child(convertString(content: date, dateFormat: "yyyy-MM-dd"))
                .child(userId)
                .setValue(data)
            
            sendText(message)
        }
    }
    //TODO: - chatting 읽음 처리
    func ChangeRead(){
        reference
            .child(fitnessCode)
            .child(trainerId)
            .child(userId)
            .child("chat")
            .observeSingleEvent(of: .value, with: { snapshot in
                for child in snapshot.children{
                    let childSnapshot = child as! DataSnapshot
                    print("All Value in snapshot :::: \(snapshot)")
                    
                    if childSnapshot.childSnapshot(forPath: "receiver").value as? String == self.trainerId,
                       childSnapshot.childSnapshot(forPath: "read").value as? String == "false"{
                        childSnapshot.ref.updateChildValues(["read":"true"])
                    }
                }
            })
    }
    
    func viewDisAppear(){
        ChangeRead()
    }
}

extension ChattingInputViewModel{
    func getStringDate()->String{
        let date = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy년 MM월 dd일"
        return dateformatter.string(from: date)
    }
    func getStringTime()->String{
        let date = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "a h:mm"
        return dateformatter.string(from: date)
    }
}