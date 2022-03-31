//
//  Model + UserHomeMemberShipViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/31.
//

import Foundation
import Firebase

//MARK: - MODEL
struct userHomeMember:Codable{
    var startDate:String?
    var endDate:String?
    var ptTimes:String?
    var ptUsed:String?
}

//MARK: - VIEWMODE
class UserHomeMemberShipViewModel:ObservableObject{
    @Published var memberShip = userHomeMember()
    let reference = Firebase.Database.database().reference().child("Membership")
    init(){
        Observe()
    }
    
    var settingDate:[Int]{
        return calculateMonth()
    }
    var isExpirationNumber:Bool{
        return expirationNumber()
    }
    
    func Observe(){
        guard let userId = Firebase.Auth.auth().currentUser?.uid else{return}
        
        reference
            .child(userId)
            .observe(.value) { snapshot in
                if snapshot.exists(){
                    if snapshot.hasChild("EndDate"){
                        self.memberShip.endDate = snapshot.childSnapshot(forPath: "EndDate").value as? String
                    }
                    
                    if snapshot.hasChild("StartDate"){
                        self.memberShip.startDate = snapshot.childSnapshot(forPath: "StartDate").value as? String
                    }
                    
                    if snapshot.hasChild("ptTimes"){
                        self.memberShip.ptTimes = snapshot.childSnapshot(forPath: "ptTimes").value as? String
                    }
                    
                    if snapshot.hasChild("ptUsed"){
                        self.memberShip.ptUsed = snapshot.childSnapshot(forPath: "ptUsed").value as? String
                    }
                }
            }
    }
    
    func expirationNumber()->Bool{
        var expiration:Bool = false
        if memberShip.ptTimes != nil,memberShip.ptUsed != nil{
            expiration = (Int(memberShip.ptTimes!) ?? 1 <= Int(memberShip.ptUsed!) ?? 0)
        }
        return expiration
    }
    
    func expirationPeriod()->Int{
        var date1:Date = Date()
        if memberShip.startDate != nil,memberShip.endDate != nil{
            date1 = convertdate(content: memberShip.endDate!, format: "yyyy-MM-dd")
        }
        let distanceDay = Calendar.current.dateComponents([.day], from: Date(),to:date1).day ?? 1
        
        return distanceDay
    }
    
    func calculateMonth()->[Int]{
        var date1:Date = Date()
        var date2:Date = Date()
        if memberShip.startDate != nil,memberShip.endDate != nil{
            date1 = convertdate(content: memberShip.endDate!, format: "yyyy-MM-dd")
            date2 = convertdate(content: memberShip.startDate!, format: "yyyy-MM-dd")
        }
        
        let distanceMonth = Calendar.current.dateComponents([.month], from: date2, to: date1).month ?? 0
        let distanceDay = Calendar.current.dateComponents([.day], from: date2,to:date1).day ?? 0
        return [distanceMonth <= 0 ? 0:distanceMonth,distanceDay <= 0 ? 0:distanceDay]
    }
}
