//
//  RequestedExerciseViewModel.swift
//  Salud0.2
//
//  Created by 이관형 on 2022/01/23.
//

import Foundation
import Firebase
import SwiftUI

//MARK: MODEL


struct requestedExercise:Codable,Hashable{
    var id = UUID().uuidString
    var name:String
    var url:String
    var isDone:Bool
    var parameter:Double
    var minute:Int?
    var time:Int?
    var weight:Int?
    var sets:Int?
    var type:String
    var part:String?
}

//MARK: VIEWMODEL
class RequestedExerciseViewModel: ObservableObject{
    @Published var exercises:[requestedExercise] = []
    @Published var selectedDate:Date = Date()
    let reference = Firebase.Database.database().reference().child("RequestExercise")
    
    var userid:String
    
    init(_ userid:String){
        self.userid = userid
    }
    
    func fetchData(tasks:[()->Void]){
        for task in tasks {
            task()
        }
    }
    
    func fetchFitness(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        reference
            .child(trainerid)
            .child(userid)
            .child(convertDate(selectedDate))
            .child("Fitness")
            .observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children{
                    let childsnap = child as! DataSnapshot
                    let name = childsnap.key
                    guard let values = childsnap.value as? [String:Any],
                          let type = values["Hydro"] as? String else{return}
                    
                    if type == "Aerobic"{
                        guard let parameter = values["Parameter"] as? Double,
                              let type = values["Hydro"] as? String,
                              let done = values["Done"] as? Bool,
                              let minute = values["Minute"] as? Int,
                              let url = values["Url"] as? String else{return}
                        
                        let currentExercise = requestedExercise(name: name,
                                                                url: url,
                                                                isDone: done,
                                                                parameter: parameter,
                                                                minute: minute,
                                                                type: type,
                                                                part: "Fitness")
                        self.exercises.append(currentExercise)
                    }else{
                        guard let parameter = values["Parameter"] as? Double,
                              let type = values["Hydro"] as? String,
                              let done = values["Done"] as? Bool,
                              let time = values["Time"] as? Int,
                              let weight = values["Weight"] as? Int,
                              let set = values["Set"] as? Int,
                              let minute = values["Minute"] as? Int,
                              let url = values["Url"] as? String else{return}
                        
                        let currentExercise = requestedExercise(name: name,
                                                                url: url,
                                                                isDone: done,
                                                                parameter: parameter,
                                                                minute: minute,
                                                                time: time,
                                                                weight: weight,
                                                                sets: set,
                                                                type: type,
                                                                part: "Fitness")
                        self.exercises.append(currentExercise)
                    }
                    
                    
                    print("Read Data Fitness values \(values)")
                }
            }
    }
    
    func fetchAerobic(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        reference
            .child(trainerid)
            .child(userid)
            .child(convertDate(selectedDate))
            .child("Aerobic")
            .observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children{
                    let childsnap = child as! DataSnapshot
                    let name = childsnap.key
                    guard let values = childsnap.value as? [String:Any] else{return}
                    
                    guard let parameter = values["Parameter"] as? Double,
                          let type = values["Hydro"] as? String,
                          let done = values["Done"] as? Bool,
                          let minute = values["Minute"] as? Int,
                          let url = values["Url"] as? String else{return}
                    
                    let currentExercise = requestedExercise(name: name,
                                                            url: url,
                                                            isDone: done,
                                                            parameter: parameter,
                                                            minute: minute,
                                                            type: type,
                                                            part: "Aerobic")
                    self.exercises.append(currentExercise)
                }
            }
        
    }
    
    func fetchAnAerobic(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        reference
            .child(trainerid)
            .child(userid)
            .child(convertDate(selectedDate))
            .child("AnAerobic")
            .observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children{
                    let child = child as! DataSnapshot
                    let part = child.key
                    
                    guard let values = child.value as? [String:[String:Any]] else{return}
                    
                    values.keys.forEach { name in
                        guard let value = values[name],
                              let url = value["Url"] as? String,
                              let time = value["Time"] as? Int,
                              let minute = value["Minute"] as? Int,
                              let parameter = value["Parameter"] as? Double,
                              let set = value["Set"] as? Int,
                              let weight = value["Weight"] as? Int,
                              let done = value["Done"] as? Bool else{return}
                        
                        let currentData = requestedExercise(name: name,
                                                            url: url,
                                                            isDone: done,
                                                            parameter: parameter,
                                                            minute: minute,
                                                            time: time,
                                                            weight: weight,
                                                            sets: set,
                                                            type: "AnAerobic",
                                                            part: part)
                        self.exercises.append(currentData)
                    }
                }
            }
    }
    
    func deleteData(exercise:requestedExercise){
        self.exercises = self.exercises.filter{ $0.name != exercise.name }
        
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        
        if exercise.part == "Fitness"{
            reference
                .child(trainerid)
                .child(userid)
                .child(convertDate(selectedDate))
                .child("Fitness")
                .child(exercise.name)
                .removeValue()
        }else if exercise.part == "Aerobic"{
            reference
                .child(trainerid)
                .child(userid)
                .child(convertDate(selectedDate))
                .child("Aerobic")
                .child(exercise.name)
                .removeValue()
        }else{
            reference
                .child(trainerid)
                .child(userid)
                .child(convertDate(selectedDate))
                .child("AnAerobic")
                .child(exercise.part!)
                .child(exercise.name)
                .removeValue()
        }
    }
    
    func setData(exercise:requestedExercise,newvalue:[String:Any]){
        
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        
        
        if exercise.part == "Fitness"{
            if exercise.type == "Aerobic"{
                reference
                    .child(trainerid)
                    .child(userid)
                    .child(convertDate(selectedDate))
                    .child("Aerobic")
                    .child(exercise.name)
                    .updateChildValues(newvalue)
            }else{
                reference
                    .child(trainerid)
                    .child(userid)
                    .child(convertDate(selectedDate))
                    .child("Fitness")
                    .child(exercise.name)
                    .updateChildValues(newvalue)
            }
            
        }else if exercise.part == "Aerobic"{
            reference
                .child(trainerid)
                .child(userid)
                .child(convertDate(selectedDate))
                .child("Aerobic")
                .child(exercise.name)
                .updateChildValues(newvalue)
        }else{
            reference
                .child(trainerid)
                .child(userid)
                .child(convertDate(selectedDate))
                .child("AnAerobic")
                .child(exercise.part!)
                .child(exercise.name)
                .updateChildValues(newvalue)
        }
    }
    
   
    
    func convertDate(_ date:Date)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    func minuteEditor(time: Int, sets: Int) -> Int{
        return Int(round(((Double)(time)*(Double)(sets) * 5.0) / 60.0))
    }
}



