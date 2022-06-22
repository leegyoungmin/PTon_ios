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
import Combine


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
    @Published var selectedDate = Date()
    @Published var coachExerciseList:[RequestingExercise] = []
    let trainerId:String
    let userId:String
    var userWeight:Double = 0
    let reference = Firebase.Database.database().reference().child("RequestExercise")
    private var cancelable = Set<AnyCancellable>()
    
    init(_ trainerId:String,_ userId:String){
        self.trainerId = trainerId
        self.userId = userId
        
        getUserWeight()
        
        $selectedDate.sink { date in
            self.coachExerciseList.removeAll()
            let dateString = convertString(content: date, dateFormat: "yyyy-MM-dd")
            self.observeData(dateString)
        }
        .store(in: &cancelable)
    }
    
    func observeData(_ selectedDate:String){
        reference
            .child(self.trainerId)
            .child(self.userId)
            .child(selectedDate)
            .observe(.childAdded) { [weak self] snapshot in
                guard let self = self,
                      let values = snapshot.value as? [String:Any] else{return}
                
                let data = try! JSONSerialization.data(withJSONObject: values, options: [])
                let decoder = JSONDecoder()
                let decodedData = try? decoder.decode(RequestingExercise.self, from: data)
                
                if let data = decodedData{
                    self.coachExerciseList.append(data)
                }
            }
        
        reference
            .child(self.trainerId)
            .child(self.userId)
            .child(selectedDate)
            .observe(.childChanged) { [weak self] snapshot in
                guard let self = self,
                      let values = snapshot.value as? [String:Any] else{return}
                
                let data = try! JSONSerialization.data(withJSONObject: values, options: [])
                let decoder = JSONDecoder()
                let decodedData = try? decoder.decode(RequestingExercise.self, from: data)
                
                if let data = decodedData{
                    guard let index = self.coachExerciseList.firstIndex(where: {$0.exerciseName == data.exerciseName}) else{return}
                    self.coachExerciseList[index] = data
                }
            }
    }
    
    
    func ToggleDone(_ data:RequestingExercise){
        reference
            .child(self.trainerId)
            .child(self.userId)
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .observeSingleEvent(of: .value) { snapshot in
                snapshot.children.forEach { child in
                    let childSnapshot = child as! DataSnapshot
                    if childSnapshot.childSnapshot(forPath: "exerciseName").value as? String == data.exerciseName{
                        childSnapshot.childSnapshot(forPath: "done").ref.setValue(true)
                    }
                }
            }
    }
    
    func getUserWeight(){
        Firebase.Database.database().reference()
            .child("bodydata")
            .child(self.userId)
            .observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self else{return}
                
                snapshot.children.forEach { child in
                    let childSnapshot = child as! DataSnapshot
                    
                    if childSnapshot.childSnapshot(forPath: "weight").value as? String != "0"{
                        let weight = Double(childSnapshot.childSnapshot(forPath: "weight").value as! String) ?? 0.0
                        
                        self.userWeight = weight
                    }
                }
            }
    }
    
    
    func exerciseKcal(_ exercise:RequestingExercise)->Int{
        return Int(((exercise.paramter * self.userWeight)/30) * Double(calSetting(exercise)))
    }
    
    func calSetting(_ exercise:RequestingExercise)->Int{
        guard let set = exercise.set,
              let time = exercise.time else{return exercise.minute}
        return exercise.minute - (set * time * 5)
    }
}
