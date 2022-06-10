//
//  userExerciseSearchViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/06/01.
//

import Foundation
import Firebase
import SwiftUI

enum exercisePart:String,CaseIterable{
    case Aerobic
    case Abs
    case Arm
    case Back
    case Chest
    case Compound
    case Leg
    case Shoulder
    case Fitness
    
    var description:String{
        switch self {
        case .Aerobic:
            return "유산소"
        case .Abs:
            return "복근"
        case .Arm:
            return "팔"
        case .Back:
            return "등"
        case .Chest:
            return "가슴"
        case .Compound:
            return "복합 운동"
        case .Leg:
            return "하체"
        case .Shoulder:
            return "어깨"
        case .Fitness:
            return "피트니스"
        }
    }
    
    var keyValues:[String]{
        return ["Aerobic","AnAerobic","Fitness"]
    }
}

struct userExerciseData:Identifiable,Hashable{
    var id:String
    var engName:String
    var exerciseName:String
    var expectedKcal:Double
    var hydro:String
    var minute:Int
    var parameter:Double
    var part:exercisePart
    var set:String?
    var time:String?
    var url:String
    var weight:String?
}

class userExerciseSearchViewModel:ObservableObject{
    @Published var recordedData:[userExerciseData] = []
    let userId:String
    let fitnessCode:String
    let selectedDate:Date
    var userWeight:Double? = nil
    let reference = Firebase.Database.database().reference().child("bodydata")
    init(userId:String,fitnessCode:String,selectedDate:Date){
        self.userId = userId
        self.fitnessCode = fitnessCode
        self.selectedDate = selectedDate
        self.settingUserWeight()
        
        self.observeData()
    }
    
    func settingUserWeight(){
        reference
            .child(self.userId)
            .observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self else{return}
                snapshot.children.forEach{
                    let childSnapshot = $0 as! DataSnapshot
                    guard let childValue = childSnapshot.value as? [String:Any] else{return}
                    if let weight = childValue["weight"] as? String,
                       let weightValue = Double(weight){
                        if weightValue != 0{
                            self.userWeight = Double(weight)!
                        }
                    }
                }
            }
    }
    
    func observeData(){
        Firebase.Database.database().reference()
            .child("ExerciseRecord")
            .child(self.userId)
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .observe(.childAdded) { [weak self] snapshot in
                guard let self = self,
                      let values = snapshot.value as? [String:Any] else{return}
                print("user exercise Record ::: \(values)")
                let id = snapshot.key
                let part = exercisePart(rawValue: (values["part"] as? String)!) ?? .Aerobic
                let engName = values["engName"] as? String ?? ""
                let exerciseName = values["exerciseName"] as? String ?? ""
                let expectKcal = values["expectKcal"] as? Double ?? 0
                let hydro = values["hydro"] as? String ?? ""
                let minute = values["minute"] as? Int ?? 1
                let parameter = values["parameter"] as? Double ?? 0
                let url = values["url"] as? String ?? "default"
                
                let set = values["set"] as? String
                let time = values["time"] as? String
                let weight = values["weight"] as? String
                
                let currentData = userExerciseData(id: id,
                                                   engName: engName,
                                                   exerciseName: exerciseName,
                                                   expectedKcal: expectKcal,
                                                   hydro: hydro,
                                                   minute: minute,
                                                   parameter: parameter,
                                                   part: part,
                                                   set: set,
                                                   time: time,
                                                   url: url,
                                                   weight: weight)
                
                self.recordedData.append(currentData)
            }
    }
    
    //MARK: 유저 소모 칼로리 계산 함수
    /// exercuseParameter : 운동 단위 가중치
    /// settingTime : 운동 시간 - (세트수 * 횟수 * 5) 분 환산
    func calUserData(_ exerciseParameter:Double,settingTime:Int) -> Double{
        guard let userWeight = userWeight else {
            return 0
        }
        return ((exerciseParameter * userWeight)/30) * Double(settingTime)
    }
    
    //MARK: 데이터 저장 메소드
    func updateDataBase(_ values:[String:Any],completion:@escaping()->()){
        Firebase.Database.database().reference()
            .child("ExerciseRecord")
            .child(self.userId)
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .childByAutoId()
            .updateChildValues(values) { error, ref in
                completion()
            }
    }
    
}
