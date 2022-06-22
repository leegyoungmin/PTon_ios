//
//  RequestedExerciseViewModel.swift
//  Salud0.2
//
//  Created by 이관형 on 2022/01/23.
//

import Foundation
import Firebase
import SwiftUI
import Combine
import SwiftPrettyPrint

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
    @Published var exercises:[RequestingExercise] = []
    @Published var selectedDate:Date = Date()
    let reference = Firebase.Database.database().reference().child("RequestExercise")
    private var cancellables:Set<AnyCancellable> = []
    var userid:String
    
    init(_ userid:String){
        self.userid = userid
        
        $selectedDate.sink { selectedDate in
            self.exercises.removeAll()
            let seletedString = convertString(content: selectedDate, dateFormat: "yyyy-MM-dd")
            print(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            self.readRequestedExercise(seletedString)
        }
        .store(in: &cancellables)
    }
    func readRequestedExercise(_ dateString:String){
        guard let trainerId = Firebase.Auth.auth().currentUser?.uid else{return}
        
        reference
            .child(trainerId)
            .child(userid)
            .child(dateString)
            .observe(.childAdded) { [weak self] snapshot in
                guard let self = self,
                      let values = snapshot.value as? [String:Any] else{return}
                
                let data = try! JSONSerialization.data(withJSONObject: values, options: [])
                let decoder = JSONDecoder()
                let requestExercise = try? decoder.decode(RequestingExercise.self, from: data)
                
                if let exercise = requestExercise{
                    self.exercises.append(exercise)
                }
            }
        
        reference
            .child(trainerId)
            .child(userid)
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .observe(.childRemoved) { [weak self] snapshot in
                guard let self = self,
                      let values = snapshot.value as? [String:Any] else{return}
                
                if let exerciseName = values["exerciseName"] as? String{
                    guard let index = self.exercises.firstIndex(where: {$0.exerciseName == exerciseName}) else{return}
                    
                    self.exercises.remove(at: index)
                }
            }
        
        reference
            .child(trainerId)
            .child(userid)
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .observe(.childChanged) { [weak self] snapshot in
                guard let self = self,
                      let value = snapshot.value as? [String:Any] else{return}
                
                if let exerciseName = value["exerciseName"] as? String{
                    let data = try! JSONSerialization.data(withJSONObject: value, options: [])
                    let decoder = JSONDecoder()
                    let requestExercise = try? decoder.decode(RequestingExercise.self, from: data)
                    guard let index = self.exercises.firstIndex(where: {$0.exerciseName == exerciseName}),
                          let exercise = requestExercise else{return}
                    
                    
                    
                    self.exercises[index] = exercise
                }
            }
    }
    
    func removeData(exercise:RequestingExercise){
        guard let trainerId = Firebase.Auth.auth().currentUser?.uid else{return}
        
        reference
            .child(trainerId)
            .child(self.userid)
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .observeSingleEvent(of: .value) { snapshot in
                snapshot.children.forEach { child in
                    let childSnapshot = child as! DataSnapshot
                    
                    if childSnapshot.childSnapshot(forPath: "exerciseName").value as? String == exercise.exerciseName{
                        childSnapshot.ref.removeValue()
                        
                        return
                    }
                }
            }
    }
    
    
    func modifyElementExercise(_ exercise:RequestingExercise){
        guard let trainerId = Firebase.Auth.auth().currentUser?.uid else{return}
        
        reference
            .child(trainerId)
            .child(userid)
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .observeSingleEvent(of: .value) { snapshot in
                snapshot.children.forEach { child in
                    let childSnapshot = child as! DataSnapshot
                    
                    if childSnapshot.childSnapshot(forPath: "exerciseName").value as? String == exercise.exerciseName,
                       let exerciseData = exercise.toDictionary{
                        childSnapshot.ref.updateChildValues(exerciseData)
                    }
                }
            }
    }
    
    func minuteEditor(time: Int, sets: Int) -> Int{
        return Int(round(((Double)(time)*(Double)(sets) * 5.0) / 60.0))
    }
}



