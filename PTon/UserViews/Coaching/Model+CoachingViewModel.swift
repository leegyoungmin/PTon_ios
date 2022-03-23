//
//  Model+CoachingViewModel.swift
//  PTon
//
//  Created by 이관형 on 2022/02/18.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase



//MARK: Coach Model
struct coachExercise:Hashable{
    var exerciseName:String
    var exerciseType:String // Aerobic,Anaerobic,Fitness
    var exercisePart:String? // Anaerobic Exercise Part
    var sets:Int?
    var weight:Int?
    var time:Int?
    var minute:Int?
    var parameter:Double
    var imageUrl:String
    var isDone:Bool
}

class CoachViewModel : ObservableObject{
    @Published var coachExerciseList:[coachExercise] = []
    let trainerId:String
    let userId:String
    let reference = Firebase.Database.database().reference().child("RequestExercise")
    
    
    init(_ trainerId:String,_ userId:String){
        self.trainerId = trainerId
        self.userId = userId
        
        reloadData(Date())
    }
    
    func reloadData(_ selectedDate:Date){
        self.coachExerciseList.removeAll(keepingCapacity: true)
        fetchAerobic(selectedDate: selectedDate)
        fetchFitness(selectedDate: selectedDate)
        fetchAnaerobic(selectedDate: selectedDate)
    }
    
    func fetchAerobic(selectedDate:Date){
        reference
            .child(trainerId)
            .child(userId)
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .child("Aerobic")
            .observeSingleEvent(of: .value) { snapshot in
                
                for child in snapshot.children{
                    let childSnapshot = child as! DataSnapshot
                    let exerciseName = childSnapshot.key
                    
                    guard let values = childSnapshot.value as? [String:Any] else{return}
                    
                    guard let minute = values["Minute"] as? Int,
                          let imageUrl = values["Url"] as? String,
                          let parameter = values["Parameter"] as? Double,
                          let isDone = values["Done"] as? Bool else{return}
                    
                    let currentAerobic = coachExercise(exerciseName: exerciseName, exerciseType: "Aerobic", minute: minute, parameter: parameter, imageUrl: imageUrl, isDone: isDone)
                    self.coachExerciseList.append(currentAerobic)
                }
            }
    }
    
    func fetchFitness(selectedDate:Date){
        reference
            .child(trainerId)
            .child(userId)
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .child("Fitness")
            .observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children{
                    let childSnapshot = child as! DataSnapshot
                    let exerciseName = childSnapshot.key
                    
                    guard let values = childSnapshot.value as? [String:Any] else {return}
                    
                    if childSnapshot.childSnapshot(forPath: "Hydro").value as? String == "AnAerobic"{
                        guard let isDone = values["Done"] as? Bool,
                              let hydro = values["Hydro"] as? String,
                              let parameter = values["Parameter"] as? Double,
                              let set = values["Set"] as? Int,
                              let weight = values["Weight"] as? Int,
                              let Time = values["Time"] as? Int,
                              let imageUrl = values["Url"] as? String else {return}
                        
                        let currentFitness = coachExercise(exerciseName: exerciseName, exerciseType: "Fitness",exercisePart: hydro, sets: set, weight: weight, time: Time, parameter: parameter, imageUrl: imageUrl, isDone: isDone)
                        
                        self.coachExerciseList.append(currentFitness)
                    }else if childSnapshot.childSnapshot(forPath: "Hydro").value as? String == "Aerobic"{
                        guard let isDone = values["Done"] as? Bool,
                              let hydro = values["Hydro"] as? String,
                              let minute = values["Minute"] as? Int,
                              let paramter = values["Parameter"] as? Double,
                              let imageUrl = values["Url"] as? String else{return}
                        
                        let currentFitness = coachExercise(exerciseName: exerciseName, exerciseType: "Fitness", exercisePart: hydro, minute: minute, parameter: paramter, imageUrl: imageUrl, isDone: isDone)
                        self.coachExerciseList.append(currentFitness)
                    }
                }
            }
    }
    
    func fetchAnaerobic(selectedDate:Date){
        ["Back","Chest","Arm","Leg","Shoulder","Abs"]
            .forEach{ part in
                reference
                    .child(trainerId)
                    .child(userId)
                    .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
                    .child("AnAerobic")
                    .child(part)
                    .observeSingleEvent(of: .value) { snapshot in
                        for child in snapshot.children{
                            let childSnapshot = child as! DataSnapshot
                            let exerciseName = childSnapshot.key
                            guard let values = childSnapshot.value as? [String:Any] else{return}
                            
                            guard let isDone = values["Done"] as? Bool,
                                  let minute = values["Minute"] as? Int,
                                  let parameter = values["Parameter"] as? Double,
                                  let set = values["Set"] as? Int,
                                  let time = values["Time"] as? Int,
                                  let imageUrl = values["Url"] as? String,
                                  let weight = values["Weight"] as? Int else{return}
                            
                            let currentExercise = coachExercise(exerciseName: exerciseName, exerciseType: "AnAerobic", exercisePart: part, sets: set, weight: weight, time: time, minute: minute, parameter: parameter, imageUrl: imageUrl, isDone: isDone)
                            
                            self.coachExerciseList.append(currentExercise)
                        }
                    }
            }
    }
    
    func ToggleDone(_ data:coachExercise,selectedDate:Date){
        let updateRef = reference.child(trainerId).child(userId).child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd")).child(data.exerciseType)
        if data.exerciseType == "AnAerobic"{
            if data.exercisePart != nil{
                updateRef
                    .child(data.exercisePart!)
                    .child(data.exerciseName)
                    .updateChildValues(["Done":!data.isDone])
            }
        } else if data.exerciseType == "Aerobic"{
            updateRef
                .child(data.exerciseName)
                .updateChildValues(["Done":!data.isDone])
        } else if data.exerciseType == "Fitness"{
            updateRef
                .child(data.exerciseName)
                .updateChildValues(["Done":!data.isDone])
        }
    }
}
