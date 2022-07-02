//
//  UserBodyInfoViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/05.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

struct userBodyInfo:Codable{
    var height:String
    var weight:String
    var fat:String
    var muscle:String
    var kcalSetting:String = "200"
}

class BodyInfoViewModel:ObservableObject{
    @Published var height:String = ""
    @Published var weight:String = ""
    @Published var fat:String = ""
    @Published var muscle:String = ""
    let reference = FirebaseDatabase.Database.database().reference().child("UserInfo")
    
    func setupDataBase(Completion:@escaping()->Void){
        guard let userId = FirebaseAuth.Auth.auth().currentUser?.uid,
              let data = userBodyInfo(height: height, weight: weight, fat: fat, muscle: muscle).toDictionary else{return}
        
        FirebaseDatabase.Database.database().reference()
            .child("UserInfo")
            .child(userId)
            .updateChildValues(data) { err, _ in
                if err == nil{
                    Completion()
                }
            }
    }
}
