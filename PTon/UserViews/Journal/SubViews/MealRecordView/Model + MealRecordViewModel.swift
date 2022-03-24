//
//  Model + MealRecordViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import Firebase

struct userMeal:Hashable{
    var mealtype:mealType
    var uuid:String
    var name:String
    var url:String
}


class MealRecordViewModel:ObservableObject{
    @Published var userMeals:[userMeal] = []
    
    let trainerId:String
    let userId:String
    let reference = Firebase.Database.database().reference()
    let storage = FirebaseStorage.Storage.storage().reference().child("food")
    
    init(_ trainerId:String,_ userId:String){
        self.trainerId = trainerId
        self.userId = userId
    }
    
    var breakFirstMeals: [userMeal]{
        return userMeals.filter({$0.mealtype == .first})
    }
    
    var lauchMeals:[userMeal]{
        return userMeals.filter({$0.mealtype == .second})
    }
    
    var snackMeals:[userMeal]{
        return userMeals.filter({$0.mealtype == .snack})
    }
    
    var dinnerMeals:[userMeal]{
        return userMeals.filter({$0.mealtype == .third})
    }
    
    func fetchData(_ selectedDate:Date){
        self.userMeals.removeAll()
        
        ["breakfirst","launch","snack","dinner"]
            .forEach{ foodType in
                self.reference
                    .child("FoodPhoto")
                    .child(self.trainerId)
                    .child(self.userId)
                    .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
                    .child(foodType)
                    .observeSingleEvent(of: .value) { snapshot in
                        for child in snapshot.children{
                            let childSnapshot = child as! DataSnapshot
                            let uuid = childSnapshot.key
                            guard let values = childSnapshot.value as? [String:Any],
                                  let foodName = values["foodName"] as? String,
                                  let url = values["url"] as? String else{return}
                            
                            
                            if foodType == "breakfirst"{
                                let currentMeal = userMeal(mealtype: mealType.first, uuid: uuid, name: foodName, url: url)
                                self.userMeals.append(currentMeal)
                                
                            }else if foodType == "launch"{
                                let currentMeal = userMeal(mealtype: mealType.second, uuid: uuid, name: foodName, url: url)
                                self.userMeals.append(currentMeal)
                                
                            }else if foodType == "snack"{
                                let currentMeal = userMeal(mealtype: mealType.snack, uuid: uuid, name: foodName, url: url)
                                self.userMeals.append(currentMeal)
                                
                            }else{
                                let currentMeal = userMeal(mealtype: mealType.third, uuid: uuid, name: foodName, url: url)
                                self.userMeals.append(currentMeal)
                            }
                        }
                    }
            }
        
    }
    
    func setImageData(_ date:Date,index:Int,image:UIImage,foodName:String){
        
        guard let data = image.jpegData(compressionQuality: 0.8) else{return}
        let jpg = "food_\(trainerId)_\(userId)_\(index)_\(convertString(content: date, dateFormat: "yyyy-MM-dd HH:mm"))"
        
        
        
        storage.child(jpg)
            .putData(data, metadata: nil) { metadata, error in
                guard error == nil else{return}
                
                self.storage.child(jpg)
                    .downloadURL { url, error in
                        if error == nil{
                            guard let url = url?.absoluteString else{return}
                            
                            let settingData:[String:Any] = [
                                "url":url,
                                "foodName":foodName
                            ]
                            
                            self.reference
                                .child("FoodPhoto")
                                .child(self.trainerId)
                                .child(self.userId)
                                .child(convertString(content: date, dateFormat: "yyyy-MM-dd"))
                                .child(self.changeMealType(index))
                                .childByAutoId()
                                .updateChildValues(settingData)
                        }
                    }
                
                
            }
    }
    
    func changeMealType(_ index:Int) -> String{
        var mealString = ""
        if index == 0{
            mealString = "breakfirst"
        }else if index == 1{
            mealString = "launch"
        }else if index == 2{
            mealString = "snack"
        }else if index == 3{
            mealString = "dinner"
        }else{
            mealString = "breakfirst"
        }
        
        return mealString
    }
    
    func downloadImage(url:String)->String{
        var returnString = ""
        storage
            .child(url)
            .downloadURL { url, error in
                guard let urlString = url?.absoluteString else{return}
                returnString = urlString
            }
        
        return returnString
    }
}

class MealImageViewModel:ObservableObject{
    var path:String
    init(path:String){
        self.path = path
        
        print(path)
    }
    
    func fetchImage(completion:@escaping(UIImage)->Void){
        FirebaseStorage.Storage.storage().reference()
            .child("food")
            .child(path)
            .getData(maxSize: 15 * 1024 * 1024) { data, error in
                if error != nil{
                    print("error : \(error.debugDescription)")
                    return
                } else {
                    if let image = UIImage(data: data!){
                        completion(image)
                    }else{
                        print("error : Can't convert Image")
                        return
                    }
                }
            }
    }
}
