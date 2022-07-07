//
//  BaseInfoViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/06/22.
//

import Foundation
import Combine
import Firebase


struct BaseInfo:Codable{
    var age:String?
    var birthDay:String?
    var birthYear:String?
    var gender:String?
    var email:String?
    var fitnessCode:String?
    var loginApi:String?
    var name:String?
    var phone:String?
    var status:String? = "offline"
    let trainee:String? = "default"
    var uid:String?
    
    enum CodingKeys:String,CodingKey{
        case age
        case birthDay = "birthday"
        case birthYear = "birthyear"
        case gender
        case email
        case fitnessCode
        case loginApi
        case name
        case phone
        case status
        case trainee
        case uid
    }
}

enum FitnessCodeValidation:Error{
    case notContains
    case shortCount
    case success
    
    var description:String{
        switch self{
        case .notContains:
            return "지정되지 않은 코드 입니다. 센터에 문의하세요."
        case .shortCount:
            return "6자리의 인증 코드를 입력해주세요."
        case .success:
            return "인증 완료되었습니다."
        }
    }
}

class BaseInfoViewModel:ObservableObject{
    @Published var isTrainer:Bool?
    @Published var fitnessCode:String = ""
    @Published var secretCode:String = "••••••"
    @Published var sexString:String = ""
    @Published var birthDay:String = ""
    @Published var phoneNumber:String = ""
    @Published var info:BaseInfo = BaseInfo()
    @Published var fitnessCodeValidation:FitnessCodeValidation?
    @Published var isSuccessUpLoad:Bool = false
    
    private var cancellable = Set<AnyCancellable>()
    
    init(userId:String,userName:String,email:String,loginApi:String){
        info.uid = userId
        info.name = userName
        info.email = email
        info.loginApi = loginApi
    }
    
    func validationFitnessCode(){
        
        if fitnessCode.count < 6{
            fitnessCodeValidation = .shortCount
            return
        }
        
        Firebase.Database.database().reference()
            .child("fitness")
            .observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self else{return}
                snapshot.children.forEach { child in
                    let childSnapshot = child as! DataSnapshot
                    if childSnapshot.value as? String != self.fitnessCode{
                        self.fitnessCodeValidation = .notContains
                    }else{
                        self.fitnessCodeValidation = .success
                        self.info.fitnessCode = self.fitnessCode
                        return
                    }
                }
            }
    }
    
    func validationPhone()->Bool{
        return phoneNumber.cleanMobileNumberFormat().isValidWith(regex: String.RegexType.mobilePhoneNumber)
    }
    
    func validationBirth()->Bool{
        return birthDay.isValidWith(regex: String.RegexType.birth)
    }
    
    func setPhoneNumber(){
        if validationPhone(){
            info.phone = phoneNumber.cleanMobileNumberFormat()
        }
    }
    
    
    func getBirthYear(){
        guard birthDay.count == 6 else{return}
        let startIndex = birthDay.index(birthDay.startIndex, offsetBy: 2)
        let rawValue = String(birthDay[..<startIndex])
        
        if rawValue.starts(with: "9"){
            self.info.birthYear = "19" + rawValue
        }else if rawValue.starts(with: "0") {
            self.info.birthYear = "20" + rawValue
        }
        
        self.getAge()
    }
    
    func getBirthDay(){
        guard birthDay.count == 6 else{return}
        let startIndex = birthDay.index(birthDay.startIndex, offsetBy: 2)
        var rawValue = String(birthDay[startIndex...])
        let index = rawValue.index(rawValue.startIndex, offsetBy: 2)
        rawValue.insert("-", at: index)
        self.info.birthDay = rawValue
    }
    
    func getAge(){
        guard let year = Int(self.info.birthYear ?? ""),
              let currentYear = Calendar.current.dateComponents([.year], from: Date()).year else{return}
        
        self.info.age = String(currentYear - year)

    }
    
    func setSex(){
        if sexString == "1" || sexString == "3"{
            self.info.gender = "0"
        }else if sexString == "2" || sexString == "4"{
            self.info.gender = "1"
        }

    }
    
    func validationUserBaseInfo()->Bool{
        return self.info.toDictionary?.keys.count == 12
    }
    
    func setupDataBase(completion:@escaping()->Void){
        guard let isTrainer = isTrainer,
              let userId = info.uid,
              var data = info.toDictionary else {
            return
        }

        if isTrainer{
            Firebase.Database.database().reference()
                .child("Trainer")
                .child(userId)
                .setValue(data) { _, _ in
                    completion()
                }
        }else{
            data.removeValue(forKey: "trainee")
            data["trainer"] = "default"
            data["photoUri"] = "default"
            Firebase.Database.database().reference()
                .child("User")
                .child(userId)
                .setValue(data) { _, _ in
                    completion()
                }
        }
    }
}

