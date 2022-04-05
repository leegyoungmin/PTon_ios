//
//  Model + ScheduleViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/11.
//

import Foundation
import Firebase

//Date value Model

struct DateValue:Identifiable{
    var id = UUID().uuidString
    var dateWeek:Int?
    var day:Int
    var date:Date
}

//TODO: - userid, username, profileImageUrl 추가 및 데이터 구조 변경
struct schedule:Hashable{
    var date:Date
    var isDone:Bool
    var time:Date
    var user:trainee
}

class ScheduleViewModel:ObservableObject{
    @Published var schedules:[schedule] = []
    let trainerId:String
    let trainees:[trainee]
    let reference = Firebase.Database.database().reference()
    
    init(trainerId:String,trainees:[trainee]){
        self.trainerId = trainerId
        self.trainees = trainees
        
        fetchData(Date())
    }
    
    func fetchData(_ date:Date){
        self.schedules.removeAll()
        trainees.forEach{ user in
            reference
                .child("Reservation")
                .child(trainerId)
                .child(convertString(content: date, dateFormat: "yyyy-MM-dd"))
                .child(user.userId)
                .observeSingleEvent(of: .value) { snapshot in
                    guard let values = snapshot.value as? [String:Any],
                          let isDone = values["Checked"] as? Bool,
                          let time = values["Time"] as? String else{return}

                    let currentSchedule = schedule(date: date, isDone: isDone, time: convertdate(content: time, format: "HH:mm"), user: user)
                    self.schedules.append(currentSchedule)
                }
        }

    }
}
