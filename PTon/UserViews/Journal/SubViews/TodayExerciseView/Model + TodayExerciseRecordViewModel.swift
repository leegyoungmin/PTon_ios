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
    var hydro:String
    var hour:String?
    var minute:String?
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
        
        fetchData(Date())
    }
    
    
    func fetchData(_ selectedDate:Date){
        reference
            .child("ExerciseRecord")
            .child(userId)
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .observeSingleEvent(of: .value) { snapshot in
                
                for child in snapshot.children{
                    let childSnapshot = child as! DataSnapshot
                    let uuid = childSnapshot.key
                    
                    guard let values = childSnapshot.value as? [String:Any],
                          let exercisePart = values["Hydro"] as? String,
                          let exerciseName = values["Exercise"] as? String else{return}
                    
                    
                    if exercisePart == "Aerobic"{
                        guard let hour = values["Hour"] as? String,
                              let minute = values["Minute"] as? String,
                              let time = values["Time"] as? Int else {return}
                        
                        
                        let currentExercise = todayExercise(uuid: uuid, exerciseName: exerciseName, hydro: exercisePart, hour: hour, minute: minute,time: String(time))
                        self.todayExercises.append(currentExercise)
                        
                    }else if exercisePart == "AnAerobic"{
                        guard let minute = values["Minute"] as? String,
                              let part = values["Part"] as? String,
                              let set = values["Sets"] as? String,
                              let time = values["Time"] as? String,
                              let weight = values["Weight"] as? String else{return}
                        
                        let currentExercise = todayExercise(uuid: uuid, exerciseName: exerciseName, hydro: exercisePart,minute: minute, time: time, part: part, sets: set, weight: weight)
                        self.todayExercises.append(currentExercise)
                    }
                    
                    print(childSnapshot)
                }
                
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
