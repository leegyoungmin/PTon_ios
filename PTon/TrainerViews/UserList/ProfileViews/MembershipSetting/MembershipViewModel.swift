//
//  MembershipViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/14.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

//MARK: VIEWMODEL
class MembershipViewModel:ObservableObject{
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var Times = 0
    @Published var usedTimes = 0
    let reference = FirebaseDatabase.Database.database().reference()
    
    var trainerid:String
    var userid:String
    
    init(trainerid:String,userid:String){
        self.trainerid = trainerid
        self.userid = userid
        
    }
    
    func fetchData(){
        print("fetch Data")
    }
    
    func SaveData(){
        let values = [
            "EndDate":convertDate(endDate),
            "StartDate":convertDate(startDate),
            "ptTimes":"\(Times)",
            "ptUsed":"\(usedTimes)"
        ]
        reference
            .child("Membership")
            .child(userid)
            .setValue(values)
        
    }
}


extension MembershipViewModel{
    func convertDate(_ date:Date)->String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
