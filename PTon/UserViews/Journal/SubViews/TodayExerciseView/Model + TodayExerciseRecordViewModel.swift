//
//  Model + TodayExerciseRecordViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/26.
//

import Foundation
import Firebase

//MARK: - MODEL
struct userExercise:Codable{
    let anAerobic:AnAerobic
    let aerobic:[String]
    enum CodingKeys:String,CodingKey{
        case anAerobic = "AnAerobic"
        case aerobic = "Aerobic"
    }
}
struct AnAerobic:Codable{
    let chest,shoulder,back,leg,arm,abs:[String]
    enum CodingKeys: String, CodingKey, CaseIterable {
            case chest = "Chest"
            case shoulder = "Shoulder"
            case back = "Back"
            case leg = "Leg"
            case arm = "Arm"
            case abs = "Abs"
        }
}

struct todayExercise:Hashable{
    var uuid:String
    var exerciseName:String
    var hour:Int
    var minute:Int
    var time:String?
    var part:String?
    var sets:String?
    var weight:String?
}

//MARK: - VIEWMODEL
class TodayExerciseViewModel:ObservableObject{
    @Published var todayExercises:[todayExercise] = []
    let userId:String
    let reference = Firebase.Database.database().reference()
    
    init(userId:String){
        self.userId = userId
    }
    
    
    func fetchData(_ selectedDate:Date){
        reference
            .child("ExerciseRecord")
            .child(userId)
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .observeSingleEvent(of: .value) { snapshot in
                print("Data read ::: \(snapshot)")
            }
    }
    
    func uploadData(_ selectedData:Date,data:[String:Any]){
        
        
        reference
            .child("ExerciseRecord")
            .child(userId)
            .child(convertString(content: selectedData, dateFormat: "yyyy-MM-dd"))
            .childByAutoId()
            .setValue(data)
    }
}
