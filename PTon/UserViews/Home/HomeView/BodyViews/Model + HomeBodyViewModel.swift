//
//  Model + HomeBodyViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/31.
//

import Foundation
import Firebase
import SwiftUI
import Accelerate

//MARK: - MODEL
// In UserBaseInfoViewModel - userBase 모델 사용
enum bodyDataType:String,CaseIterable{
    case weight
    case muscle
    case fat
}
struct elementData{
    var dataType:bodyDataType
    var number:[Double]
}

//MARK: - VIEWMODEL
class HomeBodyViewModel:ObservableObject{
    //MARK: - PROPERTIES
    @Published var userModel:userBase = userBase()
    @Published var bodyDatas:[bodyDataType:[(String,Double)]] = [bodyDataType.weight:[],
                                                     bodyDataType.fat:[],
                                                     bodyDataType.muscle:[]]
    let reference = Firebase.Database.database().reference().child("bodydata")
    
    //MARK: - INITIALIZE
    init(){
        self.Observe()
    }
    
    func Observe(){
        
        guard let userId = Firebase.Auth.auth().currentUser?.uid else{return}
        
        
        reference
            .child(userId)
            .observe(.childAdded) { snapshot in
                let date = snapshot.key
                guard let values = snapshot.value as? [String:Any] else{return}
                bodyDataType.allCases.forEach{
                    guard let value = values[$0.rawValue] as? String else{return}
                    
                    self.bodyDatas[$0]?.append((date,Double(value) ?? 0.0))
                    
                }
            }
        
    }
}
