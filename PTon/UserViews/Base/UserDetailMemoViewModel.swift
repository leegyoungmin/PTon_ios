//
//  UserDetailMemoViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/05/14.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase


class UserDetailMemoViewModel:ObservableObject{
    @Published var comments:[comment] = []
    let userId:String
    let trainerId:String
    let memoId:String
    let reference:CollectionReference
    
    init(_ userId:String,_ trainerId:String, _ memoId:String){
        self.userId = userId
        self.trainerId = trainerId
        self.memoId = memoId
        
        self.reference = Firestore.firestore().collection("Memo").document(trainerId).collection(userId).document(memoId).collection("Comment")
        
        ObserveData()
    }
    
    func ObserveData(){
        reference.order(by: "time").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else{return}
            
            snapshot.documentChanges.forEach { diff in
                let result = Result{
                    try diff.document.data(as: comment.self)
                }
                
                self.loadData(diff.type, result: result)
            }
        }
    }
    
    func loadData(_ changeType:DocumentChangeType,result:Result<comment?,Error>){
        switch result{
        case .success(let comment):
            if let comment = comment{
                if changeType == .added{
                    self.comments.append(comment)
                }else{
                    guard let index = self.comments.firstIndex(where: {$0.uid == comment.uid}) else {return}
                    
                    if changeType == .removed{
                        self.comments.remove(at: index)
                    }
                    
                    if changeType == .modified{
                        self.comments[index] = comment
                    }
                }
            }
        case .failure(let error):
            print("Error decoding comment \(error.localizedDescription)")
        }
    }
    
    var unReadCount:Int{
        return self.comments.filter{$0.isRead == false}.count
    }
}
