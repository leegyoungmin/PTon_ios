//
//  Model+RequestStretchingViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/17.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

//MARK: MODEL

struct memberStretching:Hashable{
    var index:Int
    var isDone:Bool
    var video:Stretching
}

//MARK: VIEWMODEL
class RequestStretchingViewModel:ObservableObject{
    @Published var memberStretchings:[memberStretching] = []
    var currentDate:Date = Date(){
        willSet{
            objectWillChange.send()
        }
    }
    let stretchings:[Stretching] = Bundle.main.decode("Stretching.json")
    let reference = FirebaseDatabase.Database.database().reference()
    var trainerid:String
    var userid:String
    
    init(trainerid:String,userid:String){
        self.trainerid = trainerid
        self.userid = userid
        fetchData()
    }
    
    func fetchData(){
        reference
            .child("MemberStretch")
            .child(userid)
            .child(convertDateToString(date: currentDate))
            .observe(.value) { snapshot in
                for child in snapshot.children{
                    let childsnap = child as! DataSnapshot
                    guard let value = childsnap.value as? Bool,
                          let index = Int(childsnap.key) else{return}
                    self.memberStretchings.append(memberStretching(index: index, isDone: value, video: self.stretchings[index]))
                }
            }
    }
    
    func reloadData(){
        self.memberStretchings.removeAll(keepingCapacity: true)
        reference
            .child("MemberStretch")
            .child(userid)
            .child(convertDateToString(date: self.currentDate))
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists(){
                    for child in snapshot.children{
                        let childsnap = child as! DataSnapshot
                        guard let value = childsnap.value as? Bool,
                              let index = Int(childsnap.key) else{return}
                        self.memberStretchings.append(memberStretching(index: index, isDone: value, video: self.stretchings[index]))
                    }
                }else{
                    self.memberStretchings = []
                }
            }
    }
}

extension RequestStretchingViewModel{
    func convertDateToString(date:Date)->String{
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
