//
//  MemoListViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/15.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


struct Memo:Codable,Hashable{
    let uuid:String
    let title:String
    var content:String
    let time:String
    let isPrivate:Bool
    var firstMeal:[String]
    var secondMeal:[String]
    var thirdMeal:[String]
    var snack:[String]
    
    enum CodingKeys:String,CodingKey{
        case uuid
        case title
        case content
        case time
        case isPrivate
        case firstMeal = "아침"
        case secondMeal = "점심"
        case snack = "간식"
        case thirdMeal = "저녁"
    }
}


class MemoListViewModel:ObservableObject{
    @Published var memos:[Memo] = []
    
    let userid:String
    let trainerid:String
    let userProfile:String
    let db = Firestore.firestore()
    
    init(trainerid:String,userid:String,userProfile:String){
        self.trainerid = trainerid
        self.userid = userid
        self.userProfile = userProfile
        
        observeData()
    }
    
    //MARK: - 데이터 변화 감지 메소드
    func observeData(){
        db.collection("Memo").document(trainerid).collection(userid).order(by: "time",descending: true).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else{return}
            
            snapshot.documentChanges.forEach { diff in
                let result = Result{
                    try diff.document.data(as: Memo.self)
                }
                
                self.ChangeData(diff, result: result)
            }
        }
    }
    
    //MARK: - 데이터 변경 감지에 대한 데이터 처리 메소드
    func ChangeData(_ diff:DocumentChange,result:Result<Memo?,Error>){
        switch result {
        case .success(let success):
            if let memo = success{
                switch diff.type{
                case .added:
                    self.memos.append(memo)
                case .modified:
                    guard let index = self.memos.firstIndex(where: {$0.uuid == memo.uuid}) else{return}
                    
                    self.memos[index] = memo
                case .removed:
                    guard let index = self.memos.firstIndex(where: {$0.uuid == memo.uuid}) else{return}
                    
                    self.memos.remove(at: index)
                }
            }else{
                print("Error")
            }
        case .failure(let failure):
            print("Error decoding Memo ::: \(failure)")
        }
    }
    
    //MARK: - 데이터 제거 메소드
    func deleteData(data:Memo){
        db.collection("Memo").document(trainerid).collection(userid).document(data.uuid).delete()
    }
    
    //MARK: - 리스너 제거 메소드
    func viewDisAppear(){
        let listener = db.collection("Memo").document(trainerid).collection(userid).addSnapshotListener { snapshot, error in}
        listener.remove()
    }
    
}
