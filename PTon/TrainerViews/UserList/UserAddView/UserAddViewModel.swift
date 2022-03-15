//
//  AddUserViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/08.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase

//MARK: VIEWMODEL
class UserAddViewModel:ObservableObject{
    @Published var phoneNumber:String = ""
    @Published var findtrainee = trainee()
    let reference = FirebaseDatabase.Database.database().reference()
    
    //유저 데이터 불러오기 메소드
    func findUser(){
        reference
            .child("User")
            .observeSingleEvent(of: .value, with: { snapshot in
                for childValue in snapshot.children{
                    guard let childValues = childValue as? DataSnapshot,
                          let values = childValues.value as? [String:Any] else{return}
                    
                    if values["phone"] as? String == self.phoneNumber{
                        print(true.description)
                        self.findtrainee.useremail = values["email"]! as? String
                        self.findtrainee.username = values["name"]! as? String
                        self.findtrainee.userid = values["uid"]! as? String
                        break
                    }
                    else{
                        print(false.description)
                        self.findtrainee.username = nil
                        self.findtrainee.useremail = nil
                    }
                }
            })
    }
    
    //유저 업데이트 메소드
    func updateUser(){
        guard let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid,
              let userid = findtrainee.userid else{return}
        reference
            .child("Trainer")
            .child(trainerid)
            .child("trainee")
            .child(userid)
            .setValue(findtrainee.username, withCompletionBlock: { error, reference in
                if error == nil{
                    self.reference
                        .child("User")
                        .child(userid)
                        .child("trainer")
                        .setValue(trainerid)
                }
            })
    }
    
    //TODO: 제거 알림 메소드
}
