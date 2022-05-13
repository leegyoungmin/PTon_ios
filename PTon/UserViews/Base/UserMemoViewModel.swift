//
//  UserMemoViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/05/13.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserMemoViewModel:ObservableObject{
    @Published var memos:[Memo] = []
    
    let userId:String
    let trainerId:String
    let userProfile:String
    let db = Firestore.firestore()
    
    init(_ userId:String,_ trainerId:String,_ userProfile:String){
        self.userId = userId
        self.trainerId = trainerId
        self.userProfile = userProfile
        
        fetchData()
    }
    
    func fetchData(){
        db.collection("Memo").document(trainerId).collection(userId).order(by: "time",descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else{return}
                
                snapshot.documentChanges.forEach{ diff in
                    let result = Result{
                        try diff.document.data(as: Memo.self)
                    }
                    
                    self.changeData(diff, result: result)
                }
            }
    }
    
    func changeData(_ diff:DocumentChange,result:Result<Memo?,Error>){
        switch result{
        case .success(let success):
            if let memo = success{
                switch diff.type{
                case .added:
                    self.memos.append(memo)
                case _:
                    guard let index = self.memos.firstIndex(where: {$0.uuid == memo.uuid}) else{return}
                    
                    if diff.type == .modified{
                        modifyMemo(index, memo: memo)
                    }else if diff.type == .removed{
                        removeMemo(index)
                    }
                }
            }
        case .failure(let error):
            print("Error decoding Memo ::: \(error.localizedDescription)")
        }
    }
    
    func modifyMemo(_ index:Int,memo:Memo){
        self.memos[index] = memo
    }
    func removeMemo(_ index:Int){
        self.memos.remove(at: index)
    }
}
