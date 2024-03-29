//
//  UserChattingView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/20.
//

import SwiftUI
import ToastUI

struct UserChattingView: View {
    @StateObject var viewModel:ChattingInputViewModel
    @Binding var messages:[message]
    @State var showAdd:Bool = false
    @State var isShowImage:Bool = false
    @State var isShowCamera:Bool = false
    @State var isShowCalendar:Bool = false
    @State var typingMessage = ""
    let userProfileImage:String?
    
    
    var body: some View {
        VStack(spacing:0){
            //MARK: - 채팅 리스트
            

            ScrollView(.vertical, showsIndicators: false){
                LazyVStack{
                    ForEach(messages.indices.reversed(),id:\.self) { index in
                        
                        if index == 0 || messages[index-1].date != messages[index].date{
                            VStack{
                                
                                if messages[index].content.hasPrefix("ChatsImage"){
                                    ChattingImageView(currentUser: messages[index].isCurrentUser,
                                                      userImage: userProfileImage,
                                                      urlPath: messages[index].content,
                                                      trainerId: viewModel.trainerId,
                                                      userId: viewModel.userId,
                                                      fitnessCode: viewModel.fitnessCode)
                                }else{
                                    MessageView(currentMessage: messages[index],userProfileUrl:userProfileImage)
                                }
                                
                                userChattingDateView(messages[index].date)
                                    .padding()
                            }
                        } else {
                            if messages[index].content.hasPrefix("ChatsImage"){
                                ChattingImageView(currentUser: messages[index].isCurrentUser,
                                                  userImage: userProfileImage,
                                                  urlPath: messages[index].content,
                                                  trainerId: viewModel.trainerId,
                                                  userId: viewModel.userId,
                                                  fitnessCode: viewModel.fitnessCode)
                            }else{
                                MessageView(currentMessage: messages[index],userProfileUrl:userProfileImage)
                            }
                        }
                    }
                    .accessibilityElement()
                }

            }

            .padding(.vertical,5)
            .onTapGesture {
                withAnimation {
                    showAdd = false
                    UIApplication.shared.endEditing()
                }
            }
            .padding(.horizontal)
            .background(Color("Background"))
            .rotationEffect(.degrees(-180))
            
            //MARK: - 채팅 입력창
            HStack{
                Button {
                    withAnimation {
                        UIApplication.shared.endEditing()
                        showAdd = true
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 25))
                }
                
                TextField("메세지를 입력하세요.", text: $typingMessage)
                    .textFieldStyle(.plain)
                    .onTapGesture {
                        withAnimation {
                            showAdd = false
                        }
                    }
                
                
                Button {
                    DispatchQueue.main.async {
                        viewModel.sendText(typingMessage)
                        typingMessage = ""
                    }
                    
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.accentColor)
                }
                .disabled(typingMessage.isEmpty)
                
            }
            .padding(10)
            
            //MARK: - 추가 선택 창
            if showAdd{
                HStack{
                    
                    Button {
                        isShowCamera = true
                    } label: {
                        AdditionalButtonView(item: ("camera","카메라"))
                        
                    }
                    .buttonStyle(AdditionalButtonStyle())
                    
                    Button {
                        isShowImage = true
                    } label: {
                        AdditionalButtonView(item: ("photo","앨범"))
                    }
                    .buttonStyle(AdditionalButtonStyle())
                    
                    
                }
            }
            
        }
        .sheet(isPresented: $isShowImage) {
            //MARK: - Chatting Image Picker View
            ChattingImagePickerView(isSend: .constant(false), isPresented: $isShowImage)
                .edgesIgnoringSafeArea(.bottom)
                .environmentObject(self.viewModel)
        }
        .fullScreenCover(isPresented: $isShowCamera) {
            //MARK: - Chatting Camera View
            ChattingCameraView(isSend: .constant(false))
                .edgesIgnoringSafeArea(.all)
                .environmentObject(self.viewModel)
        }
        .toast(isPresented: $isShowCalendar) {
            //MARK: - Chatting Calendar View
            ToastView{
                CalendarAlertView(isshow: $isShowCalendar)
                    .environmentObject(self.viewModel)
            }
            .onTapGesture {
                self.isShowCalendar = false
            }
        }
        .navigationTitle(viewModel.userName)
        .onAppear {
            viewModel.ChangeRead()
        }
        .onDisappear {
            viewModel.viewDisAppear()
        }
        
    }
}

@ViewBuilder
func userChattingDateView(_ date:String)->some View{
    HStack{
        Spacer()
        Text(date)
            .foregroundColor(.white)
            .padding(.horizontal)
            .padding(.vertical,10)
            .background(.gray.opacity(0.7))
            .cornerRadius(20)
        Spacer()
    }
    .rotationEffect(.degrees(-180))
    
}


struct UserChattingView_previews: PreviewProvider {
    static var previews: some View {
        chattingDateView("2021.10.12 월요일")
            .previewLayout(.sizeThatFits)
    }
}
