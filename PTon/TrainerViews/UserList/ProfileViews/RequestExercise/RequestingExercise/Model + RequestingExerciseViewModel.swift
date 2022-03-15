//
//  RequestingExerciseViewModel.swift
//  Salud0.2
//
//  Created by 이관형 on 2021/12/08.
//

import Foundation
import SwiftUI
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

//MARK: MODEL
struct RequestingExercise:Hashable,Identifiable{
    let id = UUID().uuidString
    var name:String
    var type:String
    var paramter:String
    var url:String
    var part:String?
    var isContain:Bool = false
    var minute:Int?
    var set:Int?
    var time:Int?
    var weight:Int?
}

//MARK: VIEWMODEL
class RequestingExerciseViewModel: ObservableObject {
    @Published var ExerciseList:[String:[RequestingExercise]] = [:]
    var sendData:[RequestingExercise] = []
    var userid:String
    var fitnessCode:String
    var selectedDate:String
    let reference = Firestore.firestore()
    
    init(_ userid:String,_ fitnessCode:String,selecteDate:String){
        self.userid = userid
        self.fitnessCode = fitnessCode
        self.selectedDate = selecteDate
        
        fetchData(tasks: [fetchFitnessData,fetchTrainerData])
    }
    
    func fetchData(tasks:[()->Void]){
        for task in tasks {
            task()
        }
    }
    
    func fetchFitnessData(){
        reference
            .collection("FitnessExercise")
            .document(fitnessCode)
            .addSnapshotListener { snapshot, error in
                
                let data = snapshot.map { queryDocumentSnapshot -> [String:Any] in
                    let data = queryDocumentSnapshot.data()
                    return data!
                }
                
                var datalist:[RequestingExercise] = []
                
                data?.forEach({ key,value in
                    let name = key
                    
                    guard let values = value as? [String:Any] else{return}
                    
                    let type = values["Hydro"] as? String ?? ""
                    let parameter = values["parameter"] as? String ?? ""
                    let url = values["url"] as? String ?? ""
                    
                    datalist.append(
                        RequestingExercise(name: name, type: type, paramter: parameter, url: url, part: "Fitness")
                    )
                })
                
                self.ExerciseList["Fitness"] = datalist
                self.fetchExerciseContain()
            }
    }
    
    func fetchTrainerData(){
        let typeList:[String] = ["Aerobic","Back","Chest","Abs","Arm","Leg","Shoulder","Compound"]
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        self.ExerciseList["AnAerobic"] = []
        
        typeList.forEach { part in
            reference
                .collection("TrainerExerciseList")
                .document(trainerid)
                .collection(part)
                .addSnapshotListener { snapshot, error in
                    guard let documents = snapshot?.documents else{return}
                    
                    if part == "Aerobic"{
                        self.ExerciseList["Aerobic"] = documents.map{ queryDocumentSnapshot -> RequestingExercise in
                            let values = queryDocumentSnapshot.data()
                            let name = queryDocumentSnapshot.documentID
                            let parameter = values["parameter"] as? Double ?? 0.0
                            let url = values["url"] as? String ?? ""
                            
                            return RequestingExercise(name: name,
                                                      type: "Aerobic",
                                                      paramter: parameter.description,
                                                      url: url)
                        }
                    }else{
                        documents.forEach { document in
                            let name = document.documentID
                            let data = document.data()
                            
                            let parameter = data["parameter"] as? Double ?? 0.0
                            let url = data["url"] as? String ?? ""
                            
                            let currentExercise = RequestingExercise(name: name,
                                                      type: "AnAerobic",
                                                      paramter: parameter.description,
                                                      url: url,
                                                      part: part)
                            
                            self.ExerciseList["AnAerobic"]!.append(currentExercise)
                        }
                    }
                    self.fetchExerciseContain()
                    
                }
        }
        
    }
    
    func fetchExerciseContain(){
        self.ExerciseList.keys.forEach { type in
            if type == "Fitness"{
                isContainFitness()
            }else if type == "Aerobic"{
                isContainAerobic()
            }else{
                isContainAnAerobic()
            }
        }
    }
    
    
    func isContainFitness(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        
        let databaseRef = Firebase.Database.database().reference().child("RequestExercise").child(trainerid).child(userid).child(selectedDate)
        
        databaseRef
            .child("Fitness")
            .observeSingleEvent(of: .value) { snapshot in
                guard var data = self.ExerciseList["Fitness"] else{return}
                
                for (index,_) in data.enumerated(){
                    data[index].isContain = (snapshot.hasChild(data[index].name))
                }
                self.ExerciseList["Fitness"] = data
                self.fetchExerciseInfoData()
            }
        
        
    }
    
    func isContainAerobic(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        
        let databaseRef = Firebase.Database.database().reference().child("RequestExercise").child(trainerid).child(userid).child(selectedDate)
        
        databaseRef
            .child("Aerobic")
            .observeSingleEvent(of: .value) { snapshot in
                guard var data = self.ExerciseList["Aerobic"] else{return}
                
                for (index,_) in data.enumerated(){
                    data[index].isContain = (snapshot.hasChild(data[index].name))
                }
                
                self.ExerciseList["Aerobic"] = data
                self.fetchExerciseInfoData()
            }
    }
    
