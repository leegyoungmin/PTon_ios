//
//  Model + TrainerJournalViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/04/03.
//

import Foundation
import Firebase


class TrainerJournalViewModel:ObservableObject{
    @Published var exercises:[todayExercise] = []
    @Published var meals:[userMeal] = []
    let trainerId:String
    let userId:String
    let reference = Firebase.Database.database().reference()
    
    init(trainerId:String,userId:String){
        self.trainerId = trainerId
        self.userId = userId
        
        self.ObserveData(Date())
    }
    
    
    func ObserveData(_ selectedDate:Date){
        self.exercises.removeAll(keepingCapacity: true)
        self.meals.removeAll(keepingCapacity: true)
        reference
            .child("FoodPhoto")
            .child(trainerId)
            .child(userId)
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children{
                    let childSnap = child as! DataSnapshot
                    let mealType = childSnap.key
                    
                    for child in childSnap.children{
                        let childSnap = child as! DataSnapshot
                        let uuid = childSnap.key
                        guard let values = childSnap.value as? [String:Any] else{return}
                        
                        guard let foodName = values["foodName"] as? String,
                              let photoUrl = values["url"] as? String else{return}
                        
                        
                        if mealType == "breakfirst"{
                            let currentMeal = userMeal(mealtype: .first, uuid: uuid, name: foodName, url: photoUrl)
                            self.meals.append(currentMeal)
                        }
                        
                        if mealType == "launch"{
                            let currentMeal = userMeal(mealtype: .second, uuid: uuid, name: foodName, url: photoUrl)
                            self.meals.append(currentMeal)
                        }
                        
                        if mealType == "snack"{
                            let currentMeal = userMeal(mealtype: .snack, uuid: uuid, name: foodName, url: photoUrl)
                            self.meals.append(currentMeal)
                        }
                        
                        if mealType == "dinner"{
                            let currentMeal = userMeal(mealtype: .third, uuid: uuid, name: foodName, url: photoUrl)
                            self.meals.append(currentMeal)
                        }
                    }
                }
            }
        
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
                        self.exercises.append(currentExercise)
                        
                    }else if exercisePart == "AnAerobic"{
                        guard let minute = values["Minute"] as? String,
                              let part = values["Part"] as? String,
                              let set = values["Sets"] as? String,
                              let time = values["Time"] as? String,
                              let weight = values["Weight"] as? String else{return}
                        
                        let currentExercise = todayExercise(uuid: uuid, exerciseName: exerciseName, hydro: exercisePart,minute: minute, time: time, part: part, sets: set, weight: weight)
                        self.exercises.append(currentExercise)
                    }
                }
            }
    }
}
