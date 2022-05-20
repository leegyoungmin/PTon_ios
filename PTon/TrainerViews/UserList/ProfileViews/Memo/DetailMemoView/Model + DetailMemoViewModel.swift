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
    var uid:String
    var writerId:String
    var writerName:String
    var content:String
    var time:String
    var isLike:Bool
    var isRead:Bool
}

//MARK: - ViewModel
class DetailMemoViewModel:ObservableObject{
    @Published var commentList:[comment] = []
    
    let userId:String
    let userName:String
    let trainerId:String
    let trainerName:String
    let memoId:String
    let userProfile:String
    let reference:CollectionReference
    
    init(userId:String,userName:String,trainerId:String,trainerName:String,memoId:String,userProfile:String){
        self.userId = userId
        self.userName = userName
        self.trainerId = trainerId
        self.trainerName = trainerName
        self.memoId = memoId
        self.userProfile = userProfile
        
        // Collection 지정
        self.reference = Firestore.firestore().collection("Memo").document(trainerId).collection(userId).document(memoId).collection("Comment")
        
        // 데이터 구독함수 실행
        ObserveData()
    }
    
    //MARK: - 데이터 구독 함수
    func ObserveData(){
        reference.order(by: "time").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else{return}
            
            snapshot.documentChanges.forEach { diff in
                
                let result = Result{
                    try diff.document.data(as: comment.self)
                }
                
                self.loadData(diff.type, result: result)
            }
        }
    }
    
    //MARK: - 리스너 값 처리 함수
    func loadData(_ changeType:DocumentChangeType,result:Result<comment?,Error>){
        switch result{
        case .success(let comment):
            if let comment = comment{
                if changeType == .added{
                    self.commentList.append(comment)
                }
                else{
                    guard let index = self.commentList.firstIndex(where: {$0.uid == comment.uid}) else {return}
                    
                    if changeType == .removed{
                        self.commentList.remove(at: index)
                    }
                    
                    if changeType == .modified{
                        self.commentList[index] = comment
                    }
                }
            }
        case .failure(let error):
            print("Error decoding comment \(error)")
        }
    }
    
    //TODO: - Trainer 유저 메소드
    func setCommentData(_ content:String){
        let data = makeInputData(type: .trainer, content: content)
        uploadData(data: data)
    }
    
    //MARK: - 데이터 업로드 함수
    func uploadData(data:[String:Any]){
        guard let uuid = data["uid"] as? String else{return}
        reference
            .document(uuid)
            .setData(data)
    }
    
    //MARK: - 업로드 데이터 생성 함수
    func makeInputData(type:userType = .trainer,content:String) -> [String:Any]{
        let data:[String:Any] = [
            "uid" : UUID().uuidString,
            "content" : content,
            "time" : convertString(content: Date(), dateFormat: "yyyy-MM-dd HH:mm"),
            "isLike" : false,
            "isRead":false,
            "writerId":trainerId,
            "writerName":trainerName
        ]
        return data
    }
    
    //MARK: - 작성자 판별 메소드
    func isWriter(_ writerId:String)->Bool{
        guard let currentUser = Firebase.Auth.auth().currentUser else{return true}
        return writerId == currentUser.uid
    }
    
    //MARK: - 좋아요 변경 함수
    func toggleLike(comment:comment){
        reference
            .document(comment.uid)
            .updateData(["isLike":!comment.isLike])
    }
    
    //MARK: - 댓글 삭제 버튼
    func deleteData(comment:comment){
        reference
            .document(comment.uid)
            .delete()
    }
    
//    func updateMemoData(data:Memo){
//        let reference = Firestore.firestore().collection("Memo").document(trainerId).collection(userId).document(data.uuid)
//        let data:[String:Any] = [
//            "content":data.content,
//            "time":convertString(content: Date(), dateFormat: "yyyy-MM-dd HH:mm"),
//            "uuid":data.uuid,
//            mealType.first.rawValue:data.firstMeal,
//            mealType.second.rawValue:data.secondMeal,
//            mealType.snack.rawValue:data.snack,
//            mealType.third.rawValue:data.thirdMeal
//        ]
//        
//        reference.updateData(data)
//    }
//    
    //MARK: - 리스너 제거 메소드 (뷰가 사라질 경우, 리스너를 분리한다.)
    func viewDisapper(data:Memo){
        
//        updateMemoData(data: data)
        let listener = reference.addSnapshotListener { querySnapshot, error in}
        
        listener.remove()
    }
    
    func isTrainer()->Bool{
        guard let currentUser = Firebase.Auth.auth().currentUser?.uid else{return true}
        
        if trainerId == currentUser{
            return true
        }else if userId == currentUser{
            return false
        }else{
            return true
        }
    }
    
}
