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
        ScrollView(.vertical, showsIndicators: true) {
            ForEach(viewModel.chatRooms,id:\.self){ chatroom in
                let userProfile = self.trainees.first(where: {$0.userId == chatroom.opponentId})?.userProfile ?? ""
                NavigationLink {
                    ChattingView(viewModel: chattingViewModel(fitnessCode: viewModel.fitnessCode,
                                                              trainerId: viewModel.trainerId,
                                                              trainerName: self.trainerName,
                                                              userId: chatroom.opponentId,
                                                              reference: viewModel.reference),
                                 opponentName: chatroom.opponentName, opponentProfileUrl: userProfile)
                } label: {
                    chatRoomListCellView(room: chatroom, userProfile: userProfile)
                        .environmentObject(self.viewModel)
                }//NAVIGATIONLINK
            }
        }//SCROLLVIEW
        .padding(.horizontal)
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
                HStack(spacing:5){
                    Text(room.opponentName)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.black)
                    Button {
                        viewModel.ToggleFavorite(room.opponentId)
                    } label: {
                        Image(systemName:"star.fill")
                            .symbolVariant(.circle)
                            .foregroundColor(room.favorite ? Color.accentColor:Color.gray.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }//HSTACK
                
                Text("무성할 잠, 이런 소학교 청춘이 책상을 봅니다. 하나에 한 별에도 이제 아직 내 까닭입니다. 위에 언덕 별 멀리 그리고 다 하나에 듯합니다. 남은 파란 청춘이 라이너 계십니다. 차 패, 토끼, 가득 계집애들의 계십니다.")
                    .fontWeight(.light)
                    .foregroundColor(.gray.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }//VSTACK
            Spacer()
        }//HSTACK
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
