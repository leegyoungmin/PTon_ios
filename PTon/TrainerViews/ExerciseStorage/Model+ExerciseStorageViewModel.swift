//
//  ExerciseStorageViewModel.swift
//  Salud0.2
//
//  Created by 이관형 on 2022/01/06.
//

import Foundation
import SwiftUI
import UIKit
import Firebase
import FirebaseFirestore

//MARK: MODEL
struct StorageExerciseModel: Hashable{
    let id = UUID().uuidString
    var exerciseName: String
    var parameter: Double
    var exerciseEngName: String
    var exerciseURL: String
    var iscontains:Bool
}

//MARK: VIEWMODEL
class ExerciseStorageViewModel: ObservableObject{
    @Published var StorageList: [StorageExerciseModel] = []
    @Published var alreadyList: [String] = []
    let db = Firestore.firestore()
    var StorageRef : CollectionReference = Firestore.firestore().collection("CommonExercise")
    
    func getAerobicExercise(_ searchData:String,completion:@escaping()->Void){
        StorageList.removeAll(keepingCapacity: true)
        let ref = StorageRef.document("Aerobic").collection("Aerobic")
        
        ref.getDocuments { snapshot, error in
            if let error = error{
                print("Error in get Doc \(error.localizedDescription)")
            }else{
                guard let documents = snapshot?.documents else{return}
                
                for document in documents{
                    if document.documentID.contains(searchData){
                        
                        guard let parameter = document.get("parameter") as? Double,
                              let engname = document.get("EngLabel") as? String,
                              let url = document.get("url") as? String else{return}
                        self.StorageList.append(
                            StorageExerciseModel(exerciseName: document.documentID,
                                                 parameter: parameter,
                                                 exerciseEngName: engname,
                                                 exerciseURL: url,
                                                 iscontains: false)
                        )
                    }
                }
            }
            completion()
            self.checkData("Aerobic")
        }
    }
    
    func getAnaerobicExercise(_ part:String,_ searchData:String,completion:@escaping()->Void){
        StorageList.removeAll(keepingCapacity: true)
        let ref = StorageRef.document("Anaerobic").collection(part)
        print(searchData)
        
        ref.getDocuments(){ (snapshot, error) in
            if let error = error{
                print("Error \(error)")
            }else{
                for documents in snapshot!.documents{
                    if documents.documentID.contains(searchData){
                        print("\(documents.documentID) ==> \(documents.data())")
                        
                        let model = StorageExerciseModel(
                            exerciseName: documents.documentID,
                            parameter: documents.get("parameter")! as! Double,
                            exerciseEngName: documents.get("EngLabel")! as! String,
                            exerciseURL: documents.get("url")! as! String,
                            iscontains: false)
                        self.StorageList.append(model)
                    }
                }
            }
            completion()
            self.checkData(part)
        }
    }
    
    func checkData(_ partName:String){
        guard let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        for (index,item) in StorageList.enumerated(){
            let ref = Firestore.firestore().collection("TrainerExerciseList").document(trainerid).collection(partName).document(item.exerciseName)
            ref.getDocument { snapshot, error in
                if let error = error{
                    print("Check Data Error \(error)")
                }else{
                    guard let values = snapshot?.exists else{return}
                    if values{
                        self.StorageList[index].iscontains = true
                    }
                }
            }
        }
    }
    
    func getAlreadyStoredList(part: String, uid: String){
        StorageRef = db.collection("TrainerExerciseList").document(uid).collection(part)
        print("Functioned getAlreadyStoredList")
        StorageRef.getDocuments(){ (querySnapshot, error) in
            if let error = error{
                print("Error getting Document in getAlreadyStorageList() \(error)")
            }else{
                for document in querySnapshot!.documents{
                    self.alreadyList.append(document.documentID)
                }
                print("self.alreadyList.append  == \(self.alreadyList)")
            }
        }
    }
    
    func setExerciseStorage(part: String, item: StorageExerciseModel,completion:@escaping()->Void){
        guard let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        let ref = db.collection("TrainerExerciseList").document(trainerid).collection(part)
        let fieldData = [
            "parameter": item.parameter,
            "url": item.exerciseURL
        ] as [String : Any]
        
        ref.document(item.exerciseName).setData(fieldData){ error in
            if let error = error{
                print("Error writing document: \(error)")
            }else{
                print("Document successfully written!")
                completion()
            }
        }
    }
    
    
    func deleteExistingExercise(_ part: String, _ exerciseName: String,completion:@escaping()->Void){
        
        guard let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        StorageRef = db.collection("TrainerExerciseList").document(trainerid).collection(part)
        StorageRef.document(exerciseName)
            .delete(){ error in
                if let error = error{
                    print("Error removing document: \(error)")
                }else{
                    print("Delete Document Successfully: \(exerciseName)")
                    completion()
                }
            }
    }
    
}
