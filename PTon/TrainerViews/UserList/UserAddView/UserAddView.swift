//
//  UserAddView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/08.
//

import SwiftUI

struct UserAddView:View{
    @Environment(\.presentationMode) var presentationMode
    @StateObject var addUserViewModel = UserAddViewModel()
    @State var phoneNumber = ""
    @State var offset = CGSize.zero
    var body: some View{
        
        let dragGesture = DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded {
                if $0.translation.height > -30{
                    withAnimation {
                        offset = .zero
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }else{
                    offset = .zero
                }
            }
        
        VStack(spacing:0){
            HStack{
                Text("회원 추가")
                    .font(.system(size: 40, weight: .black, design: .default))
                Spacer()
            }
            .padding()
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
                            .font(.system(size: 30))
                    }
                    .foregroundColor(.purple)

                }
                .padding(.horizontal)
                
                VStack{
                    if addUserViewModel.findtrainee.username == nil,
                       addUserViewModel.findtrainee.useremail == nil{
                        VStack{
                            Spacer()
                            Text("검색된 회원이 없습니다.")
                            Spacer()
                        }
                        
                    }else{
                        VStack{
                            Spacer()
                            FindUserCardView(addUserViewModel: self.addUserViewModel)
                                .padding()
                            Spacer()
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onTapGesture(count: 1) {
            UIApplication.shared.endEditing()
        }
        .gesture(dragGesture)
    }
}

struct FindUserCardView:View{
    @ObservedObject var addUserViewModel:UserAddViewModel
    var body: some View{
        VStack{
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.top,10)
            
            Text(addUserViewModel.findtrainee.username ?? "example_name")
            
            Text(addUserViewModel.findtrainee.useremail ?? "example_email")
            
            Button {
                addUserViewModel.updateUser()
            } label: {
                HStack{
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 25))
                    Text("추가하기")
                        .font(.system(size: 25))
                }
                .padding(.vertical,5)
                .padding(.horizontal,20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.purple)
                )
                .foregroundColor(.purple)
                
            }
            .buttonStyle(.plain)

        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 250, alignment: .center)
        .background(Color.gray)
        .cornerRadius(20)
    }
}


struct UserAddView_Previews:PreviewProvider{
    static var previews: some View{
//        UserAddView()
        FindUserCardView(addUserViewModel: UserAddViewModel())
            .previewLayout(.sizeThatFits)
    }
}

extension UIApplication { // 키보드밖 화면 터치시 키보드 사라짐
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
