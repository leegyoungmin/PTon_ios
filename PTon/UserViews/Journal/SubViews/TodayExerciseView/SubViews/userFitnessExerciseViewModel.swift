//
//  userFitnessExerciseViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/06/03.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


class userFitnessExerciseViewModel:ObservableObject{
    @Published var exerciseList:[exerciseResult] = []
    
    let userId:String
    let fitnessCode:String
    
    init(userId:String,fitnessCode:String){
        self.userId = userId
        self.fitnessCode = fitnessCode
        
        observeData()
    }
    
    func observeData(){
        Firestore.firestore()
            .collection("FitnessExercise")
            .document(self.fitnessCode)
            .addSnapshotListener { snapshot, err in
                let data = snapshot.map{ query -> [String:Any] in
                    let data = query.data()
                    return data!
                }
                
                data?.forEach{ key, value in
                    let name = key
                    guard let values = value as? [String:Any] else{return}
                    
                    let type = values["Hydro"] as? String ?? ""
                    let parameter = values["parameter"] as? String ?? ""
                    let url = values["url"] as? String ?? ""
                    
                    self.exerciseList.append(exerciseResult(exerciseName: name, part: "Fitness", hydro: type, engName: name, parameter: Double(parameter) ?? 0, url: url))
                }
            }
    }
}
