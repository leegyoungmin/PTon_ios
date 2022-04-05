//
//  TrainerUserListViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/08.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseDatabase

//MARK: MODEL
struct trainee:Hashable,Identifiable{
    let id = UUID().uuidString
    var username:String?
    var useremail:String?
    var userid:String?
    var userProfile:String?
    
    var userName:String {
        guard let username = username else {
            return ""
        }
        
        return username
    }
    var userId:String {
        guard let userid = userid else {
            return ""
        }
        
        return userid
    }
}

//MARK: VIEWMODEL
class TrainerUserListViewModel:ObservableObject{
    @Published var trainees:[trainee] = []
    var trainerid: String {
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return ""}
        return trainerid
    }
    let reference = FirebaseDatabase.Database.database().reference()
    var trainername:String
    var fitnessCode:String
    
    init(){
        self.trainername = ""
        self.fitnessCode = ""
        self.getTrainerName()
        self.fetchData()
    }
    
    //트레이너 이름 및 코드 불러오기 함수
    func getTrainerName(){
        guard let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        reference
            .child("Trainer")
            .child(trainerid)
            .observeSingleEvent(of: .value) { snapshot in
                guard let values = snapshot.value as? [String:Any] else{return}
                print(values)
                
                guard let trainerName = values["name"] as? String,
                      let fitnessCode = values["fitnessCode"] as? String else{return}
                
                self.trainername = trainerName
                self.fitnessCode = fitnessCode
            }
    }
    
    func userid(_ index:Int)->String{
        guard let userid = trainees[index].userid else{return "" }
        return userid
    }
    
    //유저 아이디 불러오기 메소드
    func fetchData(){
        guard let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        reference
            .child("Trainer")
            .child(trainerid)
            .child("trainee")
            .observe(.childAdded) { snapshot in
                if snapshot.value as? String == "default"{
                    self.trainees = []
                }else{
                    print("Snapshot in fetch Data ::: \(snapshot)")
                    let userId = snapshot.key
                    guard let userName = snapshot.value as? String else{return}
                    
                    self.reference
                        .child("User")
                        .child(userId)
                        .child("photoUri")
                        .observeSingleEvent(of: .value) { snapshot in
                            if snapshot.exists(){
                                guard let url = snapshot.value as? String else{return}
                                self.trainees.append(trainee(username: userName, useremail: "", userid: userId, userProfile: url))
                            }else{
                                self.trainees.append(trainee(username: userName, useremail: "", userid: userId, userProfile: ""))
                            }
                        }
                }
                print("self.fetch data ::: \(self.trainees)")
            }
        
        
        reference
            .child("Trainer")
            .child(trainerid)
            .child("trainee")
            .observe(.childRemoved) { snapshot in
                let userId = snapshot.key
                
                self.trainees.removeAll(where: {$0.userId == userId})
            }
        
       
    }
    
    //유저 지우기 메소드
    func removeUser(userId:String){
        guard let trainerid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        reference
            .child("Trainer")
            .child(trainerid)
            .child("trainee")
            .child(userId)
            .removeValue { error, reference in
                if error == nil{
                    self.reference
                        .child("User")
                        .child(userId)
                        .child("trainer")
                        .setValue("default")
                }
            }
    }
    
    func selectedtrainee(_ index:Int)->trainee{
        return self.trainees[index]
    }
    
    func selectedUserIndex(_ userId:String)->Int{
        guard let index = self.trainees.firstIndex(where: {$0.userId == userId}) else{return -1}
        return index
    }
}
