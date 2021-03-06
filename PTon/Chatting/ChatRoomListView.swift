//
//  chatlistview.swift
//  PTon
//
//  Created by 이경민 on 2022/03/20.
//

import SwiftUI
import Kingfisher

struct ChatRoomListView: View {
    @StateObject var viewModel:ChattingRoomListViewModel
    let trainees:[trainee]
    let trainerName:String
    var body: some View {
        List{
            ForEach(viewModel.chatRooms,id:\.self){ chatRoom in
                let userProfile = self.trainees.first(where: {$0.userid == chatRoom.opponentId})?.userProfile ?? ""
                NavigationLink {
                    ChattingView(opponentName: chatRoom.opponentName, opponentProfileUrl: userProfile)
                        .environmentObject(chattingViewModel(fitnessCode: viewModel.fitnessCode,
                                                             trainerId: viewModel.trainerId,
                                                             trainerName: trainerName,
                                                             userId: chatRoom.opponentId,
                                                             reference: viewModel.reference))
                } label: {
                    chatRoomListCellView(room: chatRoom, userProfile: userProfile)
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        viewModel.ToggleFavorite(chatRoom.opponentId)
                    } label: {
                        Image(systemName: "star.fill")
                    }
                    .tint(.yellow)
                }
            }
        }
        .listStyle(.plain)
    }
}
struct chatRoomListCellView:View{
    @EnvironmentObject var viewModel:ChattingRoomListViewModel
    let room:chattingRoom
    let userProfile:String
    var body: some View{
        HStack{
            CircleImage(url: userProfile, size: CGSize(width: 50, height: 50))
            
            VStack(alignment:.leading,spacing: 5){
                Text(room.opponentName)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
                
                Text(room.lastMessage)
                    .fontWeight(.light)
                    .foregroundColor(.gray.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }//VSTACK
            Spacer()
        }//HSTACK
        .padding(.horizontal,5)
    }
}

struct listButtonStyle:ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        if configuration.isPressed{
            configuration.label.background(backgroundColor)
        }
    }
}

struct chatlistview_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ChatRoomListView(viewModel: ChattingRoomListViewModel(fitnessCode: "000001", trainerId: "3yvE0bnUEHbvDKasU1Orf7DhvjX2"), trainees: [trainee(username: "이경민", useremail: "cow970814@naver.com", userid: "kakao:1967260938", userProfile: "")], trainerName: "이경민")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
