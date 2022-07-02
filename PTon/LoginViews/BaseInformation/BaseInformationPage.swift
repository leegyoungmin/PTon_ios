//
//  BaseInformationPage.swift
//  PTon
//
//  Created by 이경민 on 2022/02/04.
//

import SwiftUI
import AlertToast

struct BaseInformationPage: View {
    @StateObject var viewModel:BaseInfoViewModel
    @State var isPresentBodyData:Bool = false
    @EnvironmentObject var errorhandle:ErrorHandling
    @Binding var dismissCurrent:Bool
    
    //MARK: - FUNCTIONS
    @ViewBuilder
    func titleView(_ title:String)->some View{
        HStack{
            Text(title)
                .font(.title.bold())
                .foregroundColor(.black)
            
            Spacer()
        }
    }
    var body: some View{
        NavigationView(content: {
            VStack(spacing:20){
                //회원 구분
                VStack(spacing:10){
                    titleView("회원 구분")
                    
                    VStack{
                        HStack{
                            Text("트레이너")
                            
                            Spacer()
                            
                            Button {
                                viewModel.isTrainer = true
                            } label: {
                                Image(systemName:viewModel.isTrainer == nil ?
                                      "circle":viewModel.isTrainer! == true ? "checkmark.circle":"circle")
                            }
                        }
                        
                        HStack{
                            Text("회원")
                            
                            Spacer()
                            
                            Button {
                                viewModel.isTrainer = false
                            } label: {
                                Image(systemName:viewModel.isTrainer == nil ?
                                      "circle":viewModel.isTrainer! == true ? "circle":"checkmark.circle")
                            }
                        }
                    }
                    .font(.title2)
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                
                //핸드폰 번호
                VStack{
                    titleView("핸드폰 번호")
                    
                    TextField("",text: $viewModel.phoneNumber,onEditingChanged: { _ in
                        viewModel.phoneNumber = viewModel.phoneNumber.formatMobileNumber()
                    })
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                    .padding(10)
                    .background(backgroundColor)
                    .cornerRadius(15)
                    .foregroundColor(.accentColor)
                    .font(.title2)
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                
                //생년월일
                VStack{
                    titleView("생년월일")
                    
                    HStack{
                        TextField("", text: $viewModel.birthDay)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.numberPad)
                            .padding(10)
                            .background(backgroundColor)
                            .cornerRadius(15)
                            .foregroundColor(.accentColor)
                            .font(.title2)
                            .onChange(of: viewModel.birthDay) { newValue in
                                viewModel.birthDay = String(newValue.prefix(6))
                            }
                            .multilineTextAlignment(.center)
                        
                        Text("-")
                            .font(.title)
                        
                        SecureField("", text: $viewModel.sexString)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.numberPad)
                            .padding(10)
                            .background(backgroundColor)
                            .cornerRadius(15)
                            .foregroundColor(.accentColor)
                            .font(.title2)
                            .onChange(of: viewModel.sexString) { newValue in
                                viewModel.sexString = String(newValue.prefix(1))
                            }
                            .frame(maxWidth:40)
                            .multilineTextAlignment(.center)
                        
                        Text(viewModel.secretCode)
                            .padding(5)
                            .font(.title)
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                
                VStack{
                    titleView("센터인증코드")
                    
                    HStack{
                        TextField("",text: $viewModel.fitnessCode)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                            .padding(10)
                            .background(backgroundColor)
                            .cornerRadius(15)
                            .foregroundColor(.accentColor)
                            .font(.title2)
                            .onChange(of: viewModel.fitnessCode) { newValue in
                                viewModel.fitnessCode = String(newValue.prefix(6))
                            }
                        
                        Button {
                            viewModel.validationFitnessCode()
                        } label: {
                            Text("인증하기")
                                .foregroundColor(.accentColor)
                        }
                    }
                    
                    if viewModel.fitnessCodeValidation != nil{
                        let result = viewModel.fitnessCodeValidation!
                        
                        if result == .success{
                            Text(result.description)
                                .foregroundColor(Color.accentColor)
                        }else{
                            Text(result.description)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                
                Spacer()
                
                Button {
                    viewModel.setPhoneNumber()
                    viewModel.getBirthDay()
                    viewModel.getBirthYear()
                    viewModel.setSex()
                    
                    if viewModel.validationUserBaseInfo(){
                        viewModel.setupDataBase {
                            if viewModel.isTrainer! == true{
                                dismissCurrent = false
                            }else{
                                isPresentBodyData = true
                            }
                        }
                    }
                } label: {
                    Text("회원가입")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.vertical,5)
                }
                .padding(5)
                .frame(width:UIScreen.main.bounds.width*0.8)
                .background(Color.accentColor)
                .cornerRadius(20)
                .disabled(viewModel.validationUserBaseInfo())
                
                NavigationLink(isActive: $isPresentBodyData) {
                    BodyInfoPage(dismissCurrentPage: $dismissCurrent)
                } label: {
                    EmptyView()
                }

            }
            .navigationTitle("공통 정보")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .background(backgroundColor.edgesIgnoringSafeArea(.all))
        })
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

struct BaseInformationPage_Previews: PreviewProvider {
    static var previews: some View {
        BaseInformationPage(viewModel: BaseInfoViewModel(userId: "asnjkansjd", userName: "이경민", email: "cow970814@naver.com", loginApi: "Kakao"), dismissCurrent: .constant(true))
            .withErrorHandling()
    }
}
