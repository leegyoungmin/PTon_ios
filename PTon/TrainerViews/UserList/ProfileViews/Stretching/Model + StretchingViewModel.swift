//
//  StretchingViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/13.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

//MARK: MODEL
struct trainerStretching:Hashable{
    var index:Int
    var Checked:Bool
    var video:Stretching
}

//MARK: VIEWMODEL
class StretchingViewModel:ObservableObject{
    var trainerid:String
    var userid:String
    
    @Published var selectedDay = Date()
    @Published var trainerList:[trainerStretching] = []
    let reference = FirebaseDatabase.Database.database().reference()
    
    init(trainerid:String,userid:String){
        self.trainerid = trainerid
        self.userid = userid
        resetData()
        fetchData(date: Date())
    }
    
    func setTrainerStretching(completion:@escaping()->Void){
        let baseRef = reference
            .child("Stretch")
            .child(self.trainerid)
            .child(self.userid)
            .child(convertDateToString(date: selectedDay))
        
        var trainervalues:[String:Bool] = [:]
        self.trainerList.forEach{
            trainervalues["\($0.index)"] = $0.Checked
        }
        
        baseRef.setValue(trainervalues) { error, ref in
            if error == nil{
                self.setUserStretching {
                    completion()
                }
            }
        }
    }
    
    func setUserStretching(completion:@escaping()->Void){
        let baseRef = reference.child("MemberStretch").child(self.userid).child(convertDateToString(date: selectedDay))
        
        var userValues:[String:Bool] = [:]
        let userList = self.trainerList.filter{$0.Checked == true}
        userList.forEach{
            userValues["\($0.index)"] = false
        }
        baseRef.setValue(userValues) { error, ref in
            if error == nil{
                completion()
            }
        }
    }
    func fetchData(date:Date){
        reference
            .child("Stretch")
            .child(self.trainerid)
            .child(self.userid)
            .child(convertDateToString(date: date))
            .observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists(){
                    for child in snapshot.children{
                        let childsnap = child as! DataSnapshot
                        
                        guard let childvalue = childsnap.value as? Bool,
                              let childkey = Int(childsnap.key) else {return}
                        
                        self.trainerList[childkey].Checked = childvalue
                    }
                }else{
                    self.trainerList.removeAll(keepingCapacity: true)
                    self.resetData()
                }
            })
    }
    
    func resetData(){
        let stretchings:[Stretching] = Bundle.main.decode("Stretching.json")
        for (key,value) in stretchings.enumerated(){
            self.trainerList.append(trainerStretching(index: key, Checked: false, video: value))
        }
    }
}


extension StretchingViewModel{
    func convertDateToString(date:Date)->String{
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    func convertShowDate(date:Date)->String{
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}
