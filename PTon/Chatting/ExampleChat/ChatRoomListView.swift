//
//  chatlistview.swift
//  PTon
//
//  Created by 이경민 on 2022/03/20.
//

import SwiftUI

struct ChatRoomListView: View {
    let trainees:[trainee]
    let trainerId:String
    let trainerName:String
    let fitnessCode:String
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(trainees,id:\.self){ trainee in
                ChatRoomListCellView(viewModel: ChattingViewModel(trainee: trainee, trainerId, trainerName, fitnessCode))
            }
        }
    }
}

struct ChatRoomListCellView:View{
    @StateObject var viewModel:ChattingViewModel
    var body: some View{
        
        //TODO: - 유저 이미지 불러오기
        NavigationLink {
            ChatView(messages: $viewModel.ChattingRoom.Messages,
                     viewModel:ChattingInputViewModel(viewModel.trainerId, trainerName: viewModel.trainerName, viewModel.trainee.userId, userName: viewModel.trainee.userName, viewModel.fitnessCode))
        } label: {
            let lastMessage = viewModel.ChattingRoom.Messages.last ?? message(content: "", time: "", date: "", isRead: false, isCurrentUser: false)
            HStack{
                Image(systemName: "person.fill")
                    .clipShape(Circle())
                    .font(.system(size: 50))
                
                VStack(alignment:.leading,spacing:10){
                    HStack{
                        Text(viewModel.trainee.userName)
                        
                        Button {
                            viewModel.changeFavorite()
                        } label: {
                            Image(systemName: "star.fill")
                                .foregroundColor(viewModel.ChattingRoom.favorite ? Color.accentColor:Color.gray.opacity(0.1))
                                .imageScale(.small)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Text(lastMessage.time)
                    }
                    HStack{
                        Text(lastMessage.content.hasPrefix("ChatsImage") ? "사진":lastMessage.content)
                            .frame(alignment:.leading)
                        
                        Spacer()
                        
                        if viewModel.unReadCount != 0{
                            Text("\(viewModel.unReadCount)")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color.accentColor)
                                )
                        }else{
                            EmptyView()
                        }
                        

                    }
                }
            }
        }
        .buttonStyle(.plain)
        .padding()
        
    }
}

struct chatlistview_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomListCellView(viewModel:
                            ChattingViewModel(trainee:
                                                trainee(username: "스타카토비바체", useremail: "asd", userid: "Asd", userProfile: "Asd")
                                              , "exaxas", "asd", "asdasd"
                                             )
        )
        .previewLayout(.sizeThatFits)
    }
}
