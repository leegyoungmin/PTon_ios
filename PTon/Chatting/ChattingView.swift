//
//  chatview.swift
//  PTon
//
//  Created by 이경민 on 2022/03/20.
//

import SwiftUI
import Firebase

struct ChattingView:View{
    @StateObject var viewModel:chattingViewModel
    @State var isEdtiding:Bool = false
    let opponentName:String
    let opponentProfileUrl:String
    var body: some View{
        VStack(spacing:0){
            ScrollViewReader { proxy in
                
                ZStack{
                    //1. 채팅 리스트 뷰
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(viewModel.chats,id:\.self){ chat in
                            MessageView(currentMessage: chat, userProfileUrl: opponentProfileUrl)
                                .padding(.horizontal)
                                .id(chat.chatId)
                        }
                    }
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                    .padding(.vertical,3)
                    
                    //2. 상대방 새로운 메시지 스크롤 뷰
                    if viewModel.isUpdate{
                        VStack{
                            Spacer()
                            
                            Button {
                                DispatchQueue.main.async {
                                    proxy.scrollTo(viewModel.chats.last?.chatId)
                                    self.viewModel.isUpdate = false
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
                }
                //3. 채팅 입력창
                HStack(spacing:0){
                    Button {
                        print("plus tapped")
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.accentColor)
                    }//BUTTON
                    .padding(5)
                    HStack{
                        CustomTextfield(placeHolder: Text("메시지를 입력하세요."), text: $viewModel.typingMessage){_ in
                            
                        } commit: {
                            DispatchQueue.main.sync {
                                viewModel.uploadchats(opponentName) {
                                    print("Error in sending message")
                                }
                                withAnimation {
                                    proxy.scrollTo(viewModel.chats.last?.chatId)
                                }
                            }
                        }
                        .padding(.leading,10)
                        
                        Button {
                            DispatchQueue.main.sync {
                                viewModel.uploadchats(opponentName) {
                                    print("Error in sending message")
                                }
                                withAnimation {
                                    proxy.scrollTo(viewModel.chats.last?.chatId)
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
                
            }//SCROLLVIEWREADER
            
            
            
        }//VSTACK
        .background(backgroundColor)
        .navigationTitle(opponentName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            UINavigationBar.appearance().barTintColor = UIColor(named: "Background")
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

struct ChattinView_Previews:PreviewProvider{
    @State static var text:String = ""
    static var previews: some View{
        Group{
            
            NavigationView{
                ChattingView(viewModel: chattingViewModel(fitnessCode: "000001", trainerId: "3yvE0bnUEHbvDKasU1Orf7DhvjX2", trainerName: "이경민", userId: "kakao:1967260938", reference: Firebase.Database.database().reference()), opponentName: "이경민", opponentProfileUrl: "")
                    .navigationBarTitleDisplayMode(.inline)
            }
            
            
        }
        
    }
}
