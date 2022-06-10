//
//  LoginPageView.swift
//  PTon
//
//  Created by 이경민 on 2022/06/09.
//

import Foundation
import SwiftUI

struct LoginPageView:View{
    @EnvironmentObject var authService:AuthService
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
                authService.validationKakaoToke()
            } label: {
                kakaoShape()
                    .shadow(color: .gray.opacity(0.5), radius: 1, x: 0, y: 0)
            }
            
            Button {
                authService.GoogleLogin()
            } label: {
                GoogleShape()
                    .shadow(color: .gray.opacity(0.5), radius: 1, x: 0, y: 0)
            }
            .buttonStyle(.plain)
            
            Button {
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
        
    }
}


struct LoginPageView_previews:PreviewProvider{
    static var previews: some View{
        LoginPageView()
            
    }
}