    func isContainAnAerobic(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        
        let databaseRef = Firebase.Database.database().reference().child("RequestExercise").child(trainerid).child(userid).child(selectedDate)
        
        guard var data = self.ExerciseList["AnAerobic"] else{return}

        for (index,exercise) in data.enumerated(){
            databaseRef
                .child("AnAerobic")
                .child(exercise.part!)
                .observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists(){
                        data[index].isContain = snapshot.hasChild(exercise.name)
                        self.ExerciseList["AnAerobic"] = data
                    }
                    
                    
                    self.fetchExerciseInfoData()
                }
        }
    }
    
    
    func fetchExerciseInfoData(){
        self.ExerciseList.keys.forEach { type in
            if type == "Fitness"{
                fetchFitnessInfo()
            }else if type == "Aerobic"{
                fetchAerobicInfo()
            }else{
                fetchAnAerobicInfo()
            }
        }
    }
    
    func fetchFitnessInfo(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        let databaseRef = Firebase.Database.database().reference().child("RequestExercise").child(trainerid).child(userid).child(selectedDate).child("Fitness")
        guard var data = self.ExerciseList["Fitness"] else {return}
        
        for (index,exercise) in data.enumerated(){
            if data[index].isContain{
                databaseRef
                    .child(exercise.name)
                    .observeSingleEvent(of: .value) { snapshot in
                        guard let values = snapshot.value as? [String:Any] else{return}
                        
                        if exercise.type == "AnAerobic"{
                            guard let isDone = values["Done"] as? Bool,
                                  let minute = values["Minute"] as? Int,
                                  let weight = values["Weight"] as? Int,
                                  let sets = values["Set"] as? Int,
                                  let time = values["Time"] as? Int else{return}
                            
                            
                            data[index].minute = minute
                            data[index].weight = weight
                            data[index].set = sets
                            data[index].time = time
                            
                            self.ExerciseList["Fitness"] = data
                        }else{
                            guard let isDone = values["Done"] as? Bool,
                                  let minute = values["Minute"] as? Int else{return}
                            
                            data[index].minute = minute
                            
                            self.ExerciseList["Fitness"] = data
                        }
                    }
            }
        }
    }
    
    func fetchAerobicInfo(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        let databaseRef = Firebase.Database.database().reference().child("RequestExercise").child(trainerid).child(userid).child(selectedDate).child("Aerobic")
        guard var data = self.ExerciseList["Aerobic"] else {return}
        
        for (index,exercise) in data.enumerated(){
            if data[index].isContain{
                databaseRef
                    .child(exercise.name)
                    .observeSingleEvent(of: .value) { snapshot in
                        
                        guard let values = snapshot.value as? [String:Any] else{return}
                        
                        guard let isDone = values["Done"] as? Bool,
                              let minute = values["Minute"] as? Int else{return}
                        
                        data[index].minute = minute
                        
                        self.ExerciseList["Aerobic"] = data
                    }
            }
        }
    }
    
    func fetchAnAerobicInfo(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        let databaseRef = Firebase.Database.database().reference().child("RequestExercise").child(trainerid).child(userid).child(selectedDate).child("AnAerobic")
        guard var data = self.ExerciseList["AnAerobic"] else {return}
        
        for (index,exercise) in data.enumerated(){
            if exercise.isContain{
                databaseRef
                    .child(exercise.part!)
                    .child(exercise.name)
                    .observeSingleEvent(of: .value) { snapshot in
                        if snapshot.exists(){
                            guard let values = snapshot.value as? [String:Any] else{return}
                            
                            guard let isDone = values["Done"] as? Bool,
                                  let minute = values["Minute"] as? Int,
                                  let weight = values["Weight"] as? Int,
                                  let sets = values["Set"] as? Int,
                                  let time = values["Time"] as? Int else{return}
                            
                            
                            data[index].minute = minute
                            data[index].weight = weight
                            data[index].set = sets
                            data[index].time = time
                            
                            self.ExerciseList["AnAerobic"] = data
                        }
                    }
            }

        }
        
    }
    
    func setExerciseData(data:RequestingExercise,set:String,weight:String,time:String,minute:String){
        var data = data
        data.isContain = true

        print(minute)

        if minute != ""{
            if data.part != "Fitness"{
                data.part = "Aerobic"
            }

            data.minute = Int(minute)
        }else{
            data.set = Int(set)
            data.weight = Int(weight)
            data.time = Int(time)

            guard let time = data.time,
                  let set = data.set else{return}

            data.minute = minuteEditor(time: time, sets: set)
        }
        sendData.append(data)

        print(sendData)
    }

    func setData(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        let databaseref = Firebase.Database.database().reference()
            .child("RequestExercise")
            .child(trainerid)
            .child(userid)
            .child(selectedDate)

        sendData.forEach{
            var data:[String:Any?] = [
                "Done":false,
                "Hydro":$0.type,
                "Minute":$0.minute ?? nil,
                "Parameter":Double($0.paramter) ?? nil,
                "Set":$0.set ?? nil,
                "Time":$0.time ?? nil,
                "Url":$0.url,
                "Weight":$0.weight ?? nil
            ]
            
            if $0.part == "Fitness"{
                databaseref
                    .child($0.part!)
                    .child($0.name)
                    .setValue(data)
            }else {
                if $0.type == "AnAerobic"{
                    data["Hydro"] = nil
                    databaseref
                        .child($0.type)
                        .child($0.part!)
                        .child($0.name)
                        .setValue(data)
                }else{
                    databaseref
                        .child($0.type)
                        .child($0.name)
                        .setValue(data)
                }
            }

        }


    }

    func minuteEditor(time: Int, sets: Int) -> Int{
        return Int(round(((Double)(time)*(Double)(sets) * 5.0) / 60.0))
    }
    
}





