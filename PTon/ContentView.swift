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
    var body: some View{
        Group{
            if authService.usertype != nil{
                if authService.usertype == .user{
                    UserBaseView(UserBaseViewModel: UserBaseViewModel())
                        .navigationBarTitleDisplayMode(.inline)
                }else if authService.usertype == .trainer{
                    TrainerBaseView()
                        .navigationBarTitleDisplayMode(.inline)
                }
            }else{
                VStack{}
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $authService.isNotLogged) {
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
            
            Text(viewModel.isNotLogged ? "False":"True")
            
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
            
            Text(viewModel.isNotLogged ? "False":"True")
            
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
