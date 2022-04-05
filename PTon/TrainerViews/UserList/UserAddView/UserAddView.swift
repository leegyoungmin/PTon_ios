//
//  UserAddView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/08.
//

import SwiftUI
import AlertToast
import SDWebImageSwiftUI

struct UserAddView:View{
    @Environment(\.dismiss) var dismiss
    @StateObject var addUserViewModel:UserAddViewModel
    @State var phoneNumber = ""
    @State var offset = CGSize.zero
    @State var isShowAlert:Bool = false
    @State var showAlertMessage:String?
    @State var isShowSuccessAlert:Bool = false
    var body: some View{
        
        let dragGesture = DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded {
                if $0.translation.height > -30{
                    withAnimation {
                        offset = .zero
                        self.dismiss.callAsFunction()
                    }
                }else{
                    offset = .zero
                }
            }
        
        VStack(spacing:0){
            HStack{
                
                Label {
                    Text("회원추가")
                        .font(.title)
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.accentColor)
                }

                Spacer()
            }
            .padding(.horizontal)
            VStack{
                HStack{
                    TextField("", text: $addUserViewModel.phoneNumber)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                    
                    Button {
                        UIApplication.shared.endEditing()
                        addUserViewModel.findUser()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .foregroundColor(Color.accentColor)
                    
                }
                .padding(.vertical)
                
                Divider()
                
                if addUserViewModel.findtrainee.username == nil,
                   addUserViewModel.findtrainee.useremail == nil{
                    VStack{
                        Spacer()
                        Text("검색된 회원이 없습니다.")
                        Spacer()
                    }
                    
                }else{
                    VStack{
                        FindUserCardView(isShowAlertView: $isShowAlert,isShowSuccessView: $isShowSuccessAlert, alertMessage: $showAlertMessage)
                            .environmentObject(self.addUserViewModel)
                            .padding()
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationBarHidden(true)
        .onTapGesture(count: 1) {
            UIApplication.shared.endEditing()
        }
        .toast(isPresenting: $isShowAlert, alert: {
            AlertToast(displayMode: .hud, type: .error(.red),title: showAlertMessage)
        })
        .toast(isPresenting: $isShowSuccessAlert,duration: 1, alert: {
            AlertToast(displayMode: .hud, type: .complete(.blue),title: "회원을 추가했습니다.")
        },completion: {
            self.dismiss.callAsFunction()
        })
        .gesture(dragGesture)
    }
}

struct FindUserCardView:View{
    @EnvironmentObject var viewModel:UserAddViewModel
    @Binding var isShowAlertView:Bool
    @Binding var isShowSuccessView:Bool
    @Binding var alertMessage:String?
    var body: some View{
        VStack{
            WebImage(url: URL(string: viewModel.findtrainee.userProfile ?? ""))
                .resizable()
                .placeholder(
                    Image("defaultImage")
                )
                .frame(width: 130, height: 130, alignment: .center)
                .clipShape(Circle())
                .shadow(color: .gray, radius: 5)
                .padding()
            
            Text(viewModel.findtrainee.username ?? "")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(viewModel.findtrainee.useremail ?? "")
                .font(.title3)

            
            Button {
                viewModel.updateUser { error in
                    withAnimation {
                        if error != .notTrainer{
                            self.alertMessage = error.errorDescription
                            self.isShowAlertView = true
                        }else{
                            self.isShowSuccessView = true
                        }
                    }
                }
            } label: {
                Label {
                    Text("추가하기")
                        .bold()
                } icon: {
                    Image(systemName: "plus.circle")
                }
                .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .frame(width: UIScreen.main.bounds.width*0.7)
            .padding(.vertical,5)
            .background(Color.accentColor)
            .cornerRadius(10)
            
            
        }
        .padding(.vertical)
        .frame(width: UIScreen.main.bounds.width*0.9)
        .background(backgroundColor)
        .cornerRadius(20)
    }
}


struct UserAddView_Previews:PreviewProvider{
    static var previews: some View{
        UserAddView(addUserViewModel: UserAddViewModel(trainerId: "3yvE0bnUEHbvDKasU1Orf7DhvjX2"))
        //        FindUserCardView(addUserViewModel: UserAddViewModel())
        //            .previewLayout(.sizeThatFits)
    }
}

extension UIApplication { // 키보드밖 화면 터치시 키보드 사라짐
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
