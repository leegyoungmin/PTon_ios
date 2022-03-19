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
            TrainerUserListView(baseIndex: $trainerSelectedIndex,trainerName: trainerBaseViewModel.trainername)
                .tabItem {
                    Image(systemName: "person")
                }
                .tag(0)
                .onTapGesture {
                    self.trainerSelectedIndex = 0
                }
            TrainerChattingListView(trainees: trainerBaseViewModel.trainerbasemodel.trainee, trainerName: trainerBaseViewModel.trainername, fitnessCode: trainerBaseViewModel.fitnessCode)
                .tabItem {
                    Image(systemName: "message.fill")
                }
                .tag(1)
                .onTapGesture {
                    self.trainerSelectedIndex = 1
                }
            
            TrainerCalendarView(currentDate: $today)
                .tabItem{
                    Image(systemName: "person.fill")
                }
                .tag(2)
                .onTapGesture {
                    self.trainerSelectedIndex = 2
                }
            
            ExerciseStorageView()
                .tabItem {
                    Image(systemName: "figure.walk")
                }
                .tag(3)
                .onTapGesture {
                    self.trainerSelectedIndex = 3
                }
        }
        .tint(.purple)
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
