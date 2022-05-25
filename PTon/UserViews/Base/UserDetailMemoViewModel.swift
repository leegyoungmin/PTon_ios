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
    let userName:String
    let trainerId:String
    let memoId:String
    let reference:CollectionReference
    
    init(_ userId:String,_ userName:String,_ trainerId:String, _ memoId:String){
        self.userId = userId
        self.userName = userName
        self.trainerId = trainerId
        self.memoId = memoId
        
        print(self.userId)
        
        self.reference = Firestore.firestore().collection("Memo").document(self.trainerId).collection(self.userId).document(self.memoId).collection("Comment")
        
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
    
    func loadData(_ changeType:DocumentChangeType,result:Result<comment,Error>){
        switch result{
        case .success(let comment):
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
        case .failure(let error):
            print("Error decoding comment \(error.localizedDescription)")
        }
    }
    
    var unReadCount:Int{
        return self.comments.filter{$0.isRead == false}.count
    }
    
    func changeUnread(_ index:Int){
        let commentId = self.comments[index].uid
        self.reference.document(commentId).updateData(["isRead":true])
    }
    
    
    //MARK: - 데이터 업로드 함수
    func uploadComment(data:[String:Any]){
        guard let uuid = data["uid"] as? String else{return}
        print(uuid)
        Firestore.firestore().collection("Memo")
            .document(self.trainerId)
            .collection(self.userId)
            .document(self.memoId)
            .collection("Comment")
            .document(uuid)
            .setData(data)
    }
    
    func makeInputData(type:userType = .user,content:String)->[String:Any]{
        let data:[String:Any] = [
            "uid":UUID().uuidString,
            "content":content,
            "time":convertString(content: Date(), dateFormat: "yyyy-MM-dd HH:mm"),
            "isLike":false,
            "isRead":false,
            "writerId":userId,
            "writerName":userName
        ]
        
        return data
    }
    
    //MARK: - 좋아요 업데이트 함수
    func toggleLike(comment:comment){
        reference
            .document(comment.uid)
            .updateData(["isLike":!comment.isLike])
    }
    
    //MARK: - 댓글 삭제 함수
    func deleteComment(comment:comment){
        reference
            .document(comment.uid)
            .delete()
    }

}
