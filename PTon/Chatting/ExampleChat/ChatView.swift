//
//  chatview.swift
//  PTon
//
//  Created by 이경민 on 2022/03/20.
//

import SwiftUI
import ToastUI

struct ChatView: View {
    @StateObject var viewModel:ChattingInputViewModel
    @EnvironmentObject var chattingRoomViewModel:ChattingViewModel
    @State var showAdd:Bool = false
    @State var isShowImage:Bool = false
    @State var isShowCamera:Bool = false
    @State var isShowCalendar:Bool = false
    @State var typingMessage = ""
    let userProfileImage:String?
    
    init(viewModel:ChattingInputViewModel,userProfileImage:String?){
        _viewModel = StateObject.init(wrappedValue: viewModel)
        self.userProfileImage = userProfileImage
    }
    
    
    var body: some View {
        VStack(spacing:0){
            //MARK: - 채팅 리스트
            ScrollView(.vertical, showsIndicators: false){
                let messages = chattingRoomViewModel.ChattingRoom.Messages
                ForEach(messages.indices.reversed(),id:\.self) { index in
                    
                    if index == 0 || messages[index-1].date != messages[index].date{
                        VStack{
                            
                            if messages[index].content.hasPrefix("ChatsImage"){
                                ChattingImageView(viewmodel: ChattingImageViewModel(path: messages[index].content),
                                                  currentUser: messages[index].isCurrentUser)
                            }else{
                                MessageView(currentMessage: messages[index],userProfileUrl:userProfileImage)
                            }
                            
                            chattingDateView(messages[index].date)
                                .padding()
                        }
                    } else {
                        if messages[index].content.hasPrefix("ChatsImage"){
                            ChattingImageView(viewmodel: ChattingImageViewModel(path: messages[index].content),
                                              currentUser: messages[index].isCurrentUser)
                        }else{
                            MessageView(currentMessage: messages[index],userProfileUrl:userProfileImage)
                        }
                    }
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
                        isShowCalendar = true
                    } label: {
                        AdditionalButtonView(item: ("calendar","스케줄"))
                    }
                    .buttonStyle(AdditionalButtonStyle())


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
            ChattingImagePickerView(isPresented: $isShowImage)
                .edgesIgnoringSafeArea(.bottom)
                .environmentObject(self.viewModel)
        }
        .fullScreenCover(isPresented: $isShowCamera) {
            //MARK: - Chatting Camera View
            ChattingCameraView()
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
        .onDisappear {
            viewModel.viewDisAppear()
        }
        
    }
}

@ViewBuilder
func chattingDateView(_ date:String)->some View{
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


struct CalendarAlertView:View{
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewmodel:ChattingInputViewModel
    @Binding var isshow:Bool
    @State var date = Date()
    var body: some View{
        VStack{
            HStack{
                Spacer()
                Text("일정 예약")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            DatePicker("예약 날짜", selection: $date,displayedComponents: .date)

            DatePicker("예약 시간", selection: $date,displayedComponents: .hourAndMinute)

            Button {
                viewmodel.sendReservation(date)
                self.dismiss.callAsFunction()
            } label: {
                Text("예약하기")
            }
            .buttonStyle(ToastButtonStyle(isPrimary: true))
            .padding(.top)

        }
        .environment(\.locale, Locale(identifier: "ko_KR"))
    }
}


struct AdditionalButtonStyle:ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.accentColor:.gray)
    }
}


struct AdditionalButtonView:View{
    let item:(String,String)
    var body: some View{

        VStack(spacing:10){
            Image(systemName: item.0)
                .font(.system(size: 40))

            Text(item.1)
                .font(.system(size: 20))
                .fontWeight(.light)
        }
        .frame(width: 80, height: 80, alignment: .center)
        .padding()

    }
}

struct chatview_Previews: PreviewProvider {
    static var previews: some View {
        chattingDateView("2021.10.12 월요일")
            .previewLayout(.sizeThatFits)
    }
}
