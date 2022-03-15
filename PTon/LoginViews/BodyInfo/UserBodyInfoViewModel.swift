//
//  UserBodyInfoViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/05.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class BodyInfoViewModel:ObservableObject{
    @Published var height:String = ""
    @Published var weight:String = ""
    @Published var fat:String = ""
    @Published var muscle:String = ""
    let reference = FirebaseDatabase.Database.database().reference().child("UserInfo")
    
    //각 데이터별 검사후 오류 생성 메소드
    func ValidValue() throws {
        if self.height.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            throw ValidationError.MissingHeight
        }
        else if self.weight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            throw ValidationError.MissingWeight
        }
        else if self.fat.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            throw ValidationError.MissingFat
        }
        else if self.muscle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            throw ValidationError.MissingMuscle
        }
    }
    
    //데이터 베이스 저장 메소드
    func uploadData(completion:@escaping()->Void){
        guard let userid = FirebaseAuth.Auth.auth().currentUser?.uid else {return}
        let values:[String:String] = [
            "height":height,
            "weight":weight,
            "fat":fat,
            "muscle":muscle,
            "kcalSetting":"0"
        ]
        reference
            .child(userid)
            .setValue(values) { error, reference in
                if error == nil{
                    completion()
                }
            }
    }
}
