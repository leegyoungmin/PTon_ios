//
//  BaseViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/05.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

//MARK: MODEL
struct BaseInfoModel{
    var userType:userType = .user
    var age:String?
    var birthyear:String?
    var birthday:String?
    var email:String?
    var fitnessCode:String?
    var gender:String?
    var loginApi:String?
    var name:String?
    var phone:String?
    var photoUri:String = "default"
    var status:String = "offline"
    var trainer:String = "default"
    var uid:String?
}

enum userType:String,CaseIterable{
    case trainer,user,none
}


//MARK: VIEWMODEL
class BaseViewModel:ObservableObject{
    @Published var BaseinfoModel = BaseInfoModel()
    @Published var UserType:userType = .user
    @Published var phoneNumber:String = ""
    @Published var birthDay:String = ""
    @Published var centerCode:String = ""
    
    init(_ name:String,_ email:String){
        self.BaseinfoModel.email = email
        self.BaseinfoModel.name = name
    }
    
    var reference = FirebaseDatabase.Database.database().reference()
    
    //view에서 변화되는 값 세팅 함수
    func setData(_ trainerToggle:Bool,_ sexString:String,completion:@escaping ()->Void){

        self.BaseinfoModel.phone = phoneNumber
        self.BaseinfoModel.fitnessCode = centerCode
        
        if trainerToggle == true{
            self.BaseinfoModel.userType = .trainer
        }else{
            self.BaseinfoModel.userType = .user
        }
        
        if sexString == "1"||sexString == "3"{
            self.BaseinfoModel.gender = "0"
        }
        else if sexString == "2"||sexString == "4"{
            self.BaseinfoModel.gender = "1"
        }
        
        self.BaseinfoModel.birthday = getBirthDay(birthDay)
        self.BaseinfoModel.birthyear = getBirthYear(birthDay)
        self.BaseinfoModel.age = getAge(getBirthYear(birthDay))
        guard let UID = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        self.BaseinfoModel.uid = UID
        
        completion()
    }
    
    //데이터베이스 저장 메소드
    func upLoadDataBase(completion:@escaping ()->Void){
        guard let UID = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        var values:[String:Any?] = [
            "division":self.BaseinfoModel.userType.rawValue,
            "age":self.BaseinfoModel.age,
            "birthday":self.BaseinfoModel.birthday,
            "birthyear":self.BaseinfoModel.birthyear,
            "email":self.BaseinfoModel.email,
            "fitnessCode":self.BaseinfoModel.fitnessCode,
            "gender":self.BaseinfoModel.gender,
            "name":self.BaseinfoModel.name,
            "phone":self.BaseinfoModel.phone,
            "status":self.BaseinfoModel.status,
            "uid":UID
        ]
        
        //데이터베이스 회원 구분에 따른 저장 메소드
        if self.BaseinfoModel.userType == .trainer{
            
            reference.child("User").observeSingleEvent(of: .value) { snapshot in
                if snapshot.hasChild(UID){
                    snapshot.childSnapshot(forPath: UID).ref.removeValue()
                }
            }
            
            values["trainee"] = "default"
            
            reference.child("Trainer").child(UID).setValue(values){error,reference in
                if error == nil{
                    completion()
                }
            }
        }else{
            reference.child("Trainer").observeSingleEvent(of: .value) { snapshot in
                if snapshot.hasChild(UID){
                    snapshot.childSnapshot(forPath: UID).ref.removeValue()
                }
            }
            values["trainer"] = "default"
            reference.child("User").child(UID).setValue(values) { error, reference in
                if error == nil{
                    completion()
                }
            }
        }
    }
    
    //데이터베이스 코드 검사 메소드
    func validUserCode(completion:@escaping(Bool)->Void){
        if self.centerCode.count != 0{
            FirebaseDatabase.Database.database().reference()
                .child("Center")
                .observe(.value) { snapshot in
                    if snapshot.hasChild(self.centerCode){
                        completion(true)
                    }else{
                        completion(false)
                    }
                }
        }
    }
}

extension BaseViewModel{
    //출생년도 파싱 메소드
    func getBirthYear(_ birthday:String)->String{
        let startIndex = birthday.index(birthday.startIndex, offsetBy: 2)
        return String(birthday[..<startIndex])
    }
    
    //생일 파싱 메소드
    func getBirthDay(_ birthday:String)->String{
        let startIndex = birthday.index(birthday.startIndex, offsetBy: 2)
        return String(birthday[startIndex...])
    }
    
    //나이 구하는 메소드
    func getAge(_ birthyear:String)->String{
        var birth = Int(birthyear)
        if birth! < 22{
            birth = birth! + 2000
        }
        else{
            birth = birth! + 1900
        }
        
        let dob = DateComponents(calendar: .current ,year: birth).date!
        return String(dob.age)
    }
}


extension Date {
    var age: Int { Calendar.current.dateComponents([.year], from: self, to: Date()).year! }
}
