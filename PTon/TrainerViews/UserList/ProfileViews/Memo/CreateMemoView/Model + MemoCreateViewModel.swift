//
//  Model + MemoCreateViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/15.
//

import Foundation
import Firebase
import FirebaseFirestore


//MARK: - Model
struct memo{
    let uuid = UUID().uuidString
    var isprivate:Bool = false
    var title:String
    var content:String
    var meal:[meal]
}

struct meal{
    var mealType:mealType
    var foodList:[String]
}

//MARK: - ViewModel
//TODO: - 데이터 생성시 작성자 id 입력하여서 push notification 발송
class MemoCreateViewModel:ObservableObject{
    @Published var meals:[meal] = [
        meal(mealType: .first, foodList: []),
        meal(mealType: .second, foodList: []),
        meal(mealType: .snack, foodList: []),
        meal(mealType: .third, foodList: [])
    ]
    
    var userid:String
    let reference = Firebase.Database.database().reference()
    let db = Firestore.firestore()
    init(userid:String){
        self.userid = userid
    }
    
    
    //MARK: - 데이터 업데이트 메소드
    func updateData(data:memo){
        print(data)
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}

        let reference = db.collection("Memo").document(trainerid).collection(userid)
        var values : [String:Any] = [
            "uuid":data.uuid,
            "title":data.title,
            "isPrivate":data.isprivate,
            "content":data.content,
            "time":convertString(content: Date(), dateFormat: "yyyy-MM-dd HH:mm")
        ]
        
        data.meal.forEach{
            values[$0.mealType.rawValue] = $0.foodList
        }

        reference.document(data.uuid).setData(values)
    }
    
    //MARK: - 데이터 재정의 메소드
    func disAppear(){
        self.meals = [
            meal(mealType: .first, foodList: []),
            meal(mealType: .second, foodList: []),
            meal(mealType: .third, foodList: [])
        ]
    }
    
    
}
