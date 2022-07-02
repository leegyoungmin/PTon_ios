//
//  LoginPageView.swift
//  PTon
//
//  Created by 이경민 on 2022/06/09.
//

import Foundation
import SwiftUI

enum userType:String,CaseIterable{
    case trainer,user
}

struct LoginPageView:View{
    @EnvironmentObject var authService:AuthService
    @State var userType:userType?
    var body: some View{
        VStack{
            HStack{
                Spacer()
                Image("defaultImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: .center)
                    .controlSize(.large)
                Spacer()
            }
            .padding(.top,100)

            Spacer()
            
            Button {
                authService.authType = "Kakao"
                authService.validationKakaoToke()
            } label: {
                kakaoShape()
                    .shadow(color: .gray.opacity(0.5), radius: 1, x: 0, y: 0)
            }
            
            Button {
                
                authService.authType = "Google"
                authService.GoogleLogin()
            } label: {
                GoogleShape()
                    .shadow(color: .gray.opacity(0.5), radius: 1, x: 0, y: 0)
            }
            .buttonStyle(.plain)
            
            Button {
                authService.authType = "Apple"
                authService.AppleLogin()
            } label: {
                AppleShape()
                    .shadow(color: .gray.opacity(0.5), radius: 1, x: 0, y: 0)
            }
            
            Spacer()
        }
        .background(
            LinearGradient(colors: [.gray.opacity(0.5),.accentColor.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
        )
        .fullScreenCover(isPresented: $authService.isNewUser,onDismiss: {
            authService.ChangeState()
        }) {
            BaseInformationPage(viewModel: BaseInfoViewModel(userId: authService.userId(),
                                                             userName: authService.userName(),
                                                             email: authService.getuserEmail(),
                                                             loginApi: authService.getauthType())
                                ,dismissCurrent: $authService.isNewUser
            )
        }
    }
}


struct LoginPageView_previews:PreviewProvider{
    static var previews: some View{
        LoginPageView()
            
    }
}
