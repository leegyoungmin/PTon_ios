//
//  ChattingImageViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/11.
//

import Foundation
import Firebase
import SDWebImageSwiftUI
import SDWebImage

class ChattingImageViewModel:ObservableObject{
    let path:String
    let trainerId:String
    let userId:String
    let fitnessCode:String
    init(_ path:String,_ trainerId:String,_ userId:String,_ fitnessCode:String){
        self.path = path
        self.trainerId = trainerId
        self.userId = userId
        self.fitnessCode = fitnessCode
    }
}
