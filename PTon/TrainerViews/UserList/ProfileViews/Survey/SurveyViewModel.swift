//
//  SurveyViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/11.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct surveyResult{
    var allKcal:String
    var carboKcal:String
    var carboGram:String
    var fatKcal:String
    var fatGram:String
    var proteinKcal:String
    var proteinGram:String
}

class SurveyViewModel:ObservableObject{
    @Published var userScore = 0
    var isExist = false
    var trainerid:String
    var userid:String
    var age:String?
    var gender:String?
    var weight:String?
    var height:String?
    
    let reference = FirebaseDatabase.Database.database().reference()
    
    init(_ trainerid:String,_ userid:String){
        self.trainerid = trainerid
        self.userid = userid
        getBaseData()
    }
    func getBaseData(){
        
        
        reference
            .child("User")
            .child(self.userid)
            .observeSingleEvent(of: .value) { snapshot in
                guard let snapage = snapshot.childSnapshot(forPath: "age").value as? String,
                      let snapsex = snapshot.childSnapshot(forPath: "gender").value as? String else {return}
                
                self.age = snapage
                self.gender = snapsex
            }
        
        reference
            .child("UserInfo")
            .child(self.userid)
            .observeSingleEvent(of: .value) { snapshot in
                guard let snapHeight = snapshot.childSnapshot(forPath: "height").value as? String,
                      let snapWeight = snapshot.childSnapshot(forPath: "weight").value as? String else{return}
                
                self.weight = snapWeight
                self.height = snapHeight
            }
        
        
    }
    
    func SaveDataBase(_ result:Int){
        let userType = getUserType(result: result)
        let constitutionJudgeCarbo = ConstitutionJudge(UserType: userType, GetType: .Carbo)
        let constitutionJudgeFat = ConstitutionJudge(UserType: userType, GetType: .Fat)
        
        guard let sex = StringToInt(self.gender!),
              let age = StringToInt(self.age!),
              let Weight = StringToDouble(self.weight!),
              let Height = StringToDouble(self.height!) else{return}
        
        
        let UserTDEEKcal = getTDEE(sex: sex, age: age, Weight: Weight, Height: Height)
        
        let Carbo = constitution_Carbo(TDEE: UserTDEEKcal, Carbo: constitutionJudgeCarbo)
        let Protein = constitution_Protin(Weight: Weight)
        let Fat = constitution_Fat(TDEE: UserTDEEKcal, Fat: constitutionJudgeFat)
        
        let AllKcal = Carbo["Kcal"]! + Protein["Kcal"]! + Fat["Kcal"]!
        
        reference
            .child("Ingredient")
            .child(self.userid)
            .child("AllKcal")
            .updateChildValues(["Kcal":"\(AllKcal)"])
        
        for (key,value) in Carbo{
            
            reference
                .child("Ingredient")
                .child(self.userid)
                .child("Carbohydrate")
                .updateChildValues([key:"\(value)"])
        }
        
        for (key,value) in Protein{
            reference
                .child("Ingredient")
                .child(self.userid)
                .child("Protein")
                .updateChildValues([key:"\(value)"])
        }
        
        for (key,value) in Fat{
            
            reference
                .child("Ingredient")
                .child(self.userid)
                .child("Fat")
                .updateChildValues([key:"\(value)"])
        }
    }
    
    
    func getResult(type:String,result:Int)->String{
        var resultString = ""
        let userType = getUserType(result: result)
        let constitutionJudgeCarbo = ConstitutionJudge(UserType: userType, GetType: .Carbo)
        let constitutionJudgeFat = ConstitutionJudge(UserType: userType, GetType: .Fat)
        
        guard let sex = StringToInt(self.gender!),
              let age = StringToInt(self.age!),
              let Weight = StringToDouble(self.weight!),
              let Height = StringToDouble(self.height!) else{return resultString}
        
        
        let UserTDEEKcal = getTDEE(sex: sex, age: age, Weight: Weight, Height: Height)
        
        let Carbo = constitution_Carbo(TDEE: UserTDEEKcal, Carbo: constitutionJudgeCarbo)
        let Protein = constitution_Protin(Weight: Weight)
        let Fat = constitution_Fat(TDEE: UserTDEEKcal, Fat: constitutionJudgeFat)
        
        let AllKcal = Carbo["Kcal"]! + Protein["Kcal"]! + Fat["Kcal"]!
        
        if type == "All"{
            resultString = String(format: "%.2f", AllKcal)
        }
        
        if type == "Carbo"{
            resultString = DataToString(Carbo, Type: "Carbo")
        }
        
        if type == "Protein"{
            resultString = DataToString(Protein, Type: "Protein")
        }
        
        if type == "Fat"{
            resultString = DataToString(Fat, Type: "Fat")
        }
        return resultString
    }
    
