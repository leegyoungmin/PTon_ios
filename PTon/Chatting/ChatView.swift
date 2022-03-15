//
//  ChatView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/10.
//

import Foundation
import SwiftUI
import PhotosUI
import ToastUI
import Firebase

struct ChatView:View{
    @StateObject var ChattingViewModel:ChattingViewModel
    @State var showAdd:Bool = false
    @State var isShowImage:Bool = false
    @State var isShowCamera:Bool = false
    @State var isShowCalendar:Bool = false
    
    var body: some View{
        VStack(spacing:0){
            ZStack{
                
                Color("Background").edgesIgnoringSafeArea(.all)
                
                List{
                    ForEach(ChattingViewModel.Messages.reversed(),id:\.self) { message in
                        if message.content.hasPrefix("ChatsImage"){
                            
                            if message.data == nil{
                                ChattingImageView(viewmodel: ChattingImageViewModel(path: message.content), currentUser: message.user.isCurrentUser)
                            }else{
                                Image(uiImage: UIImage(data: message.data!) ?? UIImage())
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight:400)
                                    .rotationEffect(Angle(degrees: -180))
                                    .cornerRadius(5)
                            }
                            

                        }else{
                            MessageView(currentMessage: message)
                        }

                    }
                    .listRowBackground(Color("Background"))
                }
                .listStyle(.plain)
                .rotationEffect(.degrees(180))
                .onTapGesture {
                    withAnimation {
                        UIApplication.shared.endEditing()
                        self.showAdd = false
                    }
                }
                .background(Color("Background"))
                
                
            }

            HStack{
                Button {
                    withAnimation(.default){
                        UIApplication.shared.endEditing()
                        showAdd = true
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 25))
                }
                
                TextField("메세지를 입력하세요.", text: $ChattingViewModel.typingMessage)
                    .textFieldStyle(.plain)
                    .onTapGesture {
                        withAnimation {
                            showAdd = false
                        }
                    }
                
                Button {
                    print("send Button Tapped")
                    
                    DispatchQueue.main.async {
                        ChattingViewModel.updateSelf(nil)
                        ChattingViewModel.send()
                    }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 25))
                        .foregroundColor(ChattingViewModel.typingMessage.isEmpty ? .gray:.accentColor)
                }
                .disabled(ChattingViewModel.typingMessage.isEmpty)
            }
            .padding(10)

            
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
                
                .frame(height:UIScreen.main.bounds.height/5)
                
            }
        }
        .background(.white)
        .navigationTitle(ChattingViewModel.username)
        .onAppear {
            UINavigationBar.appearance().backgroundColor = UIColor(.clear)
            UINavigationBar.appearance().tintColor = UIColor(.accentColor)
            UITableView.appearance().showsVerticalScrollIndicator = false
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().separatorColor = .clear
            UITableView.appearance().tableFooterView = UIView()
        }
        .onTapGesture(count: 1) {
            UIApplication.shared.endEditing()
        }
        .sheet(isPresented: $isShowImage) {
            ChattingImagePickerView(isPresented: $isShowImage)
                .edgesIgnoringSafeArea(.bottom)
                .environmentObject(self.ChattingViewModel)
        }
        .fullScreenCover(isPresented: $isShowCamera) {
            ChattingCameraView()
                .edgesIgnoringSafeArea(.all)
                .environmentObject(self.ChattingViewModel)
        }
        .toast(isPresented: $isShowCalendar, content: {
            ToastView {
                CalendarAlertView(isshow: $isShowCalendar)
                    .environmentObject(self.ChattingViewModel)
            }
            .onTapGesture {
                self.isShowCalendar = false
            }
        })
    }
}

struct CalendarAlertView:View{
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewmodel:ChattingViewModel
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
                DispatchQueue.main.async {
                    viewmodel.updateReservation(date)
                }
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

struct ChatView_Previews:PreviewProvider{
    @State static var typingMessage:String = ""
    static var previews: some View{
        ChatView(ChattingViewModel: ChattingViewModel("asjdk", trainername: "aedfnj", fitnessCode: "asdjk", username: "asdnjk"))
//        AdditionalButtonView(item: ("calendar","스케줄"))
//            .previewLayout(.sizeThatFits)
//            .padding()
    }
}


extension ChattingViewModel{
    func updateReservation(_ date:Date){
        guard let trainerid = Firebase.Auth.auth().currentUser?.uid else{return}
        
        let data : [String:Any] = [
            "Checked":false,
            "Time":convertString(content: date, dateFormat: "HH:mm")
        ]
        
        Firebase.Database.database().reference()
            .child("Reservation")
            .child(trainerid)
            .child(convertString(content: date, dateFormat: "yyyy-MM-dd"))
            .child(self.userid)
            .updateChildValues(data) { error, ref in
                if error == nil{
                    self.sendReservation(date)
                }
            }
        
    }
}
