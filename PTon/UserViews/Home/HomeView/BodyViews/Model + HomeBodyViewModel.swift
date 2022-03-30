//
//  Model + HomeBodyViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/31.
//

import Foundation
import Firebase

//MARK: - MODEL
// In UserBaseInfoViewModel - userBase 모델 사용

//MARK: - VIEWMODEL
class HomeBodyViewModel:ObservableObject{
    //MARK: - PROPERTIES
    @Published var userModel:userBase = userBase()
    let reference = Firebase.Database.database().reference().child("bodydata")
    
    //MARK: - INITIALIZE
    init(){
        Observe()
    }
    
    func Observe(){
        
        guard let userId = Firebase.Auth.auth().currentUser?.uid else{return}
        
        reference
            .child(userId)
            .child(convertString(content: Date(), dateFormat: "yyyy-MM-dd"))
            .observe(.value) { snapshot in
                if snapshot.exists(){
                    if snapshot.childSnapshot(forPath: "fat").exists(){
                        self.userModel.bodyFat = snapshot.childSnapshot(forPath: "fat").value as? String
                    }
                    
                    if snapshot.childSnapshot(forPath: "muscle").exists(){
                        self.userModel.bodyMuscle = snapshot.childSnapshot(forPath: "muscle").value as? String
                    }
                    
                    if snapshot.childSnapshot(forPath: "weight").exists(){
                        self.userModel.bodyMuscle = snapshot.childSnapshot(forPath: "weight").value as? String
                    }
                }else {
                    print("Not Exist Home Body View Model")
                }
            }
    }
}
