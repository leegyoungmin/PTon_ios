//
//  TrainerCalendarView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/08.
//

import SwiftUI
import ToastUI
import SDWebImageSwiftUI

struct TrainerScheduleView: View {
    @StateObject var viewmodel:ScheduleViewModel
    @State var isshowCreateView:Bool = false
    @State var isshowEndView:Bool = false
    @State var selectedDate = Date()
    var body: some View {
        VStack {
            //MARK: - Header View
            
            TrainerCalendarView(currentDate: $selectedDate)
                .onChange(of: selectedDate) { newValue in
                    viewmodel.fetchData(newValue)
                }
            
            HStack{
                Text("일정")
                    .font(.system(size:25))
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink {
                    TrainerScheduleUserListView(viewModel: ScheduleMakeViewModel(trainees: viewmodel.trainees))
                } label: {
                    Label {
                        Text("일정추가")
                    } icon: {
                        Image(systemName: "plus.circle")
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)

            }
            .padding(.horizontal)
            
            if viewmodel.schedules.isEmpty{
                Spacer()
                Text("아직 예약된 회원이 없습니다.")
                Spacer()
            }else{
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(viewmodel.schedules,id:\.self){ schedule in
                        scheduleCellView(schedule: schedule)
                            .environmentObject(self.viewmodel)
                    }
                }
                .background(RoundedRectangle(cornerRadius: 5).fill(.white).shadow(color: .gray.opacity(0.5), radius: 5))
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(backgroundColor)
        
        
    }
}

struct scheduleCellView:View{
    @State var schedule:schedule
    @EnvironmentObject var viewmodel:ScheduleViewModel
    var body: some View{
        HStack{
            
            CircleImage(url: schedule.user.userProfile ?? "", size: CGSize(width: 50, height: 50))
            

            VStack(alignment: .leading){
                Text(schedule.user.userName)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(convertString(content:schedule.time,dateFormat:"HH:mm"))
                    .fontWeight(.light)
                    .foregroundColor(.gray.opacity(0.8))
            }
            
            Spacer()
            
            Button {
                self.schedule.isDone = true
                viewmodel.updateDone(schedule.date, schedule.user.userId)
            } label: {
                Image(systemName: schedule.isDone ? "checkmark.circle":"circle")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(self.schedule.isDone)


        }
        .padding()
    }
}


struct ToastButtonStyle:ButtonStyle{
    var isPrimary:Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isPrimary ? .white:.black)
            .padding(.horizontal,30)
            .padding(.vertical,5)
            .background(isPrimary ? Color.accentColor:.gray.opacity(0.5))
            .cornerRadius(20)
            
            
    }
}

struct TrainerScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            scheduleCellView(schedule: schedule(date: Date(), isDone: false, time: Date(), user: trainee(username: "이경민", useremail: "cow970814@naber.vom", userid: "ansdjk", userProfile: "")))
                .previewLayout(.sizeThatFits)
            
            TrainerScheduleView(viewmodel: ScheduleViewModel(trainerId: "", trainees: []))

        }

    }
}
