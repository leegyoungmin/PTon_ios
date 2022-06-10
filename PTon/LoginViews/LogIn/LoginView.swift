//
//  ContentView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/03.
//

import SwiftUI
import KakaoSDKAuth
import KakaoSDKUser
//import NaverThirdPartyLogin
import AuthenticationServices
import AlertToast

enum LoginType:Int{
    case kakao,naver,google,apple,none
}

struct LoginView: View {
    @EnvironmentObject var authService:AuthService
    var rawValue:Int = UserDefaults.standard.integer(forKey: "LoginApi")
    @State var isNavigationUser:Bool = false
    @StateObject var loginViewModel = LoginViewModel()
    var loginApi:LoginType
    init(){
        self.loginApi = LoginType(rawValue: rawValue) ?? .none
    }
    var body: some View {
        NavigationView{

            VStack{
                
                Image("defaultImage")
                    .controlSize(.large)
                
                Button {
                    self.loginViewModel.validationKakaoToken()
                } label: {
                    kakaoShape()
                }
                
                Button {
                    UserDefaults.standard.set(LoginType.google.rawValue, forKey: "LoginApi")
                    self.loginViewModel.googleLogin()
                } label: {
                    GoogleShape()
                }
                .buttonStyle(.plain)
                
                Button {
                    UserDefaults.standard.set(LoginType.apple.rawValue, forKey: "LoginApi")
                } label: {
                    AppleShape()
                }

                NavigationLink(tag: true, selection:$loginViewModel.isTrainer) {
                    withAnimation {
                        TrainerBaseView()
                            .navigationTitle("")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarBackButtonHidden(true)
                    }

                } label: {
                    EmptyView()
                }

                NavigationLink(tag: false, selection: $loginViewModel.isTrainer) {
                    UserBaseView(UserBaseViewModel: UserBaseViewModel())
                        .navigationTitle("")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true)
                } label: {
                    EmptyView()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $loginViewModel.isNewUser,onDismiss: {
                self.loginViewModel.getUserType()
            }) {
                if loginViewModel.email != "" && loginViewModel.name != ""{
                    BaseInformationPage(baseViewModel: BaseViewModel(loginViewModel.name, loginViewModel.email),LoginViewPage: $loginViewModel.isNewUser)
                        .withErrorHandling()
                }

            }
            .toast(isPresenting: $loginViewModel.isShowLoading) {
                AlertToast(displayMode: .alert, type: .loading)
            }
        }
        .navigationBarHidden(true)
//        .onAppear {
//            self.loginViewModel.AutoLogin(loginApi: loginApi)
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
