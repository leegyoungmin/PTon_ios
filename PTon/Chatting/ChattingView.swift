//
//  chatview.swift
//  PTon
//
//  Created by 이경민 on 2022/03/20.
//

import SwiftUI
import Firebase
import Kingfisher
import BottomSheet

struct ChattingView:View{
    //MARK: - DATA PROPERTIES
    @EnvironmentObject var viewModel:chattingViewModel
    let opponentName:String
    let opponentProfileUrl:String
    @State var selectedDate:Date = Date()
    
    //MARK: - VIEW PROPERTIES
    @State var isEdtiding:Bool = false
    @State var isShowMenu:Bool = false
    @State var photoType:photoType?
    @State var reservationError:Bool = true
    let gridItems:[GridItem] = Array(repeating: GridItem(.flexible()), count: 3)
    
    //MARK: - FUNCTIONS
    @ViewBuilder
    private func menuButton(_ title:String,_ image:String,onClicked:@escaping ()->())-> some View{
        Button {
            onClicked()
        } label: {
            VStack(spacing:10){
                Image(systemName: image)
                    .font(.system(size: 30))
                Text(title)
                    .fontWeight(.light)
            }
            .padding()
            .foregroundColor(.gray.opacity(0.8))
        }
        .buttonStyle(.plain)
    }
    
