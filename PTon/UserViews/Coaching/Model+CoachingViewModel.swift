//
//  Model+CoachingViewModel.swift
//  PTon
//
//  Created by 이관형 on 2022/02/18.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase



//MARK: Coach Model
struct CoachModel: Codable, Hashable, Identifiable{
    var id = UUID().uuidString
    var exName: String
    var exUrl: String
    var exDone: Bool
    var exParameter: Double
    var exMinute: Int
    var exTime: Int
    var exWeight: Int
    var exSets: Int
    var exHydro: String
    
    init(exName: String, exUrl: String, exDone: Bool, exParameter: Double, exMinute: Int, exTime: Int, exWeight: Int, exSets: Int, exHydro: String){
        self.exName = exName
        self.exUrl = exUrl
        self.exDone = exDone
        self.exParameter = exParameter
        self.exMinute = exMinute
        self.exTime = exTime
        self.exWeight = exWeight
        self.exSets = exSets
        self.exHydro = exHydro
    }
}

class CoachViewModel : ObservableObject{
    @Published var savedAnAerobicList: [CoachModel] = []
    @Published var savedAerobicList: [CoachModel] = []
    @Published var savedFitnessList: [CoachModel] = []
    @Published var savedCompoundList: [CoachModel] = []
    let uid: String
    init(){
        uid = Auth.auth().currentUser!.uid
    }

    func getExercise(part: String, date: String, isFitness: Bool, trainerId: String){
        self.savedAnAerobicList.removeAll()
        self.savedAerobicList.removeAll()
        self.savedFitnessList.removeAll()
        self.savedCompoundList.removeAll()
        print("getExericse TrainerId::::\(trainerId)")
        
        //피트니스 인지 아닌지 먼저 구분
        if isFitness{
            //Action FitnessFunction
            getExerciseFitness(date: date, trainerId: trainerId)
        }
        else{
            //AnAerobic
            if (part != "Compound") && (part != "Aerobic")
            {
                //Action CommonFunction
                getExerciseAnAerobic(part: part, date: date, trainerId: trainerId)
            }
            //Aerobic
            else if part == "Aerobic"
            {
                
            }
            //Compound
            else if part == "Compound"
            {
                print("part is Compound")
                getExerciseCompound(date: date, trainerId: trainerId)
            }

        }
    }
    
    //FitnessTab 저장된 운동 가져오기
    func getExerciseFitness(date: String, trainerId: String){
        
        let TAG = "Function getExerciseFitness"
        print(TAG)
        //Fitness DB Route
        let fitnessRef = Database.database().reference().child("RequestExercise")
            .child(trainerId).child(self.uid).child(date).child("Fitness")
        
        print("FitnessStart")
        
        fitnessRef.observe(.value, with: { fitnessShot in
            if fitnessShot.hasChildren()
            {
                print("StartRoute")
                let values = fitnessShot.value
                if values != nil
                {
                    let aerobicDic = values as! [String: [String: Any]]
                    for index in aerobicDic
                    {
                        if index.value["Hydro"] as! String == "Aerobic"
                        {
                            let model = CoachModel(
                                exName: index.key,
                                exUrl: index.value["Url"] as! String,
                                exDone: index.value["Done"] as! Bool,
                                exParameter: index.value["Parameter"] as! Double,
                                exMinute: index.value["Minute"] as! Int,
                                exTime: 0,
                                exWeight: 0,
                                exSets: 0,
                                exHydro: index.value["Hydro"] as! String)
                            self.savedFitnessList.append(model)
                        }
                        else
                        {
                            let model = CoachModel(
                                exName: index.key,
                                exUrl: index.value["Url"] as! String,
                                exDone: index.value["Done"] as! Bool,
                                exParameter: index.value["Parameter"] as! Double,
                                exMinute: index.value["Minute"] as? Int ?? 1,
                                exTime: index.value["Time"] as! Int,
                                exWeight: index.value["Weight"] as! Int,
                                exSets: index.value["Set"] as! Int,
                                exHydro: index.value["Hydro"] as! String)
                            self.savedFitnessList.append(model)
                        }
                        
                    }
                    
                }
            }else
            {
                print(TAG + "::Fitness Data Doesn't Exist")
            }
        })
        
    }
    func getExerciseAnAerobic(part: String, date: String, trainerId: String){
        
        let TAG = "Function getExerciseAnAerobic"
        let anAerobicRef = Database.database().reference().child("RequestExercise")
            .child(trainerId).child(self.uid).child(date).child("AnAerobic").child(part)
        
        anAerobicRef.observe(.value, with: { anAerobicSnap in
            if anAerobicSnap.hasChildren()
            {
                let values = anAerobicSnap.value
                if values != nil
                {
                    let dic = values as! [String: [String: Any]]
                    for index in dic
                    {
                        let model = CoachModel(
                            exName: index.key,
                            exUrl: index.value["Url"] as! String,
                            exDone: index.value["Done"] as! Bool,
                            exParameter: index.value["Parameter"] as? Double ?? 1.0,
                            exMinute: index.value["Minute"] as! Int,
                            exTime: index.value["Time"] as! Int,
                            exWeight: index.value["Weight"] as! Int,
                            exSets: index.value["Set"] as! Int,
                            exHydro: index.value["Hydro"] as? String ?? "AnAerobic")
                        self.savedAnAerobicList.append(model)
                    }
                }
            }
            else
            {
                print(TAG + ":: AnAerobic Data Doesn't Exist")
            }
        })
    }
    
    func getExerciseCompound(date: String, trainerId: String){
        let TAG = "Function getExerciseCompound"
        let compoundRef = Database.database().reference().child("RequestExercise")
            .child(trainerId).child(self.uid).child(date).child("AnAerobic").child("Compound")
        
        compoundRef.observe(.value, with: {compoundSnap in
            if compoundSnap.hasChildren()
            {
                let values = compoundSnap.value
                if values != nil
                {
                    let dic = values as! [String: [String: Any]]
                    for index in dic
                    {
                        let model = CoachModel(
                            exName: index.key,
                            exUrl: index.value["Url"] as! String,
                            exDone: index.value["Done"] as! Bool,
                            exParameter: index.value["Parameter"] as? Double ?? 1.0,
                            exMinute: index.value["Minute"] as! Int,
                            exTime: index.value["Time"] as! Int,
                            exWeight: index.value["Weight"] as! Int,
                            exSets: index.value["Set"] as! Int,
                            exHydro: index.value["Hydro"] as? String ?? "Compound")
                        self.savedCompoundList.append(model)
                    }
                }
                else
                {
                    print(TAG + ":: Compound Data Doesn't Exist")
                }
            }
        })
    }
}
