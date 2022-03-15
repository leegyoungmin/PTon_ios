//
//  Error.swift
//  PTon
//
//  Created by 이경민 on 2022/02/07.
//

import Foundation
import SwiftUI
import AlertToast

//오류 종류
enum ValidationError:LocalizedError{
    case MissingUserType
    case MissingBirth
    case Missingsex
    case MissingPhone
    case MissingCorrect
    case MissingHeight
    case MissingWeight
    case MissingFat
    case MissingMuscle
    
    var errorDescription: String?{
        switch self {
        case .MissingUserType:
            return "사용자 구분을 선택해주세요."
        case .MissingBirth:
            return "생년월일을 올바르게 작성해주세요."
        case .Missingsex:
            return "성별을 올바르게 작성해주세요."
        case .MissingPhone:
            return "핸드폰 번호를 올바르게 작성해주세요."
        case .MissingCorrect:
            return "인증 코드를 올바르게 작성해주세요."
        case .MissingHeight:
            return "키를 입력해주세요."
        case .MissingWeight:
            return "몸무게를 입력해주세요."
        case .MissingFat:
            return "채지방률을 입력해주세요."
        case .MissingMuscle:
            return "골격근량을 입력해주세요."
        }
    }
}

//에러 모델
struct ErrorAlert:Identifiable{
    var id = UUID()
    var message:String
}

//에러 뷰모델
class ErrorHandling:ObservableObject{
    @Published var currentAlert:ErrorAlert?
    @Published var isshowAlert : Bool = false
    
    func handle(error:Error){
        currentAlert = ErrorAlert(message: error.localizedDescription)
        
        if currentAlert != nil{
            isshowAlert = true
        }
    }
}

//View Modifier
struct HandleErrorByShowingAlertViewModifier:ViewModifier{
    @StateObject var errorHandling = ErrorHandling()
    
    func body(content: Content) -> some View {
        content
            .environmentObject(errorHandling)
            .toast(isPresenting: $errorHandling.isshowAlert, alert: {
                AlertToast(displayMode: .banner(.pop), type: .error(.red), subTitle: errorHandling.currentAlert?.message)
            })
    }
}

extension View{
    func withErrorHandling()->some View{
        modifier(HandleErrorByShowingAlertViewModifier())
    }
}
