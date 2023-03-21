//
//  searchModel+mealSearchViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/05/20.
//

import Foundation
import InstantSearchSwiftUI
import InstantSearchCore
//import FirebaseStorage
//import Firebase

struct foodResult:Codable{
    var foodName:String
    var manufacture:String
    var intake:Double
    var kcal:Double
    var protein:Double
    var fat:Double
    var carbs:Double
    var sodium:Double
    
    var proteinKcal:Double{
        return protein*4
    }
    var carbsKcal:Double{
        return carbs*4
    }
    var fatKcal:Double{
        return fat*9
    }
}

class AlgoliaController{
    let searcher:HitsSearcher
    
    let queryInputInteractor:SearchBoxInteractor
    let queryInputController:SearchBoxObservableController
    
    let hitsInteractor:HitsInteractor<foodResult>
    let hitsController: HitsObservableController<foodResult>
    
    init(){
        self.searcher = HitsSearcher(appID: "ZYD60NFWI1", apiKey: "3b7be953c85e84f564b6fd9e4f365d75", indexName: "food")
        self.queryInputController = .init()
        self.queryInputInteractor = .init()
        
        self.hitsController = .init()
        self.hitsInteractor = .init()
        
        setupConnections()
    }
    
    func setupConnections(){
        queryInputInteractor.connectSearcher(searcher)
        queryInputInteractor.connectController(queryInputController)
        hitsInteractor.connectSearcher(searcher)
        hitsInteractor.connectController(hitsController)
    }
}

enum ingredientType:String,Error,Codable{
    case all = "AllKcal"
    case carbo = "Carbohydrate"
    case fat = "Fat"
    case protein = "Protein"
    case error
}

struct ingredient:Codable,Hashable{
    var type:ingredientType
    var kcal:Int
}
class FoodRecordViewModel:ObservableObject{
    @Published var ingredients:[ingredient] = []
    let userId:String
    let trainerId:String
    let mealType:mealType
    let storage:StorageReference
    let reference:DatabaseReference
    
    init(userId:String,trainerId:String,mealtype:mealType){
        self.userId = userId
        self.trainerId = trainerId
        self.mealType = mealtype
        self.storage = Storage.storage().reference().child("FoodJournal").child(userId)
        self.reference = Firebase.Database.database().reference().child("FoodJournal").child(trainerId).child(userId)
        
        loadIngredient()
    }
    
    func loadIngredient(){
        Firebase.Database.database()
            .reference()
            .child("Ingredient")
            .child(self.userId)
            .observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children{
                    let childSnapshot = child as! DataSnapshot
                    let key = childSnapshot.key
                    print(key)
                    guard let dict = childSnapshot.value as? [String:Any],
                          let kcal = dict["Kcal"] as? String else{ return }
                    let kcalValue = Int(Double(kcal) ?? 0)
                    
                    let type = ingredientType.init(rawValue: key) ?? .error
                    
                    self.ingredients.append(ingredient(type: type, kcal: kcalValue))
                }
            }
    }
    
    func userAllKcal()->Int{
        guard let first = ingredients.filter({$0.type == .all}).first else{return 1}
        return first.kcal
    }
    
    func userCarbo()->Int{
        guard let first = ingredients.filter({$0.type == .carbo}).first else{return 1}
        return first.kcal
    }
    
    func userProtein()->Int{
        guard let first = ingredients.filter({$0.type == .protein}).first else{return 1}
        return first.kcal
    }
    
    func userFat()->Int{
        guard let first = ingredients.filter({$0.type == .fat}).first else{return 1}
        return first.kcal
    }
    
    func uploadUserRecord(userData:[String:Any]){
        reference
            .child(convertString(content: Date(), dateFormat: "yyyy-MM-dd"))
            .child(self.mealType.keyDescription())
            .childByAutoId()
            .updateChildValues(userData)
    }
    
    func uploadImage(imageData:Data?,completion:@escaping(String?)->Void){
        guard let imageData = imageData else {
            return
        }
        let meta = StorageMetadata()
        meta.contentType = "image/jpg"
        
        let imagePath:String = "FoodJournal_\(convertString(content: Date(), dateFormat: "yyyy_MM_dd_hh_mm_ss")).jpg"
        storage.child(imagePath).putData(imageData, metadata: meta) { meta, error in
            self.storage.child(imagePath).downloadURL { url, _ in
                guard let path = url?.downloadURL.absoluteString else{return}
                completion(path)
            }
        }
        
    }
}
