//
//  Model + UserBaseInfoViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/29.
//

import Foundation
import Firebase

//MARK: - MODEL
struct userBase:Codable{
    var bodyWeight:String?
    var bodyFat:String?
    var bodyMuscle:String?
}


//MARK: - VIEWMODEL
class UserBaseInfoViewModel:ObservableObject{
    
    @Published var weightText:String = ""
    @Published var fatText:String = ""
    @Published var muscleText:String = ""
    
    let userId:String
    let reference = Firebase.Database.database().reference().child("bodydata")
    init(_ userId:String){
        self.userId = userId
        
        readData(Date())
    }
    
    func readData(_ selectedData:Date){
        reference
            .child(self.userId)
            .child(convertString(content: selectedData, dateFormat: "yyyy-MM-dd"))
            .observeSingleEvent(of: .value) { snapshot in
                
                if snapshot.exists(){
                    guard let values = snapshot.value as? [String:Any] else{return}
                    
                    guard let fat = values["fat"] as? String,
                          let muscle = values["muscle"] as? String,
                          let weight = values["weight"] as? String else{return}
                    
                    self.weightText = weight
                    self.muscleText = muscle
                    self.fatText = fat
                }else{
                    self.weightText = ""
                    self.muscleText = ""
                    self.fatText = ""
                }
                

            }
    }
    
    func updateValue(_ selectedDate:Date){
        let data:[String:Any] = [
            "fat":fatText.isEmpty ? "0":fatText,
            "weight":weightText.isEmpty ? "0":weightText,
            "muscle":muscleText.isEmpty ? "0":muscleText
        ]
        
        reference
            .child(self.userId)
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .updateChildValues(data)
    }
}
