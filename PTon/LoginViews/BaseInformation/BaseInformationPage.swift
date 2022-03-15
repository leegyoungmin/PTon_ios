//
//  BaseInformationPage.swift
//  PTon
//
//  Created by 이경민 on 2022/02/04.
//

import SwiftUI
import AlertToast

struct BaseInformationPage: View {
    @StateObject var baseViewModel:BaseViewModel
    @EnvironmentObject var errorhandle:ErrorHandling
    @State var trainerToggle:Bool = false
    @State var userToggle:Bool = false
    @State var isCorrectCode:Bool = false
    @State var isTappedAuth:Bool = false
    @State var baseString:String = "••••••"
    @State var sexString:String = ""
    @State var isShowErrorMessage:Bool = false
    @State var isNavigateUserPage:Bool = false
    @Binding var LoginViewPage:Bool

    var body: some View {
        //사용자 정의 바인딩 생성
        let trainerBinding = Binding(get: {self.trainerToggle},
                                     set: {
            self.trainerToggle = $0
            
            if $0 == true{
                self.userToggle = false
            }
        })
        //사용자 정의 바인딩 생성
        let userBinding = Binding(get: {self.userToggle}, set: {
            self.userToggle = $0
            
            if $0 == true{
                self.trainerToggle = false
            }
        })
        
        let sexBinding = Binding(get: {self.sexString}, set: {
            self.sexString = String($0.prefix(2))
        })
        
        VStack{
            HStack{
                Text("회원 가입")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.top,30)
            .padding(.bottom,10)

            VStack{
                titleView("회원 구분")
                
                VStack{
                    Toggle(isOn: trainerBinding) {
                        Text("트레이너")
                            .foregroundColor(.black)
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .toggleStyle(CheckBoxStyle())
                    
                    Toggle(isOn: userBinding) {
                        Text("유저")
                            .foregroundColor(.black)
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .toggleStyle(CheckBoxStyle())
                    
                }
                .padding(.horizontal)
            }//MARK: 회원 구분
            VStack{
                titleView("생년 월일")
                
                HStack{
                    TextField("", text: $baseViewModel.birthDay)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: UIScreen.main.bounds.width*0.4)
                    
                    Text("-")
                        .foregroundColor(.black)
                        .font(.body)
                        .fontWeight(.medium)
                        .frame(width: UIScreen.main.bounds.width*0.1)
                    
                    TextField("", text: sexBinding)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: UIScreen.main.bounds.width*0.1)
                    
                    SecureField("", text: $baseString)
                        .font(.system(size: 20))
                        .textFieldStyle(.plain)
                        .frame(width: UIScreen.main.bounds.width*0.2)
                        .allowsHitTesting(false)
                }
                .padding(.horizontal)
            }//MARK: 생년 월일
            VStack{
                titleView("핸드폰 번호")
                HStack{
                    TextField("", text: $baseViewModel.phoneNumber)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)
            }
            VStack{
                titleView("회원 코드")
                HStack{
                    TextField("", text: $baseViewModel.centerCode)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        self.baseViewModel.validUserCode { iscorrect in
                            self.isTappedAuth = true
                            if iscorrect == true{
                                self.isCorrectCode = iscorrect
                            }
                        }
                    } label: {
                        Text("인증하기")
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.purple)
                    
                }
                .padding(.horizontal)
                
                HStack{
                    if isTappedAuth{
                        Text(isCorrectCode ? "인증 완료되었습니다.":"회원 코드를 확인해주세요.")
                            .foregroundColor(isCorrectCode ? .blue:.red)
                            .font(.system(size: 15))
                    }
                    else{
                        EmptyView()
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
            }//MARK: 회원 코드
            
            Button {
                self.baseViewModel.setData(self.trainerToggle, self.sexString) {
                    self.baseViewModel.upLoadDataBase {
                        do{
                            try validate()
                            
                            if trainerToggle == true{
                                self.LoginViewPage = false
                                self.isNavigateUserPage = false
                            }else{
                                self.isNavigateUserPage = true
                            }
                        }catch{
                            errorhandle.handle(error: error)
                        }
                    }
                }
            } label: {
                HStack{
                    Text("회원가입")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 25))
                }
                .padding(.vertical,8)
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(lineWidth: 2)
                )
            }
            .padding()
            Spacer()
        }
        .fullScreenCover(isPresented: $isNavigateUserPage,onDismiss: {
            self.LoginViewPage = false
        }){
            BodyInfoPage(isNavigatePast: $isNavigateUserPage, userName: self.baseViewModel.BaseinfoModel.name!, userEmail: self.baseViewModel.BaseinfoModel.email!)
                .withErrorHandling()
        }
        .padding()

    }
}

func titleView(_ title:String)->some View{
    return HStack{
        Text(title)
            .foregroundColor(.black)
            .font(.title2)
            .fontWeight(.semibold)
        Spacer()
    }
}

struct CheckBoxStyle:ToggleStyle{
    func makeBody(configuration: Configuration) -> some View {
        return HStack{
            configuration.label
            
            Spacer()
            
            Image(systemName: configuration.isOn ? "checkmark.circle.fill":"circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(configuration.isOn ? .purple:.gray)
                .font(.system(size: 20,weight: .bold,design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

struct BaseInformationPage_Previews: PreviewProvider {
    static var previews: some View {
        BaseInformationPage(baseViewModel: BaseViewModel("이경민", "cow970814@naver.com"), LoginViewPage: .constant(true))
            .withErrorHandling()
    }
}


extension BaseInformationPage{
    //MARK: 각 데이터별 오류 검사 후 throw 메소드
    func validate() throws{
        if self.trainerToggle == false && self.userToggle == false{
            throw ValidationError.MissingUserType
        }
        else if baseViewModel.birthDay.count != 6{
            throw ValidationError.MissingBirth
        }
        else if !(self.sexString == "1" || self.sexString == "2" || self.sexString == "3" || self.sexString == "4"){
            throw ValidationError.Missingsex
        }
        else if self.baseViewModel.phoneNumber.count != 11{
            throw ValidationError.MissingPhone
        }
        else if isCorrectCode == false{
            throw ValidationError.MissingCorrect
        }
    }
}

