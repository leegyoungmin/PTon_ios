//
//  Model + PublicMemoViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/17.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

//MARK: - Model
struct comment:Hashable,Codable{
    var uid:String = UUID().uuidString
    var writerId:String
    var writerName:String
    var content:String
    var time:String
    var isLike:Bool
}

//MARK: - ViewModel
class PublicMemoViewModel:ObservableObject{
    @Published var commentList:[comment] = []
    
    let userId:String
    let userName:String
    let trainerId:String
    let trainerName:String
    let memoId:String
    let reference:CollectionReference
    
    init(userId:String,userName:String,trainerId:String,trainerName:String,memoId:String){
        self.userId = userId
        self.userName = userName
        self.trainerId = trainerId
        self.trainerName = trainerName
        self.memoId = memoId
        
        self.reference = Firestore.firestore().collection("Memo").document(trainerId).collection(userId).document(memoId).collection("Comment")
        
        ObserveData()
    }
    
    //TODO: - Read Data
    //MARK: - 가독성을 위한 함수 분리 작업
    func ObserveData(){
        reference.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else{return}
            
            snapshot.documentChanges.forEach { diff in
                if diff.type == .added{
                    let result = Result{
                        try diff.document.data(as: comment.self)
                    }
                    
                    switch result {
                    case .success(let success):
                        if let comment = success{
                            self.commentList.append(comment)
                        }else{
                            print("Error")
                        }
                    case .failure(let failure):
                        print("Error decoding Memo \(failure.localizedDescription)")
                    }
                }else if diff.type == .modified{
                    
                    
                    let result = Result{
                        try diff.document.data(as: comment.self)
                    }
                    
                    
                    switch result {
                    case .success(let success):
                        if let comment = success{
                            guard let index = self.commentList.firstIndex(where: {$0.uid == diff.document.documentID}) else{return}
                            
                            self.commentList[index] = comment
                        }else{
                            print("Error in comment make")
                        }
                    case .failure(let failure):
                        
                        print("Error decoding Memo \(failure.localizedDescription)")
                    }
                } else if diff.type == .removed{
                    let result = Result{
                        try diff.document.data(as: comment.self)
                    }
                    
                    switch result {
                    case .success(let success):
                        if let comment = success{
                            guard let index = self.commentList.firstIndex(where: {$0.uid == diff.document.documentID}) else{return}
                            
                            self.commentList.remove(at: index)
                        } else{
                            print("Error in Comment make")
                        }
                    case .failure(let failure):
                        print("Error decoding Memo \(failure.localizedDescription)")
                    }
                }
            }
        }
    }
    
    //TODO: - Create Data
    func setCommentData(_ content:String){
        
        guard let currentUser = Firebase.Auth.auth().currentUser else{return}
        
        //Trainer일 경우
        if trainerId == currentUser.uid{
            let data = makeInputData(type: .trainer, content: content)
            uploadData(data: data)
        }else if userId == currentUser.uid{
            let data = makeInputData(type: .user, content: content)
            uploadData(data: data)
        }
    }
    
    //MARK: - Upload Data
    func uploadData(data:[String:Any]){
        guard let uuid = data["uid"] as? String else{return}
        reference
            .document(uuid)
            .setData(data)
    }
    
    //MARK: - Make Upload Data
    func makeInputData(type:userType,content:String) -> [String:Any]{
        var data:[String:Any] = [:]
        
        if type == .trainer{
            data = [
                "uid" : UUID().uuidString,
                "writerId" : trainerId,
                "writerName" : trainerName,
                "content" : content,
                "time" : convertString(content: Date(), dateFormat: "yyyy-MM-dd HH:mm"),
                "isLike" : false
            ]
        }else if type == .user{
            data = [
                "uid" : UUID().uuidString,
                "writerId" : userId,
                "writerName" : userName,
                "content" : content,
                "time" : convertString(content: Date(), dateFormat: "yyyy-MM-dd HH:mm"),
                "isLike" : false
            ]
        }
        return data
    }
    
    //MARK: - 작성자 판별 메소드
    func isWriter(_ writerId:String)->Bool{
        guard let currentUser = Firebase.Auth.auth().currentUser else{return true}
        return writerId == currentUser.uid
    }
    
    //MARK: - Toggle Like
    func toggleLike(comment:comment){
        
        reference
            .document(comment.uid)
            .updateData(["isLike":!comment.isLike])
    }
    
    //MARK: - Delete comment
    func deleteData(comment:comment){
        reference
            .document(comment.uid)
            .delete()
    }
}


