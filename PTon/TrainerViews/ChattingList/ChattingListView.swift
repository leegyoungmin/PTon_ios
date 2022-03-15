//
//  TrainerChattingListView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/09.
//

import SwiftUI

struct TrainerChattingListView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var chattingListViewModel:ChattingListViewModel
    
    var body: some View {
        VStack{
            if self.chattingListViewModel.Chats.isEmpty{
                Text("회원님과 채팅을 시작해보세요.")
            }else{
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(self.chattingListViewModel.Chats.sorted(by: {$0.time > $1.time}),id:\.self) { item in
                        NavigationLink {
                            ChatView(ChattingViewModel: ChattingViewModel(item.userid,trainername: chattingListViewModel.trainername, fitnessCode: chattingListViewModel.fitnessCode, username: item.username))
                        } label: {
                            ChattingListCellView(chatting: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .background(Color("Background"))
        //TODO: 트레이너 채팅 리스트 및 마지막 데이터 불러오기 함수 적용 및 Async적용
        .navigationViewStyle(.stack)
        .onAppear {
            UITableView.appearance().separatorColor = .clear
            UITableView.appearance().separatorStyle = .none
            
            chattingListViewModel.refreshChatList()
        }
        .onDisappear {
            chattingListViewModel.onViewDisAppear()
        }
    }
}

struct ChattingListCellView:View{
    @State var chatting:Chat
    var body: some View{
        HStack(alignment:.center){
            
            URLImageView(urlString: chatting.urlString, imageSize: 50, youtube: false)
            
            
            VStack(alignment:.leading,spacing:10){
                Text(chatting.username)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text(chatting.lastMessage.hasPrefix("ChatsImage") ? "사진":chatting.lastMessage)
                    .font(.body)
                    .fontWeight(.light)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment:.center,spacing:10){
                Text(chatting.time)
            }
            
        }
        .padding()
    }
}

struct TrainerChattingListView_Previews: PreviewProvider {
    static var previews: some View {
//        TrainerChattingListView(chattingListViewModel: ChattingListViewModel(trainername: "이겨민", fitnessCode: "000001"))
        ChattingListCellView(chatting: Chat(userid: "asd", username: "dlrudaㅣㄴ", lastMessage: "ㅁㄴㅇㅁ", time: "12:00"))
            .previewLayout(.sizeThatFits)
    }
}
