//
//  ContentView.swift
//  PTon
//
//  Created by 이경민 on 2022/06/09.
//

import Foundation
import SwiftUI
import KakaoSDKAuth

struct ContentView:View{
    @StateObject var authService = AuthService()
    @ViewBuilder
    func userBaseView()->some View{
        if authService.usertype == .trainer{
            TrainerBaseView()
        } else if authService.usertype == .user{
            UserBaseView(UserBaseViewModel: UserBaseViewModel())
        } else{
            LoginPageView()
        }
    }
    var body: some View{
        Group{
            userBaseView()
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: .constant(authService.State == .signedOut)) {
            LoginPageView()
                .navigationBarTitleDisplayMode(.inline)
                .environmentObject(authService)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url){
                        AuthController.handleOpenUrl(url: url)
                    }
                }
        }
        .environmentObject(self.authService)
    }
}

struct TrainerExample:View{
    @EnvironmentObject var viewModel:AuthService
    var body: some View{
        VStack{
            Spacer()
            
            Text("Trainer")
            
            Text(viewModel.usertype == .trainer ? "False":"True")
            
            Button {
                viewModel.LogOut()
            } label: {
                Text("LogOut")
            }
            
            Spacer()
        }.font(.largeTitle)
        
    }
}

struct UserExample:View{
    @EnvironmentObject var viewModel:AuthService
    var body: some View{
        VStack{
            Spacer()
            
            Text("User")
            
            Text(viewModel.usertype == .trainer ? "False":"True")
            
            Button {
                viewModel.LogOut()
            } label: {
                Text("LogOut")
            }
            
            Spacer()
        }
        .font(.largeTitle)
    }
}

struct CotentView_preview:PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}
