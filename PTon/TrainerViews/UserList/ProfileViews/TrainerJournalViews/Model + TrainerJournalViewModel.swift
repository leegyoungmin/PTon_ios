//
//  Model + TrainerJournalViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/04/03.
//

import Foundation
import Firebase
import Combine
import SwiftPrettyPrint

struct TrainerMealRecorded:Codable{
    var carbs:Int
    var fat:Int
    var foodName:String
    var intake:Int
    var kcal:Int
    var protein:Int
    var sodium:Int
    var url:String
}

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

struct TrainerExercise:Hashable{
    let exerciseName:String
    let Hydro:String
    let part:exercisePart?
    let exerciseData:RequestExerciseResult
}

struct TrainerRecordExercise:Hashable,Codable{
    let engName:String
    let exerciseName:String
    let expectKcal:Double
    let hydro:String
    let minute:Int
    let parameter:Double
    let part:String
    let set:String?
    let time:String?
    let url:String
    let weight:String?
}


struct RequestExerciseResult:Hashable,Codable{
    let done:Bool
    let hydro:String?
    let minute:Int
    let parameter:Double
    let set:Int?
    let time:Int?
    let url:String
    let weight:Int?
    
    enum CodingKeys:String,CodingKey{
        case done = "Done"
        case hydro = "Hydro"
        case minute = "Minute"
        case parameter = "Parameter"
        case set = "Set"
        case time = "Time"
        case url = "Url"
        case weight = "Weight"
    }
}


class TrainerJournalViewModel:ObservableObject{
    @Published var currentMonth:Int = 0
    @Published var currentDate = Date()
    @Published var requestExercises:[TrainerExercise] = []
    @Published var recordedExercises:[TrainerRecordExercise] = []
    @Published var meals:[mealType:[TrainerMealRecorded]] = [:]
    @Published var kcal:String = "" {
        didSet{
            print("kcal setting value " + kcal)
        }
    }
    @Published var userWeight:Double = 0
    let decoder = JSONDecoder()
    let trainerId:String
    let userId:String
    let reference = Firebase.Database.database().reference()
    var cancelable = Set<AnyCancellable>()
    
    init(trainerId:String,userId:String){
        self.trainerId = trainerId
        self.userId = userId
        
        self.settingKcal()
        self.settingWeight()
        
        self.$currentDate.sink { [weak self] date in
            self?.meals.removeAll()
            self?.recordedExercises.removeAll()
            self?.requestExercises.removeAll()
            guard let self = self else{return}
            let keyDate = convertString(content: date, dateFormat: "yyyy-MM-dd")
            DispatchQueue.main.async {
                self.updateMealData(keyDate)
                self.updateRequestExercise(keyDate)
                self.updateRecordExercise(keyDate)
            }
            
        }
        .store(in: &cancelable)
    }
    
    func settingKcal(){
        reference
            .child("Ingredient")
            .child(self.userId)
            .child("AllKcal")
            .child("Kcal")
            .observeSingleEvent(of: .value) { snapshot in
                guard let kcal = snapshot.value as? String else{return}
                let intKcal = Int(Double(kcal) ?? 0.0)
                self.kcal = String(intKcal)
            }
    }
    
