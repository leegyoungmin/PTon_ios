//
//  UserChattingView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/20.
//

import SwiftUI
import ToastUI

struct UserChattingView: View {
    @StateObject var viewModel:UserChattingViewModel
    @State var isShowMenu:Bool = false
    @State var photoType:photoType?
    
    //MARK: - VIEW_PROPERTIES
    let gridItems:[GridItem] = Array(repeating: GridItem(.flexible()), count: 2)
    
    //MARK: - FUNCTIONS
    @ViewBuilder
    func menuButton(_ title:String,_ image:String,onClick:@escaping()->())->some View{
        Button {
            onClick()
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
        VStack{
            ScrollViewReader { proxy in
                
                ZStack{
                    //1. 채팅 리스트 뷰
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(viewModel.chattings.sorted(by: {$0.key < $1.key}),id:\.key){ key,value in
                            
                            Text(key.replacingOccurrences(of: "-", with: ". "))
                                .font(.callout)
                                .foregroundColor(.black.opacity(0.5))
                                .padding(.top,10)
                            
                            ForEach(value,id:\.chatId){ chat in
                                if chat.content.contains("https://"){
                                    MessageView(currentMessage: chat, chattingType: .image, userProfileUrl: "")
                                }else{
                                    MessageView(currentMessage: chat, chattingType: .text, userProfileUrl: "")
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
//                    if viewModel.isUpdate{
//                        VStack{
//                            Spacer()
//
//                            Button {
//                                DispatchQueue.main.async {
//                                    withAnimation {
//                                        proxy.scrollTo(viewModel.lastMessageId)
//                                        viewModel.isUpdate = false
//                                    }
//                                }
//                            } label: {
//                                Text("마지막으로")
//                                    .font(.footnote)
//                            }
//                            .padding(10)
//                            .background(.white)
//                            .cornerRadius(20)
//                        }
//                        .padding()
//                    }
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
                        CustomTextfield(placeHolder: Text("메시지를 입력하세요."), text: $viewModel.typeMessage){_ in
                            withAnimation {
                                self.isShowMenu = false
                            }
                        } commit: {
                            if !viewModel.typeMessage.isEmpty{
                                DispatchQueue.main.async {
                                    viewModel.uploadChats {
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
                                viewModel.uploadChats {
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
                                .background(viewModel.typeMessage.isEmpty ? Color(UIColor.secondaryLabel).opacity(0.5):.accentColor)
                                .cornerRadius(50)
                        }
                        .disabled(viewModel.typeMessage.isEmpty)
                        
                    }//HSTACK
                    .padding(3)
                    .background(backgroundColor)
                    .cornerRadius(50)
                }//HSTACK
                .padding(5)
                .background(.white)
                
                if isShowMenu{
                    LazyVGrid(columns: gridItems, alignment: .center, spacing: 30) {
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
        .navigationTitle(viewModel.trainerName)
        .fullScreenCover(item: $photoType) { type in
            switch type{
            case .camera:
                UserChattingCameraView(isPhotoType: $photoType)
                    .environmentObject(self.viewModel)
            case .library:
                UserChattingImagePickerView(isPhotoType: $photoType)
                    .environmentObject(self.viewModel)
            }
        }
    }
}
struct UserChattingView_previews: PreviewProvider {
    static var previews: some View {
        UserChattingView(viewModel: UserChattingViewModel(userId: "", trainerId: "", fitnessCode: "", userName: "", trainerName: ""))
    }
}
