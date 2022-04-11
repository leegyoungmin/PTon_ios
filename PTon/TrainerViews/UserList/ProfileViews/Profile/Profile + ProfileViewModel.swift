//
//  Profile + ProfileViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/08.
//

import Foundation
import Firebase

struct memberShip:Codable,Hashable{
    var startMember:Date?
    var endMember:Date?
    var maxLisence:String?
    var useLisence:String?
    
    var IntMaxLisense:Int{
        guard let maxLisence = maxLisence else {
            return 0
        }

        return Int(maxLisence) ?? 0
    }
    
    var IntuserLisence:Int{
        guard let useLisence = useLisence else {
            return 0
        }
        
        return Int(useLisence) ?? 0

    }
    
}

class ProfileViewModel:ObservableObject{
    let TAG = "FETCH PROFILEVIEWMODEL - "
    @Published var result = surveyResult(allKcal: "", carboKcal: "", carboGram: "", fatKcal: "", fatGram: "", proteinKcal: "", proteinGram: "")
    @Published var MemberShip = memberShip()
    
    let traineid:String
    let fitnessCode:String
    let trainee:trainee
    
    let reference = Firebase.Database.database().reference().child("Membership")
    
    init(_ trainerid:String,_ fitnessCode:String,_ trainee:trainee){
        self.traineid = trainerid
        self.fitnessCode = fitnessCode
        self.trainee = trainee
        
        fetchMemberShip()
        observeSurvey()
    }
    
    
    func fetchMemberShip(){
        reference
            .child(trainee.userId)
            .observe(.value) { snapshot in
                print(self.TAG + "\(snapshot)")
                
                if snapshot.exists(){
                    let values = snapshot.value as! [String:Any]
                    
                    if snapshot.hasChild("StartDate"){
                        guard let startDate = values["StartDate"] as? String else{return}
                        self.MemberShip.startMember = convertdate(content: startDate, format: "yyyy-MM-dd")
                    }
                    
                    if snapshot.hasChild("EndDate"){
                        guard let endDate = values["EndDate"] as? String else{return}
                        self.MemberShip.endMember = convertdate(content: endDate, format: "yyyy-MM-dd")
                    }
                    
                    if snapshot.hasChild("ptTimes"){
                        guard let maxLisence = values["ptTimes"] as? String else{return}
                        self.MemberShip.maxLisence = maxLisence
                    }
                    
                    if snapshot.hasChild("ptUsed"){
                        guard let useLisence = values["ptUsed"] as? String else{return}
                        self.MemberShip.useLisence = useLisence
                    }
                }
            }
    }
    
    func observeSurvey(){
        Database.database().reference()
            .child("Ingredient")
            .child(self.trainee.userId)
            .observe(.value, with: { snapshot in
                if snapshot.exists(){
                    guard let values = snapshot.value as? [String:[String:Any]] else{return}
                    
                    if let all = values["AllKcal"]{
                        let allkcal = all["Kcal"] as? String
                        self.result.allKcal = allkcal ?? ""
                    }
                    
                    if let carbo = values["Carbohydrate"]{
                        self.result.carboGram = carbo["gram"] as? String ?? ""
                        self.result.carboKcal = carbo["Kcal"] as? String ?? ""
                    }
                    
                    if let protein = values["Protein"]{
                        self.result.proteinKcal = protein["Kcal"] as? String ?? ""
                        self.result.proteinGram = protein["gram"] as? String ?? ""
                    }
                    
                    if let fat = values["Fat"]{
                        self.result.fatKcal = fat["Kcal"] as? String ?? ""
                        self.result.fatGram = fat["gram"] as? String ?? ""
                    }
                }
            })
                
    }
    
    func setDateData(_ data:[String:String]){
        reference
            .child(trainee.userId)
            .updateChildValues(data)
    }
    
    func setLisenceData(_ data:[String:String]){
        reference
            .child(trainee.userId)
            .updateChildValues(data)
    }
}
