//
//  AddUserViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/08.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase

//MARK: VIEWMODEL
class UserAddViewModel:ObservableObject{
    @Published var phoneNumber:String = ""
    @Published var findtrainee = trainee()
    let trainerId:String
    let reference = FirebaseDatabase.Database.database().reference()
    
    init(trainerId:String){
        self.trainerId = trainerId
    }
    
    /*
     1. 트레이너가 전화번호를 입력후 버튼 클릭
     2. 데이터베이스에서 전화번호가 적힌 데이터를 찾는다.
     3. 찾은 정보를 화면에 보여준다.
     4. 트레이너가 추가하기 버튼을 클릭한다.
     5. 트레이너가 존재하는지 판단후 존재하면 삭제를 요청하는 알림을 띄운다.
     6. 트레이너가 존재하지 않을 경우, 데이터를 유저와 트레이너에게 저장을 한다.
     7. 완료 메시지를 알림으로 띄운다.
     */
    
    //유저 데이터 불러오기 메소드
    func findUser(){
        reference
            .child("User")
            .observeSingleEvent(of: .value, with: { snapshot in
                for childValue in snapshot.children{
                    guard let childValues = childValue as? DataSnapshot,
                          let values = childValues.value as? [String:Any] else{return}
                    
                    if values["phone"] as? String == self.phoneNumber{
                        print(true.description)
                        self.findtrainee.useremail = values["email"]! as? String
                        self.findtrainee.username = values["name"]! as? String
                        self.findtrainee.userid = values["uid"]! as? String
                        self.findtrainee.userProfile = values["profile"] as? String ?? ""
                        break
                    }
                    else{
                        print(false.description)
                        self.findtrainee.username = nil
                        self.findtrainee.useremail = nil
                    }
                }
            })
    }
    
    //유저 업데이트 메소드
    func updateUser(completion:@escaping(UserAddError)->Void){
        isValidationAlreadyTrainer { istrainer in
            
            if istrainer == .notTrainer{
                self.reference
                    .child("Trainer")
                    .child(self.trainerId)
                    .child("trainee")
                    .updateChildValues([self.findtrainee.userId:self.findtrainee.userName]) { error, ref in
                        if error == nil{
                            self.reference
                                .child("User")
                                .child(self.findtrainee.userId)
                                .child("trainer")
                                .setValue(self.trainerId) { error, ref in
                                    if error == nil{
                                        completion(istrainer)
                                    }
                                }
                        }
                    }
            }else{
                completion(istrainer)
            }
        }
    }
    
    //TODO: 제거 알림 메소드
    
    func isValidationAlreadyTrainer(completions:@escaping(UserAddError)->Void){
        reference
            .child("User")
            .child(self.findtrainee.userId)
            .child("trainer")
            .observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? String else{return}
                
                if value == "default"{
                    completions(UserAddError.notTrainer)
                }else{
                    if value == self.trainerId{
                        completions(UserAddError.myUser)
                    }else if value != self.trainerId{
                        completions(UserAddError.differentTrainer)
                    }
                }
            }
    }
}

enum UserAddError:Error,LocalizedError{
    case myUser
    case differentTrainer
    case notTrainer
    
    var errorDescription: String?{
        switch self {
        case .myUser:
            return "이미 추가된 회원입니다."
        case .differentTrainer:
            return "트레이너가 이미 존재하는 회원입니다."
        case .notTrainer:
            return "트레이너가 없습니다."
        }
    }
}