    var body: some View{
        VStack(spacing:0){
            ScrollViewReader { proxy in
                
                ZStack{
                    //1. 채팅 리스트 뷰
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(viewModel.chats.sorted(by: {$0.key < $1.key}),id:\.key){ key,value in
                            
                            Text(key.replacingOccurrences(of: "-", with: ". "))
                                .font(.callout)
                                .foregroundColor(.black.opacity(0.5))
                                .padding(.top,10)
                            
                            ForEach(value,id:\.chatId){ chat in
                                if chat.content.contains("https://"){
                                    MessageView(currentMessage: chat, chattingType: .image, userProfileUrl: opponentProfileUrl)
                                }else{
                                    MessageView(currentMessage: chat, chattingType: .text, userProfileUrl: opponentProfileUrl)
                                }
                                
                            }
                            
                        }
                    }
                    .onChange(of: viewModel.lastMessageId) { id in
                        withAnimation {
                            proxy.scrollTo(id)
                        }
                        
                    }
                    .onTapGesture {
                        withAnimation {
                            UIApplication.shared.endEditing()
                            self.isShowMenu = false
                        }
                        
                    }
                    
                    //2. 상대방 새로운 메시지 스크롤 뷰
                    if viewModel.isUpdate{
                        VStack{
                            Spacer()
                            
                            Button {
                                DispatchQueue.main.async {
                                    withAnimation {
                                        proxy.scrollTo(viewModel.lastMessageId)
                                        viewModel.isUpdate = false
                                    }
                                }
                            } label: {
                                Text("마지막으로")
                                    .font(.footnote)
                            }
                            .padding(10)
                            .background(.white)
                            .cornerRadius(20)
                        }
                        .padding()
                    }
                }//ZSTACK
                
                //3. 채팅 입력창
                HStack(spacing:0){
                    Button {
                        withAnimation {
                            UIApplication.shared.endEditing()
                            self.isShowMenu.toggle()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.accentColor)
                    }//BUTTON
                    .padding(5)
                    
                    HStack{
                        CustomTextfield(placeHolder: Text("메시지를 입력하세요."), text: $viewModel.typingMessage){_ in
                            withAnimation {
                                self.isShowMenu = false
                            }
                        } commit: {
                            if !viewModel.typingMessage.isEmpty{
                                DispatchQueue.main.async {
                                    viewModel.uploadchats(opponentName) {
                                        print("Error in sending message")
                                    }
                                    withAnimation {
                                        proxy.scrollTo(viewModel.lastMessageId)
                                    }
                                }
                            }else{
                                UIApplication.shared.endEditing()
                            }
                        }
                        .padding(.leading,10)
                        
                        Button {
                            DispatchQueue.main.async {
                                viewModel.uploadchats(opponentName) {
                                    print("Error in sending message")
                                }
                                withAnimation {
                                    proxy.scrollTo(viewModel.lastMessageId)
                                }
                            }
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .font(.footnote)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(viewModel.typingMessage.isEmpty ? Color(UIColor.secondaryLabel).opacity(0.5):.accentColor)
                                .cornerRadius(50)
                        }
                        .disabled(viewModel.typingMessage.isEmpty)
                        
                    }//HSTACK
                    .padding(3)
                    .background(backgroundColor)
                    .cornerRadius(50)
                }//HSTACK
                .padding(5)
                .background(.white)
                
                if isShowMenu{
                    
                    LazyVGrid(columns: gridItems, alignment: .center, spacing: 30) {
                        
                        menuButton("스케줄", "calendar") {
                            withAnimation {
                                self.isShowMenu = false
                                viewModel.isShowCalendar = true
                            }
                        }
                        
                        menuButton("카메라", "camera") {
                            self.photoType = .camera
                        }
                        
                        menuButton("앨범", "photo.on.rectangle") {
                            self.photoType = .library
                        }
                    }
                    .frame(height:70)
                }
                
            }//SCROLLVIEWREADER
        }//VSTACK
        .background(backgroundColor)
        .navigationTitle(opponentName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            UINavigationBar.appearance().barTintColor = UIColor(named: "Background")
        }
        .fullScreenCover(item: $photoType) { type in
            switch type{
            case .camera:
                ChattingCameraView(isPhotoType: $photoType, userName: opponentName)
                    .environmentObject(self.viewModel)
                    .background(.black)
            case .library:
                ChattingImagePickerView(isPhotoType: $photoType, userName: opponentName)
                    .environmentObject(self.viewModel)
            }
        }
        .bottomSheet(isPresented: $viewModel.isShowCalendar, height: 600,topBarCornerRadius: 30) {
            VStack{
                VStack(alignment:.leading){
                    Text("PT예약하기")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Divider()
                }
                
                VStack{
                    DatePicker("", selection: $selectedDate)
                        .datePickerStyle(.graphical)
                        .environment(\.locale, Locale(identifier: "ko-KR"))
                    
                    if !reservationError{
                        Text("같은 시간에 예약된 인원이 있습니다. 일정 관리 탭에서 확인해주세요.")
                            .foregroundColor(.red)
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.ReadReservation(selectedDate) {
                            print("Completion read Reservation \(viewModel.reservations)")
                            
                            viewModel.checkTime(selectedDate) { isSelected in
                                self.reservationError = isSelected
                                if isSelected{
                                    let message = "[\(convertString(content: selectedDate, dateFormat: "yyyy.MM.dd HH시 mm분"))] PT일정 예약 되셨습니다."
                                    viewModel.uploadchats(opponentName, message: message)
                                }
                            }
                        }
                    } label: {
                        Text("예약하기")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(width: UIScreen.main.bounds.width*0.8, alignment: .center)
                            .padding(.vertical,10)
                            .foregroundColor(.white)
                    }
                    .background(Color.accentColor)
                    .cornerRadius(50)

                }
            }
            .padding(.horizontal)
        }
    }
}

struct CustomTextfield:View{
    var placeHolder:Text
    @Binding var text:String
    var editingChanged:(Bool)->() = {_ in}
    var commit:()->() = {}
    
    var body: some View{
        ZStack(alignment: .leading) {
            if text.isEmpty{
                placeHolder
                    .opacity(0.5)
            }
            
            TextField("", text: $text,onEditingChanged: editingChanged,onCommit: commit)
                .submitLabel(.done)
        }
    }
}



//MARK: - PREVIEWS
struct ChattinView_Previews:PreviewProvider{
    @State static var text:String = ""
    @StateObject static var viewModel = chattingViewModel(fitnessCode: "000001", trainerId: "3yvE0bnUEHbvDKasU1Orf7DhvjX2", trainerName: "이경민", userId: "kakao:1967260938", reference: Firebase.Database.database().reference())
    static var previews: some View{
        Group{
            
            ChattingView(opponentName: "이경민", opponentProfileUrl: "")
                .environmentObject(self.viewModel)
        }
        
    }
}
