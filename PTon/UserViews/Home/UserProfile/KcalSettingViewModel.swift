//
//  KcalSettingViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/02/21.
//

import Foundation
import Firebase

class KcalSettingViewModel:ObservableObject{
    @Published var settingText:String = ""
    let reference = Database.database().reference()
    
    func uploadData(){
        guard let userid = FirebaseAuth.Auth.auth().currentUser?.uid else{return}
        
        if settingText != ""{
            reference
                .child("UserInfo")
                .child(userid)
                .child("kcalSetting")
                .setValue(settingText)
        }
    }
}
