
//  ChattingImageViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/11.
//

import Foundation
import FirebaseStorage
import Firebase

class ChattingImageViewModel:ObservableObject{
    @Published var imageUrl:String = ""
    let path:String
    let trainerId:String
    let userId:String
    let fitnessCode:String
    
    init(_ path:String,_ trainerId:String,_ userId:String,_ fitnessCode:String){
        self.path = path
        self.trainerId = trainerId
        self.userId = userId
        self.fitnessCode = fitnessCode
        
        
        setURL()
    }
    
    func setURL(){
        guard let currentId = Firebase.Auth.auth().currentUser?.uid else{return}
        if currentId == trainerId{
            FirebaseStorage.Storage.storage().reference()
                .child("ChatsImage")
                .child(fitnessCode)
                .child(trainerId)
                .child(userId)
                .child(path)
                .downloadURL { url, error in
                    guard error == nil else{return}
                    print(url?.absoluteString)
                    if let imageUrl = url?.absoluteString{
                        self.imageUrl = imageUrl
                    }
                }
        }
        else if currentId == userId{
            FirebaseStorage.Storage.storage().reference()
                .child("ChatsImage")
                .child(fitnessCode)
                .child(userId)
                .child(trainerId)
                .child(path)
                .downloadURL { url, error in
                    guard error == nil else{return}
                    print(url?.absoluteString)
                    if let imageUrl = url?.absoluteString{
                        self.imageUrl = imageUrl
                    }
                }
        }
        
    }
    
}
