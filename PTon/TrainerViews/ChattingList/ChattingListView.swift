////
////  TrainerChattingListView.swift
////  PTon
////
////  Created by 이경민 on 2022/02/09.
////
//
//import SwiftUI
//
//struct TrainerChattingListView: View {
//    let trainees:[trainee]
//    let trainerName:String
//    let fitnessCode:String
//    var body: some View {
//        ScrollView(.vertical, showsIndicators: false) {
//            ForEach(trainees,id:\.self) { trainee in
//                ChattingListCellView(viewmodel: ChattingListViewModel(trainername: trainerName, fitnessCode: fitnessCode, trainee: trainee))
//            }
//        }
//        .background(Color("Background"))
//        //TODO: 트레이너 채팅 리스트 및 마지막 데이터 불러오기 함수 적용 및 Async적용
//        .navigationViewStyle(.stack)
//        .onAppear {
//            print("trainees in onAppear \(trainees)")
//        }
//    }
//}
//
//struct ChattingListCellView:View{
//    @StateObject var viewmodel:ChattingListViewModel
//    var body: some View{
//        NavigationLink {
//            ChatView(chattings: $viewmodel.ChatLists.chattings)
//        } label: {
//            HStack(alignment:.center){
//                
//                if viewmodel.profileUrl() == ""{
//                    Image(systemName: "person.circle")
//                        .font(.system(size: 25))
//                }else{
//                    URLImageView(urlString: viewmodel.profileUrl(), imageSize: 50, youtube: false)
//                }
//                
//                VStack(alignment:.leading,spacing:10){
//                    HStack{
//                        Text(viewmodel.ChatLists.username)
//                            .font(.body)
//                            .fontWeight(.semibold)
//                        
//                        Button {
//                            viewmodel.setFavorite()
//                        } label: {
//                            Image(systemName: "star.fill")
//                                .foregroundColor(viewmodel.ChatLists.favorite ? .accentColor:.gray)
//                                .font(.system(size: 10))
//                        }
//
//                    }
//                    
//                    Text(viewmodel.lastChatting().lastMessage.hasPrefix("ChatsImage") ? "사진":viewmodel.lastChatting().lastMessage)
//                        .font(.body)
//                        .fontWeight(.light)
//                        .lineLimit(1)
//                }
//                
//                Spacer()
//                
//                VStack(alignment:.center,spacing:10){
//                    Text(viewmodel.lastChatting().time)
//                    
//                    if let unreadCount = viewmodel.ChatLists.chattings.filter({$0.isRead == "false"}).count{
//                        Text("\(unreadCount)")
//                            .foregroundColor(unreadCount == 0 ? .clear:.black)
//                            .padding(.horizontal,10)
//                            .padding(.vertical,5)
//                            .background(unreadCount == 0 ? .clear:Color.accentColor)
//                            .cornerRadius(20)
//                    }
//                }
//                
//            }
//        }
//        .padding()
//        .onAppear {
//            viewmodel.ObserveData()
//        }
//        .onDisappear {
//            viewmodel.onViewDisAppear()
//        }
//    }
//}
//
////struct TrainerChattingListView_Previews: PreviewProvider {
////    static var previews: some View {
////        TrainerChattingListView(chattingListViewModel: ChattingListViewModel(trainername: "이겨민", fitnessCode: "000001"))
////        ChattingListCellView(chatting: Chat(userid: "asd", username: "dlrudaㅣㄴ", lastMessage: "ㅁㄴㅇㅁ", time: "12:00", isRead: "false"), unreadCount: 20)
////            .previewLayout(.sizeThatFits)
////    }
////}
