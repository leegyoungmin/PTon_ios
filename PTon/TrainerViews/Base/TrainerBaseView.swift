//
//  TrainerBaseView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/03.
//

import SwiftUI

enum TrainerPageType:String{
    case userList = "회원목록"
    case chatList = "채팅목록"
    case calendar = "일정관리"
    case exercise = "운동창고"
}

struct TrainerBaseView: View {
    @EnvironmentObject var authService:AuthService
    @Environment(\.presentationMode) var presentationMode
    @StateObject var trainerBaseViewModel = TrainerBaseViewModel()
    @State var trainerSelectedIndex:TrainerPageType = .userList
    @State var today = Date()
    
    init(){
        let coloredNavAppearance = UINavigationBarAppearance()
        coloredNavAppearance.configureWithTransparentBackground()
        coloredNavAppearance.backgroundColor = .white
        coloredNavAppearance.titleTextAttributes = [.foregroundColor:UIColor.black]
        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor:UIColor.black]
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
    }
    var body: some View {
        
        NavigationView {
            TabView(selection: $trainerSelectedIndex) {
                TrainerUserListView(selectedIndex: $trainerSelectedIndex)
                    .tag(TrainerPageType.userList)
                    .tabItem {
                        
                        VStack{
                            Image("listIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50, alignment: .center)
                            
                            Text("회원목록")
                        }
                    }
                    .environmentObject(self.trainerBaseViewModel)
                
                ChatRoomListView(viewModel: ChattingRoomListViewModel(fitnessCode: trainerBaseViewModel.fitnessCode,
                                                                      trainerId: trainerBaseViewModel.trainerId)
                                 ,trainees: trainerBaseViewModel.trainerbasemodel.trainee
                                 ,trainerName: trainerBaseViewModel.trainerbasemodel.name ?? "")
                    .tabItem {
                        
                        VStack{
                            Image("chatIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50, alignment: .center)
                            
                            Text("채팅목록")
                        }
                    }
                    .tag(TrainerPageType.chatList)
                    .badge(trainerBaseViewModel.unreadCount)
                
                TrainerScheduleView(viewmodel: ScheduleViewModel(trainerId: trainerBaseViewModel.trainerId,
                                                                 trainees: trainerBaseViewModel.trainerbasemodel.trainee))
                    .tabItem{
                        
                        VStack{
                            Image("calendarIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50, alignment: .center)
                            
                            Text("일정관리")
                        }
                    }
                    .tag(TrainerPageType.calendar)
                
                ExerciseStorageView()
                    .tabItem {
                        VStack{
                            Image("exerciseListIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50, alignment: .center)
                            
                            Text("운동창고")
                        }
                        
                    }
                    .tag(TrainerPageType.exercise)
            }
            .tint(Color.accentColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement:.navigationBarLeading) {
                    ChangeTitle($trainerSelectedIndex)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    logOutButton
                }
            }
        }
    }
    
    var logOutButton:some View{
        Button {
            authService.LogOut()
        } label: {
            Image(systemName: "arrow.left.to.line.circle.fill")
                .font(.system(size:20))
        }
        .foregroundColor(.accentColor)
    }
}

struct TrainerBaseView_Previews: PreviewProvider {
    static var previews: some View {
        TrainerBaseView()
    }
}

private func ChangeTitle(_ selectedTabIndex:Binding<TrainerPageType>) -> some View{
    Text(selectedTabIndex.wrappedValue.rawValue).font(.system(size: 25)).fontWeight(.semibold)
}
