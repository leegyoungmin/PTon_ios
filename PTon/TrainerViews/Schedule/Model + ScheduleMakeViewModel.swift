//
//  Model + ScheduleMakeViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/04/05.
//

import Foundation
import Firebase

struct schedulUser:Hashable{
    var memberShip:memberShip
    var user:trainee
}


class ScheduleMakeViewModel:ObservableObject{
    @Published var users:[schedulUser] = []
    
    let trainees:[trainee]
    let reference = Firebase.Database.database().reference()
    
    init(trainees:[trainee]){
        self.trainees = trainees
        
        fetchData()
    }
    
    func fetchData(){
        trainees.forEach{ user in
            reference
                .child("Membership")
                .child(user.userId)
                .observeSingleEvent(of: .value) { snapshot in
                    guard let values = snapshot.value as? [String:Any] else{return}
                    var memberShip = memberShip()
                    
                    if let startDate = values["StartDate"] as? String{
                        memberShip.startMember = convertdate(content: startDate, format: "yyyy-MM-dd")
                    }
                    
                    if let endDate = values["EndDate"] as? String{
                        memberShip.endMember = convertdate(content: endDate, format: "yyyy-MM-dd")
                    }
                    
                    if let maxTimes = values["ptTimes"] as? String{
                        memberShip.maxLisence = maxTimes
                    }
                    
                    if let usedTimes = values["ptUsed"] as? String{
                        memberShip.useLisence = usedTimes
                    }
                    
                    let currentScheduleUser = schedulUser(memberShip: memberShip, user: user)
                    self.users.append(currentScheduleUser)
                }
        }

    }
    
    func updateReservation(date:Date,user:trainee){
        guard let trainerId = Firebase.Auth.auth().currentUser?.uid else{return}
        let data:[String:Any] = [
            "Checked":false,
            "Time":convertString(content: date, dateFormat: "HH:mm")
        ]
        
        reference
            .child("Reservation")
            .child(trainerId)
            .child(convertString(content: date, dateFormat: "yyyy-MM-dd"))
            .child(user.userId)
            .updateChildValues(data)
    }
    
    func isNotPossible(max:Int,min:Int)->Bool{
        return (max-min) <= 0
    }
}
