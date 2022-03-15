//
//  Model + ScheduleViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/11.
//

import Foundation
import Firebase

//struct schedule:Hashable{
//}

//Date value Model

struct DateValue:Identifiable{
    var id = UUID().uuidString
    var day:Int
    var date:Date
}

//TODO: - userid, username, profileImageUrl 추가 및 데이터 구조 변경
struct schedule:Hashable{
    var date:Date
    var isDone:Bool
    var time:Date
}

struct userSchedule:Hashable{
    var userid:String
    var username:String
    var profileImage:String
    var schedule:schedule
}

class ScheduleViewModel:ObservableObject{
    @Published var schedules:[userSchedule] = []
    @Published var traineeList:[trainee] = []
    
    let reference = Firebase.Database.database().reference()
    init(){
        fetchData(Date())
        fetchUserNames()
    }
    
    
    func fetchData(_ selectedDate:Date){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        
        schedules.removeAll(keepingCapacity: true)
        
        reference
            .child("Reservation")
            .child(trainerid)
            .child(convertString(content: selectedDate, dateFormat: "yyyy-MM-dd"))
            .observeSingleEvent(of: .value) { snapshot in
                
                print(snapshot)
                
                if snapshot.exists(){
                    for child in snapshot.children{
                        let childSnap = child as! DataSnapshot
                        let userid = childSnap.key
                        
                        
                        guard let values = childSnap.value as? [String:Any],
                              let isDone = values["Checked"] as? Bool,
                              let time = values["Time"] as? String else {return}
                        
                        self.reference
                            .child("User")
                            .child(userid)
                            .observeSingleEvent(of: .value) { snapshot in
                                
                                guard let values = snapshot.value as? [String:Any],
                                      let username = values["name"] as? String,
                                      let profileImage = values["photoUri"] as? String else{return}
                                
                                print(snapshot)
                                
                                let schedule = schedule(
                                    date: selectedDate,
                                    isDone: isDone,
                                    time: convertdate(content: time, format: "HH:mm")
                                )
                                
                                let data = userSchedule(
                                    userid: userid,
                                    username: username,
                                    profileImage: profileImage,
                                    schedule:schedule
                                )
                                
                                self.schedules.append(data)
                            }
                    }
                }
            }
    }
    
    func fetchUserNames(){
        self.traineeList.removeAll()
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        
        reference
            .child("Trainer")
            .child(trainerid)
            .child("trainee")
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists(){
                    for child in snapshot.children{
                        let childSnap = child as! DataSnapshot
                        
                        guard let value = childSnap.value as? String else {return}
                            
                        let currentTrainee = trainee(username: value, userid: childSnap.key)
                        self.traineeList.append(currentTrainee)
                    }
                    
                    self.getUserImage()
                }
            }
    }
    
    func getUserImage(){
        self.traineeList.indices.forEach { index in
            
            if let userid = self.traineeList[index].userid{
                reference
                    .child("User")
                    .child(userid)
                    .child("photoUri")
                    .observeSingleEvent(of: .value) { snapshot in
                        if snapshot.exists(), let profile = snapshot.value as? String {
                            self.traineeList[index].userProfile = profile
                        }
                    }
            }
            

        }
    }
    
    func updateReservation(_ date:Date,_ userIndex:Int){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid,
              let userid = traineeList[userIndex].userid else{return}
        
        let data:[String:Any] = [
            "Checked":false,
            "Time":convertString(content: date, dateFormat: "HH:mm")
        ]
        
        reference
            .child("Reservation")
            .child(trainerid)
            .child(convertString(content: date, dateFormat: "yyyy-MM-dd"))
            .child(userid)
            .setValue(data)
    }
    
    func changeReservation(_ date:Date,_ userid:String){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        
        let values = ["Checked":true]
        
        reference
            .child("Reservation")
            .child(trainerid)
            .child(convertString(content: date, dateFormat: "yyyy-MM-dd"))
            .child(userid)
            .updateChildValues(values)

        let currentRef = reference.child("Membership").child(userid)
        currentRef
            .child("ptUsed")
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists(){
                    guard let value = snapshot.value as? String else{return}
                    
                    currentRef.updateChildValues(["ptUsed":String(Int(value)! + 1)])
                    
                }
            }
    }
}
