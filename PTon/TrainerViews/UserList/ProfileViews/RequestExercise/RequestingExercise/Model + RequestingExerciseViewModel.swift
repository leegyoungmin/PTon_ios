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
struct RequestingExercise:Hashable,Codable,Identifiable{
    let id = UUID().uuidString
    var exerciseName:String
    var exerciseHydro:String
    var minute:Int
    var paramter:Double
    var part:String
    var set:Int?
    var time:Int?
    var url:String
    var weight:Int?
    var done:Bool
    
    enum CodingKeys:String,CodingKey{
        case exerciseName
        case exerciseHydro = "hydro"
        case minute
        case paramter
        case part
        case set
        case time
        case url
        case weight
        case done
    }
}
enum exerciseHydro:String{
    case compound
    case AnAerobic
    case Fitness
}

struct TrainerSaveExercise:Hashable{
    let exerciseName:String
    let paramter:Double
    let url:String
    let exerciseHydro:exerciseHydro
    let exercisePart:exercisePart?
}

//MARK: VIEWMODEL
class RequestingExerciseViewModel: ObservableObject {
    @Published var selectedExerciseList:[RequestingExercise] = []
    @Published var ExerciseList:[String:[RequestingExercise]] = [:]
    @Published var trainerSavedExercises:[TrainerSaveExercise] = []
    var sendData:[RequestingExercise] = []
    var userid:String
    var fitnessCode:String
    var selectedDate:String
    let reference = Firestore.firestore()
    
    init(_ userid:String,_ fitnessCode:String,selecteDate:String){
        self.userid = userid
        self.fitnessCode = fitnessCode
        self.selectedDate = selecteDate
        
        
        DispatchQueue.main.async {
            self.readSavedData()
            self.readFitnessExercise()
        }
    }
    
    func readSavedData(){
        guard let trainerId = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        exercisePart.allCases.forEach { exercisePart in
            DispatchQueue.global(qos: .background).async {
                Firestore.firestore().collection("TrainerExerciseList")
                    .document(trainerId)
                    .collection(exercisePart.rawValue)
                    .getDocuments { querySnapshot, err in
                        guard err == nil else{return}
                        print(querySnapshot!.documents)
                        
                        querySnapshot!.documents.forEach { snapshot in
                            let exerciseName = snapshot.documentID
                            let values = snapshot.data()
                            
                            let parameter = values["parameter"] as? Double ?? 0.0
                            let url = values["url"] as? String ?? ""
                            
                            
                            let currentData = TrainerSaveExercise(exerciseName: exerciseName, paramter: parameter, url: url, exerciseHydro: exercisePart.hydro, exercisePart: exercisePart)
                            self.trainerSavedExercises.append(currentData)
                        }
                    }
            }
        }
    }
    
    func readFitnessExercise(){
        Firestore.firestore().collection("FitnessExercise")
            .document(self.fitnessCode)
            .getDocument { snapshot, err in
                guard err == nil,
                      let snapshotValues = snapshot?.data() else{return}
                
                for (key,value) in snapshotValues{
                    print("\(key) :: \(value)")
                    
                    if let values = value as? [String:Any]{
                        let hydro = values["Hydro"] as? String ?? ""
                        let parameter = values["parameter"] as? String
                        let url = values["url"] as? String ?? ""
                        
                        if let parameter = parameter{
                            let currentData = TrainerSaveExercise(exerciseName: key, paramter: Double(parameter) ?? 0, url: url, exerciseHydro: hydro == "Aerobic" ? .compound:.AnAerobic, exercisePart: .Fitness)
                            self.trainerSavedExercises.append(currentData)
                        }
                    }
                }
            }
    }
    
    func updateDataBase(){
        guard let trainerId = Firebase.Auth.auth().currentUser?.uid else{return}
        self.selectedExerciseList.forEach { selectedExercise in
            guard let data = selectedExercise.toDictionary else{return}
            Firebase.Database.database().reference()
                .child("RequestExercise")
                .child(trainerId)
                .child(userid)
                .child(selectedDate)
                .childByAutoId()
                .updateChildValues(data) { err, ref in
                    guard err == nil else{return}
                    
                    self.selectedExerciseList.removeAll()
                }
        }
    }
    
    func minuteEditor(time: Int, sets: Int) -> Int{
        return Int(round(((Double)(time)*(Double)(sets) * 5.0) / 60.0))
    }
}
