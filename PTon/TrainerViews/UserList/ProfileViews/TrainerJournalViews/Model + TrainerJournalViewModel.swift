//
//  Model + TrainerJournalViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/04/03.
//

import Foundation
import Firebase

struct todayExercise:Hashable{
    var uuid:String
    var exerciseName:String
    var hydro:String
    var hour:String?
    var minute:String
    var time:String
    var part:String?
    var sets:String?
    var weight:String?
}


struct RequestExerciseResult:Hashable{
    let exerciseName:String
    let exercisePart:exercisePart
    let hydro:String
    let done:Bool
    let minute:Int
    let parameter:Double
    let set:Int?
    let time:Int?
    let url:String
    let weight:Int?
}


class TrainerJournalViewModel:ObservableObject{
    @Published var currentMonth:Int = 0
    @Published var currentDate = Date()
    @Published var requestExercises:[String:[RequestExerciseResult]] = [:]
    @Published var recordedExercises:[String:[RequestExerciseResult]] = [:]
    @Published var meals:[userFoodResult] = []
    let trainerId:String
    let userId:String
    let reference = Firebase.Database.database().reference()
    
    init(trainerId:String,userId:String){
        self.trainerId = trainerId
        self.userId = userId
        
        self.ObserveData()
    }
    
    func ObserveData(){
        let mealref = Firebase.Database.database().reference().child("FoodJournal").child(self.trainerId).child(self.userId).child(convertString(content: currentDate, dateFormat: "yyyy-MM-dd"))
        let requestExerciseRef = Firebase.Database.database().reference().child("RequestExercise").child(self.trainerId).child(self.userId).child(convertString(content: currentDate, dateFormat: "yyyy-MM-dd"))
        self.meals.removeAll()
        self.exercises.removeAll()
        
        
        mealType.allCases.forEach{ type in
            mealref.child(type.keyDescription()).observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self else{return}
                for child in snapshot.children{
                    let childSnapshot = child as! DataSnapshot
                    let key = childSnapshot.key
                    guard let values = childSnapshot.value as? [String:Any] else{return}
                    
                    let carbs = values["carbs"] as? Int ?? 0
                    let fat = values["fat"] as? Int ?? 0
                    let foodName = values["foodName"] as? String ?? ""
                    let intake = values["intake"] as? Int ?? 0
                    let kcal = values["kcal"] as? Int ?? 0
                    let protein = values["protein"] as? Int ?? 0
                    let sodium = values["sodium"] as? Int ?? 0
                    let url = values["url"] as? String ?? ""
                    
                    let data = userFoodResult(id: key,
                                              mealType: type,
                                              carbs: carbs,
                                              fat: fat,
                                              foodName: foodName,
                                              intake: intake,
                                              kcal: kcal,
                                              protein: protein,
                                              sodium: sodium,
                                              url: url)
                    
                    self.meals.append(data)
                }
            }
        }
        
        ["Aerobic","AnAerobic","Fitness"].forEach { type in
            requestExerciseRef.child(type).observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self else{return}
                if type == "Aerobic" || type == "Fitness"{
                    self.AerobicItem(type,snapshot)
                }else{
                    self.AnAerobicItem(snapshot)
                }
            }
        }
    }
    
    func AerobicItem(_ key:String,_ snapshot:DataSnapshot){
        
        snapshot.children.forEach{
            let childSnapshot = $0 as! DataSnapshot
            let exerciseName = childSnapshot.key
            guard let values = childSnapshot.value as? [String:Any] else{return}
            
            let exercisePart:exercisePart = exercisePart.init(rawValue: key) ?? .Fitness
            let done = values["Done"] as? Bool ?? false
            let hydro = values["Hydro"] as? String ?? ""
            let parameter = values["Parameter"] as? Double ?? 0.0
            let minute = values["Minute"] as? Int ?? 0
            let set = values["Set"] as? Int ?? 0
            let time = values["Time"] as? Int ?? 0
            let url = values["Url"] as? String ?? ""
            let weight = values["Weight"] as? Int ?? 0
            
            let data = RequestExerciseResult(exerciseName: exerciseName,
                                             exercisePart: exercisePart,
                                             hydro: hydro,
                                             done: done,
                                             minute: minute,
                                             parameter: parameter,
                                             set: set,
                                             time: time,
                                             url: url,
                                             weight: weight)
            
            if self.requestExercises[exercisePart.description] == nil{
                self.requestExercises[exercisePart.description] = [data]
            }else{
                self.requestExercises[exercisePart.description]!.append(data)
            }
        }
    }
    
    func AnAerobicItem(_ snapshot:DataSnapshot){
        snapshot.children.forEach{
            let childSnapshot = $0 as! DataSnapshot
            print(childSnapshot)
            let exercisePart:exercisePart? = exercisePart.init(rawValue: childSnapshot.key)
            guard let exercisePart = exercisePart else{return}
            childSnapshot.children.forEach{
                let elementSnapshot = $0 as! DataSnapshot
                
                let exerciseName = elementSnapshot.key
                guard let values = elementSnapshot.value as? [String:Any] else{return}
                let done = values["Done"] as? Bool ?? false
                let minute = values["Minute"] as? Int ?? 0
                let parameter = values["Parameter"] as? Double ?? 0.0
                let set = values["Set"] as? Int ?? 0
                let time = values["Time"] as? Int ?? 0
                let url = values["Url"] as? String ?? ""
                let weight = values[""] as? Int ?? 0
                
                let currentData = RequestExerciseResult(exerciseName: exerciseName,
                                                        exercisePart: exercisePart,
                                                        hydro: "AnAerobic",
                                                        done: done,
                                                        minute: minute,
                                                        parameter: parameter,
                                                        set: set,
                                                        time: time,
                                                        url: url,
                                                        weight: weight)
                
                
                if self.requestExercises[exercisePart.description] == nil{
                    self.requestExercises[exercisePart.description] = [currentData]
                }else{
                    self.requestExercises[exercisePart.description]!.append(currentData)
                }
            }
        }
    }
}
