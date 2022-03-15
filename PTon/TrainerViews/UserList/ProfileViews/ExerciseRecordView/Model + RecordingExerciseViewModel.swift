//
//  RecordingExerciseViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/13.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

//MARK: MODEL
struct RecordingExercise:Hashable{
    var uuid:String?
    var exerciseName:String?
    var number:String?
    var set:String?
    var weight:String?
}

//MARK: VIEWMODEL
class RecordingExerciseViewModel:ObservableObject{
    @Published var ExerciseList:[RecordingExercise] = []
    @Published var selectedDay = Date()
    @Published var inputExercise:String = ""
    @Published var inputWeight:String = ""
    @Published var inputNumber:String = ""
    @Published var inputSet:String = ""
    
    let reference = FirebaseDatabase.Database.database().reference()
    
    var trainerid:String
    var userid:String
    
    init(trainerid:String,userid:String){
        self.trainerid = trainerid
        self.userid = userid
        fetchData()
    }
    
    func fetchData(){
        reference
            .child("Ptrecord")
            .child(self.trainerid)
            .child(self.userid)
            .child(convertDateToString(selectedDay))
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists(){
                    for child in snapshot.children{
                        let values = child as! DataSnapshot
                        let key = values.key
                        guard let value = values.value as? [String:Any] else{return}
                        
                        guard let exercise = value["exercise"] as? String,
                              let number = value["number"] as? String,
                              let set = value["set"] as? String,
                              let weight = value["weight"] as? String else{return}
                        
                        self.ExerciseList.append(RecordingExercise(uuid: key, exerciseName: exercise, number: number, set: set, weight: weight))
                    }
                }
            }
    }
    
    func setData(){
        let values = [
            "exercise":inputExercise,
            "number":inputNumber,
            "set":inputSet,
            "weight":inputWeight
        ]
        
        reference
            .child("Ptrecord")
            .child(self.trainerid)
            .child(self.userid)
            .child(convertDateToString(selectedDay))
            .childByAutoId()
            .setValue(values) { error, reference in
                if error == nil{
                    self.ExerciseList.removeAll(keepingCapacity: true)
                    self.fetchData()
                }
            }
    }
    func removeData(_ uuid:String){
        reference
            .child("Ptrecord")
            .child(self.trainerid)
            .child(self.userid)
            .child(convertDateToString(selectedDay))
            .child(uuid)
            .removeValue { error, reference in
                if error == nil{
                    self.ExerciseList.removeAll(keepingCapacity: true)
                    self.fetchData()
                }
            }
    }

}

extension RecordingExerciseViewModel{
    func convertDateToString(_ date:Date)->String{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        dateformatter.locale = Locale(identifier: "ko_KR")
        return dateformatter.string(from: date)
    }
}
