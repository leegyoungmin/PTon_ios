//
//  Model + MemoCreateViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/15.
//

import Foundation
import Firebase



struct memo{
    var isprivate:Bool = false
    var title:String
    var content:String
    var meal:[meal]?
}

struct meal{
    var mealType:mealType?
    var foodList:[String]?
}


class MemoCreateViewModel:ObservableObject{
    @Published var meals:[meal] = [
        meal(mealType: .first, foodList: []),
        meal(mealType: .second, foodList: []),
        meal(mealType: .third, foodList: [])
    ]
    
    var userid:String
    let reference = Firebase.Database.database().reference()
    init(userid:String){
        self.userid = userid
    }
    
    func fetchData(){
        print("Fetch Data")
    }
    
    func updateData(data:memo){
        print(data)
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        
        
        var values : [String:Any] = [
            "isprivate":data.isprivate,
            "content":data.content,
            "time":convertString(content: Date(), dateFormat: "yyyy-MM-dd HH:mm:ss")
        ]
        
        if let meal = data.meal{
            meal.forEach { meal in
                if meal.foodList != nil,meal.mealType != nil {
                    values[meal.mealType!.rawValue] = meal.foodList!
                }
            }
        }
        
        reference
            .child("memo")
            .child(trainerid)
            .child(self.userid)
            .child(data.title)
            .setValue(values)
    }
    
    func disAppear(){
        self.meals = [
            meal(mealType: .first, foodList: []),
            meal(mealType: .second, foodList: []),
            meal(mealType: .third, foodList: [])
        ]
    }
    
    
}
