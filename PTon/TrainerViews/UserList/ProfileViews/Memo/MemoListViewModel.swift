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
    let content:String
    let time:String
    let isPrivate:Bool
    let firstMeal:[String]?
    let secondMeal:[String]?
    let thirdMeal:[String]?
    
    enum CodingKeys:String,CodingKey{
        case uuid
        case title
        case content
        case time
        case isPrivate
        case firstMeal = "아침"
        case secondMeal = "점심"
        case thirdMeal = "저녁"
    }
}


class MemoListViewModel:ObservableObject{
    @Published var memos:[Memo] = []
    
    let userid:String
    let db = Firestore.firestore()
    
    init(userid:String){
        self.userid = userid
        
        observeData()
    }
    
    func fetchData(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else {return}
        
        self.memos.removeAll(keepingCapacity: true)
        
        
        db.collection("Memo").document(trainerid).collection(userid).getDocuments { (querySnapshot,error) in
            if let error = error{
                print("Error Getting documents ::: \(error.localizedDescription)")
            }else{
                querySnapshot?.documents.forEach{ document in
                    print("\(document.documentID) ::: \(document.data())")
                    
                    let result = Result {
                        try document.data(as: Memo.self)
                    }
                    
                    switch result {
                    case .success(let Memo):
                        if let memo = Memo{
                            print("MEMO ::: \(memo)")
                            self.memos.append(memo)
                        }else{
                            print("Document does not Exist")
                        }
                    case .failure(let failure):
                        print("Error decoding Memo ::: \(failure)")
                    }
                }
            }
        }
            
    }
    
    func observeData(){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        
        db.collection("Memo").document(trainerid).collection(userid).order(by: "time",descending: true).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else{return}
            
            snapshot.documentChanges.forEach { diff in
                if diff.type == .added{
                    let result = Result{
                        try diff.document.data(as: Memo.self)
                    }
                    
                    switch result {
                    case .success(let success):
                        if let memo = success{
                            self.memos.append(memo)
                        }else{
                            print("Error")
                        }
                    case .failure(let failure):
                        print("Error decoding Memo")
                    }
                }
            }
        }
    }
    
}


//MARK: - 속도 측정 (1)
//    .getDocuments { querySnapshot, error in
//    guard let documents = querySnapshot?.documents,error == nil else{return}
//
//    self.memos = documents.compactMap{ querySnapshot -> Memo in
//        let data = try? querySnapshot.data(as:Memo.self)
//        return data!
//    }
