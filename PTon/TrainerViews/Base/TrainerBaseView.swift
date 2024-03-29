//
//  TrainerBaseView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/03.
//

import SwiftUI

let coloredNavAppearance = UINavigationBarAppearance()

struct TrainerBaseView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var trainerBaseViewModel = TrainerBaseViewModel()
    @State var trainerSelectedIndex:Int = 0
    @State var today = Date()
    
    init(){
        coloredNavAppearance.configureWithTransparentBackground()
        coloredNavAppearance.backgroundColor = .white
        coloredNavAppearance.titleTextAttributes = [.foregroundColor:UIColor.black]
        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor:UIColor.black]
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
    }
    var body: some View {
        TabView(selection: $trainerSelectedIndex) {
            TrainerUserListView(baseIndex: $trainerSelectedIndex)
                .tabItem {
                    Label {
                        Text("회원목록")
                    } icon: {
                        Image(systemName: "person")
                    }


                }
                .tag(0)
                .onTapGesture {
                    self.trainerSelectedIndex = 0
                }
                .environmentObject(self.trainerBaseViewModel)
            
            ChatRoomListView(trainees: trainerBaseViewModel.trainerbasemodel.trainee,
                         trainerId: trainerBaseViewModel.trainerId,
                         trainerName: trainerBaseViewModel.trainername,
                         fitnessCode: trainerBaseViewModel.fitnessCode
            )
                .tabItem {
                    Label {
                        Text("채팅목록")
                    } icon: {
                        Image(systemName: "message.fill")
                    }


                }
                .tag(1)
                .badge(trainerBaseViewModel.unreadCount)
                .onTapGesture {
                    self.trainerSelectedIndex = 1
                }
            TrainerScheduleView(viewmodel: ScheduleViewModel(trainerId: trainerBaseViewModel.trainerId,
                                                             trainees: trainerBaseViewModel.trainerbasemodel.trainee))
                .tabItem{
                    Label {
                        Text("일정관리")
                    } icon: {
                        Image(systemName: "person.fill")
                    }
                }
                .tag(2)
                .onTapGesture {
                    self.trainerSelectedIndex = 2
                }
            
            ExerciseStorageView()
                .tabItem {
                    Label {
                        Text("운동창고")
                    } icon: {
                        Image(systemName: "figure.walk")
                    }

                }
                .tag(3)
                .onTapGesture {
                    self.trainerSelectedIndex = 3
                }
        }
        .tint(Color.purple)
        .navigationBarItems(leading: ChangeTitle(trainerSelectedIndex), trailing:logOutButton)
        .navigationViewStyle(.stack)
    }
    
    var logOutButton:some View{
        Button {
            self.trainerBaseViewModel.logout {
                self.presentationMode.wrappedValue.dismiss()
            }
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

private func ChangeTitle(_ selectedTabIndex:Int) -> some View{
    switch selectedTabIndex{
    case 0:
        return Text("회원 목록").font(.system(size:25)).fontWeight(.semibold)
    case 1:
        return Text("채팅 목록").font(.system(size:25)).fontWeight(.semibold)
    case 2:
        return Text("일정 관리").font(.system(size:25)).fontWeight(.semibold)
    case 3:
        return Text("운동 창고").font(.system(size:25)).fontWeight(.semibold)
    default:
        return Text("").font(.system(size:25)).fontWeight(.semibold)
    }
}