    func DataToString(_ inputDictionart:[String:Double], Type:String)->String{
        guard let kcal = inputDictionart["Kcal"],
              let gram = inputDictionart["gram"] else{
            return ""
        }
        switch Type{
        case "Carbo":
            return "적정 탄수화물 섭취량은 \(String(format: "%.2f", kcal))Kcal 이며, \(String(format: "%.2f", gram))g을 섭취해야 합니다.\n"
        case "Protein":
            return "적정 단백질 섭취량은 \(String(format: "%.2f", kcal))Kcal 이며, \(String(format: "%.2f", gram))g을 섭취해야 합니다.\n"
        case "Fat":
            return "적정 지방 섭취량은 \(String(format: "%.2f", kcal))Kcal 이며, \(String(format: "%.2f", gram))g을 섭취해야 합니다.\n"
        default:
            return ""
        }
    }
    
    func getUserType(result:Int)->UserEatType{
        print("User result ::: \(result)")
        if result<0{
            return .carbo
        }
        else if result == 0{
            return .hybrid
        }
        else{
            return .protin
        }
    }
    
    func ConstitutionJudge(UserType:UserEatType,GetType:GetType)->Double{
        switch UserType {
        case .carbo:
            switch GetType {
            case .Carbo:
                return 0.7
            case .Fat:
                return 0.1
            }
        case .hybrid:
            switch GetType {
            case .Carbo:
                return 0.5
            case .Fat:
                return 0.1
            }
        case .protin:
            switch GetType {
            case .Carbo:
                return 0.35
            case .Fat:
                return 0.2
            }
        }
    }
    
    
    func getBMR(sex:Int,age:Int,Weight:Double,Height:Double)->Double{
        var BMR:Double
        switch sex{
        case 0:
            BMR = 88.362+(13.397*Weight)+(4.799*Height)-(5.677*Double(age))
            return BMR
        case 1:
            BMR = 477.593+(9.247*Weight)+(3.098*Height)-(4.330*Double(age))
            return BMR
        default:
            return 0
        }
    }
    
    func getTEF(sex:Int,age:Int,Weight:Double,Height:Double)->Double{
        let REE = getBMR(sex: sex, age: age, Weight: Weight, Height: Height)
        let TEF = REE/10
        return TEF
    }
    
    func getNEAT()->Int{
        return 450
    }
    
    
    func getTDEE(sex:Int,age:Int,Weight:Double,Height:Double)->Double{
        let BMR = getBMR(sex: sex, age: age, Weight: Weight, Height: Height)
        let TEF = getTEF(sex: sex, age: age, Weight: Weight, Height: Height)
        let NEAT = Double(getNEAT())
        let TDEE = BMR + TEF + 250 + NEAT
        return TDEE
    }
    
    func constitution_Carbo(TDEE:Double,Carbo:Double)->[String:Double]{
        let Carbo_Kcal = TDEE * Carbo
        let Carbo_gram = Carbo_Kcal/4;
        let CarboResult = ["Kcal":Carbo_Kcal,"gram":Carbo_gram]
        return CarboResult
    }
    
    func constitution_Protin(Weight:Double)->[String:Double]{
        let Protin_gram = Weight
        let Protin_Kcal = Protin_gram * 4
        let ProtinResult = ["Kcal":Protin_Kcal,"gram":Protin_gram]
        return ProtinResult
    }
    
    func constitution_Fat(TDEE:Double,Fat:Double)->[String:Double]{
        let Fat_Kcal = TDEE * Fat
        let Fat_gram = Fat_Kcal/9
        let FatResult = ["Kcal":Fat_Kcal,"gram":Fat_gram]
        return FatResult
    }
}


enum UserEatType:String{
    case carbo = "탄수화물형"
    case hybrid = "하이브리드형"
    case protin = "단백질형"
}
enum GetType{
    case Carbo
    case Fat
}

extension SurveyViewModel{
    private func StringToInt(_ inputString:String)->Int?{
        return Int(inputString)
    }
    
    private func StringToDouble(_ inputString:String)->Double?{
        return Double(inputString)
    }
    
    
}
