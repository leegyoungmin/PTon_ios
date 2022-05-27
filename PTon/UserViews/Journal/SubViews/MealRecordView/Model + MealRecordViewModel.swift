////
////  Model + MealRecordViewModel.swift
////  PTon
////
////  Created by 이경민 on 2022/03/24.
////

import Foundation
import Firebase
import CoreGraphics
import FirebaseStorage

struct userMeal:Hashable{
    var mealtype:mealType
    var uuid:String
    var name:String
    var url:String

}

struct userFoodResult:Hashable{
    var id:String
    var mealType:mealType
    var carbs:Int
    var fat:Int
    var foodName:String
    var intake:Int
    var kcal:Int
    var protein:Int
    var sodium:Int
    var url:String
}

class UserMealViewModel:ObservableObject{
    @Published var recordedMeals:[userFoodResult] = []
    @Published var totalIngrendientKcal:Double = 0
    @Published var totalKcal:Double = 0
    @Published var chartRatio:CGFloat = 0
    let userId:String,trainerId:String,fitnessCode:String
    let selectedDate:Date
    let reference:DatabaseReference
    
    init(userId:String,trainerId:String,fitnessCode:String,selectedDate:Date){
        self.userId = userId
        self.trainerId = trainerId
        self.fitnessCode = fitnessCode
        self.selectedDate = selectedDate
        
        self.reference = Firebase.Database.database().reference().child("FoodJournal").child(trainerId).child(userId)
        readIngredientKcal()
        ObserveData {
            let rawRatio = self.totalKcal/self.totalIngrendientKcal
            self.chartRatio = CGFloat(round(rawRatio * pow(10, 2)) / pow(10, 2))/2
            print("chart ratio ::: \(self.chartRatio)")
        }
    }
    
    func readIngredientKcal(){
        Firebase.Database.database().reference()
            .child("Ingredient")
            .child(userId)
            .child("AllKcal")
            .observeSingleEvent(of: .value) { snapshot in
                print(snapshot)
                if snapshot.childSnapshot(forPath: "Kcal").exists(){
                    let value = snapshot.childSnapshot(forPath: "Kcal").value as? String
                    self.totalIngrendientKcal = Double(value ?? "0") ?? 0
                }
            }
    }
    
    
    func ObserveData(completion:@escaping()->Void){
        mealType.allCases.map{$0.keyDescription()}.forEach{ keyValue in
            // child added
            reference
                .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
                .child(keyValue)
                .observe(.childAdded) { [weak self] snapshot in
                    guard let self = self else{return}
                    guard let values = snapshot.value as? [String:Any] else{return}
                    
                    let id = snapshot.key
                    let type = mealType.init(key: keyValue)
                    let carbs = values["carbs"] as? Int ?? 0
                    let fat = values["fat"] as? Int ?? 0
                    let foodName = values["foodName"] as? String ?? ""
                    let intake = values["intake"] as? Int ?? 0
                    let kcal = values["kcal"] as? Double ?? 0
                    self.totalKcal += kcal
                    let protein = values["protein"] as? Int ?? 0
                    let sodium = values["sodium"] as? Int ?? 0
                    let path = values["url"] as? String ?? ""
                    
                    let data = userFoodResult(id: id, mealType: type ?? .first, carbs: carbs, fat: fat, foodName: foodName, intake: intake, kcal: Int(kcal), protein: protein, sodium: sodium, url: path)
                    self.recordedMeals.append(data)
                    
                    
                    completion()
                }
            
            // child removed
            reference
                .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
                .child(keyValue)
                .observe(.childRemoved) { [weak self] snapshot in
                    guard let self = self else { return }
                    let key = snapshot.key
                    guard let values = snapshot.value as? [String:Any] else {return}
                    let kcal = values["kcal"] as? Double ?? 0
                    self.totalKcal -= kcal
                    
                    self.recordedMeals.removeAll(where: {$0.id == key})
                    
                    completion()
                }
        }
        
    }
    
    func updateDirect(_ index:Int,_ data:[String:Any],completion:@escaping()->Void){
        guard let keyString = mealType.init(rawValue: index)?.keyDescription() else{return}
        reference
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .child(keyString)
            .childByAutoId()
            .updateChildValues(data) { error, _ in
                completion()
            }
    }
    
    //
    func uploadImage(image:Data?,completion:@escaping(String)->()){
        guard let image = image else { return }
        let meta = StorageMetadata()
        meta.contentType = "image/jpg"
        
        let url = "FoodJournal_\(convertString(content: Date(), dateFormat: "yyyy_MM_dd_hh_mm_ss")).jpg"
        FirebaseStorage.Storage.storage().reference()
            .child("FoodJournal")
            .child(self.userId)
            .child(url)
            .putData(image,metadata: meta) { meta, error in
                FirebaseStorage.Storage.storage().reference()
                    .child("FoodJournal")
                    .child(self.userId)
                    .child(url)
                    .downloadURL { url, _ in
                        guard let path = url?.downloadURL.absoluteString else{return}
                        completion(path)
                    }
            }
    }
    
    //아이템 제거 메소드
    func removeItem(_ food:userFoodResult){
        reference
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .child(food.mealType.keyDescription())
            .child(food.id)
            .removeValue()
        
    }
}
