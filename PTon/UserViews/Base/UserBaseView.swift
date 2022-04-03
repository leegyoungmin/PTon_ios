//
//  UserBaseView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/03.
//

import SwiftUI

struct UserBaseView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var UserBaseViewModel:UserBaseViewModel
    @State var selectedIndex:Int = 0
    @State var StretchingIndex:StretchingType = .request
    
    var body: some View {
        TabView(selection: $selectedIndex){
            HomeView()
                .environmentObject(self.UserBaseViewModel)
                .tabItem {
                    Label("홈", systemImage: "person.fill")
                }
                .tag(0)
                .onTapGesture {
                    selectedIndex = 0
                }
            JornalView(trainerId: UserBaseViewModel.trainerid,
                       userId: UserBaseViewModel.userid)
            .tabItem {
                Label("일지", systemImage: "bookmark.fill")
            }
            .tag(1)
            .onTapGesture {
                selectedIndex = 1
            }
            
            StretchingView(type: $StretchingIndex, trainerid: UserBaseViewModel.trainerid, userid: UserBaseViewModel.userid )
                .tabItem {
                    Label("스트레칭", systemImage: "person.fill")
                }
                .tag(2)
                .onTapGesture {
                    selectedIndex = 2
                }
            
            CoachingView(viewModel: CoachViewModel(UserBaseViewModel.trainerid, UserBaseViewModel.userid))
                .tabItem {
                    Label("코칭", systemImage: "person.fill")
                }
                .tag(3)
                .onTapGesture {
                    selectedIndex = 3
                }
            


        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack{
                    if selectedIndex != 2{
                        Text(ChangeTitle(selectedIndex))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    else{
                        Button {
                            print("Tapped Request Button")
                            self.StretchingIndex = .request
                        } label: {
                            Text("요청")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(StretchingIndex == .request ? .accentColor:.gray)
                        }.buttonStyle(.plain)
                        
                        Button {
                            print("Tapped All Button")
                            self.StretchingIndex = .all
                        } label: {
                            Text("전체")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(StretchingIndex == .all ? .accentColor:.gray)
                        }.buttonStyle(.plain)
                        
                    }
                }
            }
            
            //trailing Toolbar
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack{
                    
                    NavigationLink {
                        UserChattingView(viewModel: ChattingInputViewModel(UserBaseViewModel.trainerid,
                                                                           trainerName: UserBaseViewModel.trainerName,
                                                                           UserBaseViewModel.userid,
                                                                           userName: UserBaseViewModel.username,
                                                                           UserBaseViewModel.fitnessCode),
                                         messages: $UserBaseViewModel.chattings,
                                         userProfileImage: "")
                    } label: {
                        Image(systemName: "message.fill")
                            .foregroundColor(Color.accentColor)
                            .overlay(
                                Badge()
                                    .environmentObject(self.UserBaseViewModel)
                                ,alignment: .topLeading
                            )
                    }
                    
                    NavigationLink {
                        UserMemoView(viewmodel: MemoListViewModel(trainerid: self.UserBaseViewModel.trainerid,
                                                                  userid: self.UserBaseViewModel.userid,
                                                                  userProfile: ""),
                                     userName: self.UserBaseViewModel.username,
                                     trainerId: self.UserBaseViewModel.trainerid,
                                     trainerName: self.UserBaseViewModel.trainerName)
                    } label: {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(Color.accentColor)
                    }

                    Menu {
                        Button {
                            print("Tapped Logout Button")
                            self.UserBaseViewModel.logout {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            Text("로그 아웃")
                                .foregroundColor(Color.accentColor)
                        }
                    } label: {
                        Image("more")
                    }

                    
                    

                }
            }
        }
    }
}

struct Badge:View{
    @EnvironmentObject var viewModel:UserBaseViewModel
//    let index:Int
    var body: some View{
        ZStack(alignment: .topTrailing) {
            Color.clear
            
            if viewModel.unreadCount != 0{
                Text(String(viewModel.unreadCount))
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .font(.system(size: 10))
                    .padding(3)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: -15, y: -5)
            }
        }
    }
}

//struct UserBaseView_Previews: PreviewProvider {
//    static var previews: some View {
//        Image(systemName: "message.fill")
//            .foregroundColor(Color.accentColor)
//            .overlay(
//                Badge(index: 10)
//            )
//            .previewLayout(.sizeThatFits)
//            .padding()
//
//    }
//}

private func ChangeTitle(_ selectedTabIndex:Int) -> String{
    switch selectedTabIndex{
    case 0:
        return "홈"
    case 1:
        return "일지 작성"
    case 2:
        return "스트레칭"
    case 3:
        return "코칭"
    default:
        return ""
    }
}

enum StretchingType{
    case request,all
}
