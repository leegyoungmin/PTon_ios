//
//  UserChattingView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/16.
//

import SwiftUI

struct UserChattingView: View {
    @StateObject var viewModel:UserChattingViewModel
    var body: some View {
        VStack{
            List{
                ForEach(viewModel.userMessages.reversed(),id:\.self) { chat in
                    if chat.content.hasPrefix("ChatsImage"){
                        ChattingImageView(viewmodel: ChattingImageViewModel(path: chat.content), currentUser: chat.user.isCurrentUser)
                    }else{
                        MessageView(currentMessage: chat)
                    }
                    
                }
            }
            .listStyle(.plain)
            .rotationEffect(.degrees(180))
            
            HStack{
                TextField("", text: $viewModel.typingMessage)
                    .textFieldStyle(.plain)
                
                Button {
                    print("Tapped Senb Button")
                    viewModel.send()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 35))
                        .foregroundColor(.purple)
                }

            }
            .padding(5)
        }
        .navigationTitle(viewModel.trainerName!)
        .onAppear {
            UITableView.appearance().showsVerticalScrollIndicator = false
            UITableView.appearance().separatorColor = .clear
            UITableView.appearance().separatorStyle = .none
        }
        .onTapGesture(count: 1) {
            UIApplication.shared.endEditing()
        }
    }
}

struct UserChattingView_Previews: PreviewProvider {
    static var previews: some View {
        UserChattingView(viewModel: UserChattingViewModel(userid: "edaj", trainerid: "dajks", username: "dasnj", fitnessCode: "dask"))
    }
}
