//
//  ContentView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/03.
//

import SwiftUI
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin
import AuthenticationServices
import AlertToast

enum LoginType:Int{
    case kakao,naver,google,apple,none
}

struct LoginView: View {
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
                
                Button(action: {
                    self.loginViewModel.kakaoLogin()
                    
                }, label: {
                    Image("kakao")
                        .resizable()
                        .frame(width: 150, height: 40, alignment: .center)
                })

                Button(action: {
                    //TODO: 네이버 로그인 오류
                    
                    if NaverThirdPartyLoginConnection.getSharedInstance().isPossibleToOpenNaverApp(){
                        NaverThirdPartyLoginConnection.getSharedInstance().delegate = loginViewModel.self
                        NaverThirdPartyLoginConnection.getSharedInstance().requestThirdPartyLogin()
                    }else{
                        NaverThirdPartyLoginConnection.getSharedInstance().openAppStoreForNaverApp()
                    }
                }, label: {
                    Image("naver")
                        .resizable()
                        .frame(width: 150, height: 40, alignment: .center)
                })

                GoogleButton()
                    .frame(width: 150, height: 40, alignment: .center)
                    .onTapGesture {
                        print("Tapped Google Button")
                        UserDefaults.standard.set(LoginType.google.rawValue, forKey: "LoginApi")
                        loginViewModel.googleLogin()
                    }
                AppleLogin()
                    .frame(width: 150, height: 40, alignment: .center)
                    .onTapGesture {
                        print("Tapped Apple Login")
                        UserDefaults.standard.set(LoginType.apple .rawValue, forKey: "LoginApi")
                        loginViewModel.AppleLogin()
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
        .navigationViewStyle(.stack)
        .onAppear {
            self.loginViewModel.AutoLogin(loginApi: loginApi)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
