////
////  Model + MealRecordViewModel.swift
////  PTon
////
////  Created by 이경민 on 2022/03/24.
////

import Foundation
import Firebase

struct userMeal:Hashable{
    var mealtype:mealType
    var uuid:String
    var name:String
    var url:String

}

class MealRecordViewModel:ObservableObject{
    @Published var recordedMeals:[userMeal] = []
    let userId:String,trainerId:String,fitnessCode:String
    
    init(userId:String,trainerId:String,fitnessCode:String){
        self.userId = userId
        self.trainerId = trainerId
        self.fitnessCode = fitnessCode
    }
    
}