    func settingWeight(){
        reference
            .child("bodyData")
            .child(self.userId)
            .observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children{
                    let childSnapshot = child as! DataSnapshot
                    guard let values = snapshot.value as? [String:Any] else{return}
                    
                    let weight = values["weight"] as? String ?? "0"
                    let weightConvert = Double(weight) ?? 0.0
                    
                    if weightConvert != 0.0{
                        self.userWeight = weightConvert
                        print("user weight setting \(self.userWeight)")
                    }
                }
            }
    }
    
    func updateMealData(_ selectedDate:String){
        let ref = Firebase.Database.database().reference().child("FoodJournal").child(self.trainerId).child(self.userId).child(selectedDate)
        mealType.allCases.forEach { mealType in
            ref.child(mealType.keyDescription()).observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self,
                      let values = snapshot.value as? [String:Any] else {return}
                let data = try! JSONSerialization.data(withJSONObject: Array(values.values), options: [])
                do{
                    let currentData = try self.decoder.decode([TrainerMealRecorded].self, from: data)
                    self.meals[mealType] = currentData
                } catch let error{
                    print("Error in Read Data ::: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateRequestExercise(_ selectedDate:String){
        DispatchQueue.main.async {
            self.updateAerobic(selectedDate)
            self.updateFitness(selectedDate)
            self.updateAnAerobic(selectedDate)
        }
    }
    
    func updateRecordExercise(_ selectedDate:String){
        DispatchQueue.main.async {
            self.reference
                .child("ExerciseRecord")
                .child(self.userId)
                .child(selectedDate)
                .observeSingleEvent(of: .value) { [weak self] snapshot in
                    guard let self = self,
                          let values = snapshot.value as? [String:Any] else{return}
                    
                    let data = try! JSONSerialization.data(withJSONObject: Array(values.values), options: [])
                    
                    do{
                        let currentData = try self.decoder.decode([TrainerRecordExercise].self, from: data)
                        self.recordedExercises = currentData
                    } catch let err{
                        print("Error in update Record Exercise \(err.localizedDescription)")
                    }
                }
        }
    }
    
    private func updateAerobic(_ selectedDate:String){
        reference.child("RequestExercise").child(self.trainerId).child(self.userId).child(selectedDate).child("Aerobic").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self,
                  let values = snapshot.value as? [String:Any] else{return}
            let exerciseNames = Array(values.keys)
            let data = try! JSONSerialization.data(withJSONObject: Array(values.values), options: [])
            
            do{
                let currentData = try self.decoder.decode([RequestExerciseResult].self, from: data)
                for index in currentData.indices{
                    let trainerData = TrainerExercise(exerciseName: exerciseNames[index], Hydro: "Aerobic", part: exercisePart.Aerobic, exerciseData: currentData[index])
                    self.requestExercises.append(trainerData)
                }
            } catch let err{
                print("Error in update Aerobic ::: \(err.localizedDescription)")
            }
        }
    }
    
    private func updateFitness(_ selectedDate:String){
        reference.child("RequestExercise").child(self.trainerId).child(self.userId).child(selectedDate).child("Fitness").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self,
                  let values = snapshot.value as? [String:Any] else{return}
            
            let exerciseNames = Array(values.keys)
            let data = try! JSONSerialization.data(withJSONObject: Array(values.values), options: [])
            
            do{
                let currentData = try self.decoder.decode([RequestExerciseResult].self, from: data)
                
                for index in currentData.indices{
                    let trainerData = TrainerExercise(exerciseName: exerciseNames[index], Hydro: "Fitness", part: exercisePart.Fitness, exerciseData: currentData[index])
                    self.requestExercises.append(trainerData)
                }
            } catch let err{
                print("Error in update Fitness \(err.localizedDescription)")
            }
        }
    }
    
    private func updateAnAerobic(_ selectedDate:String){
        exercisePart.allCases.forEach { part in
            reference
                .child("RequestExercise")
                .child(self.trainerId)
                .child(self.userId)
                .child(selectedDate)
                .child("AnAerobic")
                .child(part.rawValue)
                .observeSingleEvent(of: .value) { [weak self] snapshot in
                    
                    guard let self = self,
                          let values = snapshot.value as? [String:Any] else{return}
                    let exerciseNames = Array(values.keys)
                    
                    let data = try! JSONSerialization.data(withJSONObject: Array(values.values), options: [])
                    
                    do{
                        let currentData = try self.decoder.decode([RequestExerciseResult].self, from: data)
                        
                        for index in currentData.indices{
                            let trainerData = TrainerExercise(exerciseName: exerciseNames[index], Hydro: "AnAerobic", part: part, exerciseData: currentData[index])
                            self.requestExercises.append(trainerData)
                        }
//                        Pretty.prettyPrint(self.requestExercises)
                    } catch let err{
                        print("Error in update AnAerobic \(err)")
                    }
                }
        }
    }
    
    
    func requestExerciseSuccessRate(_ selectedType:exercisePart)->Double{
        let allData = requestExercises.filter({$0.part == selectedType})
        let value = allData.filter({$0.exerciseData.done == true}).count
        return allData.isEmpty ? 0:Double(value) / Double(allData.count)
    }
    
    func requestExerciseSuccessCount(_ selectedType:exercisePart)->Int{
        let data = requestExercises.filter({$0.part == selectedType})
        return data.filter({$0.exerciseData.done == true}).count
    }
    func requestExerciseAllCount(_ selectedType:exercisePart)->Int{
        return requestExercises.filter({$0.part == selectedType}).count
    }
    
    func recordExerciseCount(_ selectedType:exercisePart)->Int{
        return selectedType == .Aerobic ? recordedExercises.filter({$0.hydro == "Aerobic"}).count:recordedExercises.filter({$0.part == selectedType.rawValue}).count
    }
    
    func filterRequestExercise(_ selectedPart:exercisePart)->[TrainerExercise]{
        return self.requestExercises.filter({$0.part == selectedPart})
    }
    
    func filterRecordExercise(_ selectedPart:exercisePart)->[TrainerRecordExercise]{
        return self.recordedExercises.filter({$0.part == selectedPart.rawValue})
    }
    
    func convertKcal(_ selectedPart:exercisePart)->Int{
        let expectKcal:Double = 0.0
        let recordKcal = self.recordedExercises.filter({$0.part == selectedPart.rawValue}).reduce(expectKcal) { partialResult, exercise in
            return partialResult + exercise.expectKcal
        }
        let requestKcal = self.requestExercises.filter({$0.part == selectedPart}).reduce(recordKcal) { partialResult, exercise in
            return partialResult + exerciseKcal(exercise.exerciseData)
        }
        Pretty.prettyPrint(requestKcal)
        return Int(requestKcal)
    }
    
    private func exerciseKcal(_ exercise:RequestExerciseResult)->Double{
        return ((exercise.parameter * self.userWeight)/30) * Double(calSetting(exercise))
    }
    
    private func calSetting(_ exercise:RequestExerciseResult)->Int{
        guard let set = exercise.set,
              let time = exercise.time else{return exercise.minute}
        return exercise.minute - (set * time * 5)
    }
    //MARK: 유저 소모 칼로리 계산 함수
    /// exercuseParameter : 운동 단위 가중치
    /// settingTime : 운동 시간 - (세트수 * 횟수 * 5) 분 환산
//    func calUserData(_ exerciseParameter:Double,settingTime:Int) -> Double{
//        guard let userWeight = userWeight else {
//            return 0
//        }
//        return ((exerciseParameter * userWeight)/30) * Double(settingTime)
//    }
}
