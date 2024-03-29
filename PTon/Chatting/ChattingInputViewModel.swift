//
//  ChattingInputViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/21.
//

import Foundation
import Firebase
import FirebaseStorage
import Kingfisher


class ChattingInputViewModel:ObservableObject{
    @Published var userMemberShip = memberShip()
    let trainerId:String
    let trainerName:String
    let userId:String
    let userName:String
    let fitnessCode:String
    var readHandle:DatabaseHandle!
    let reference = Firebase.Database.database().reference().child("Chats")
    
    init(_ trainerId:String,trainerName:String,_ userId:String,userName:String,_ fitnessCode:String){
        self.trainerId = trainerId
        self.userId = userId
        self.trainerName = trainerName
        self.userName = userName
        self.fitnessCode = fitnessCode
    }
    
    func sendText(_ message:String){
        guard let compareId = Firebase.Auth.auth().currentUser?.uid else{return}
        
        Database.database().reference()
            .child("ChatList")
            .child(fitnessCode)
            .child(trainerId)
            .child(userId)
            .observeSingleEvent(of: .value) { snapshot in
                if !snapshot.exists(){
                    snapshot.ref.updateChildValues([self.userId:["uid":self.userId,"favorite":false]])
                }
            }

        setData(compareId == trainerId, message: message)
    }
    
    func setData(_ isTrainer:Bool,message:String){
        if isTrainer{
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
        }else{
            let values = [
                "date":getStringDate(),
                "message":message,
                "read":"false",
                "sender":self.userId,
                "sendername":self.userName,
                "receiver":self.trainerId,
                "receivername":self.trainerName,
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
    }
    
    func uploadImage(_ image:Data,completion:@escaping()->Void){
        guard let compareId = Firebase.Auth.auth().currentUser?.uid else{return}
        
        if compareId == trainerId{
            let storage = FirebaseStorage.Storage.storage().reference().child("ChatsImage").child(fitnessCode).child(trainerId).child(userId)
            uploadImageData(storage: storage,image: image) {
                completion()
            }
        }else{
            let storage = FirebaseStorage.Storage.storage().reference().child("ChatsImage").child(fitnessCode).child(userId).child(trainerId)
            uploadImageData(storage: storage,image: image) {
                completion()
            }
        }

    }
    
    func uploadImageData(storage:StorageReference,image:Data,completion:@escaping()->Void){
        let path = "ChatsImage_\(convertString(content: Date(), dateFormat: "yyyy_MM_dd_HH_mm_ss")).jpg"
        let meta = StorageMetadata()
        meta.contentType = "jpg"
        
        storage.child(path).putData(image, metadata: meta) { meta, error in
            if error == nil{
                self.sendText(path)
                completion()
            }
        }
    }
    
    func sendReservation(_ date:Date){
        let dateString = convertString(content: date, dateFormat: "MM월 dd일")
        let timeString = convertString(content: date, dateFormat: "HH시 mm분")
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
    //TODO: - chatting 읽음 처리
    func ChangeRead(){
        
        guard let currentId = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        self.readHandle = reference
            .child(fitnessCode)
            .child(trainerId)
            .child(userId)
            .child("chat")
            .observe(.childAdded, with: { snapshot in
                print("All Value in snapshot :::: \(snapshot)")
                
                if snapshot.childSnapshot(forPath: "receiver").value as? String == currentId,
                   snapshot.childSnapshot(forPath: "read").value as? String == "false"{
                    snapshot.ref.updateChildValues(["read":"true"])
                }
            })
    }
    
    func UserLicense(completions: @escaping (Bool,Bool)->Void){
//        guard let compareId = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        Database.database().reference()
            .child("Membership")
            .child(self.userId)
            .observeSingleEvent(of: .value) { snapshot in
                guard let values = snapshot.value as? [String:Any] else{return}
                
                if let ptUsed = values["ptUsed"] as? String{
                    self.userMemberShip.useLisence = ptUsed
                }
                
                if let ptTimes = values["ptTimes"] as? String{
                    self.userMemberShip.maxLisence = ptTimes
                }
                
                if let start = values["StartDate"] as? String{
                    self.userMemberShip.startMember = convertdate(content: start, format: "yyyy-MM-dd")
                }
                
                if let end = values["EndDate"] as? String{
                    self.userMemberShip.endMember = convertdate(content: end, format: "yyyy-MM-dd")
                }
                
                completions((self.userMemberShip.IntMaxLisense - self.userMemberShip.IntuserLisence) != 0, (convertInteval(firstDate:self.userMemberShip.endMember!,second:self.userMemberShip.startMember!) != 0))
            }
    }
    
    func viewDisAppear(){
//        SDImageCache.shared.clear(with: .all)
        ImageCache.default.clearMemoryCache()
        
        self.reference.child(fitnessCode).child(trainerId).child(userId).child("chat").removeObserver(withHandle: self.readHandle)
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
