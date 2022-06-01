//
//  userExerciseSearchViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/06/01.
//

import Foundation

class userExerciseSearchViewModel:ObservableObject{
    @Published var selectedItem:[exerciseResult]?
    let userId:String
    let fitnessCode:String
    
    init(userId:String,fitnessCode:String){
        self.userId = userId
        self.fitnessCode = fitnessCode
    }
}
