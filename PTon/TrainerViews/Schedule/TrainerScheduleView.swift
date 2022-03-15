//
//  TrainerCalendarView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/08.
//

import SwiftUI
import ToastUI

struct TrainerScheduleView: View {
    @StateObject var viewmodel:ScheduleViewModel
    @State var isshowCreateView:Bool = false
    @State var isshowEndView:Bool = false
    @Binding var selectedDate:Date
    var body: some View {
        VStack {
            //MARK: - Header View
            HStack{
                Text("일정")
                    .font(.system(size:25))
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink {
                    TrainerScheduleUserListView()
                        .environmentObject(self.viewmodel)
                } label: {
                    HStack(alignment:.bottom){
                        Text("일정 추가")
                        Image(systemName: "plus.circle")
                    }
                    .foregroundColor(.accentColor)
                }

            }
            .padding(.horizontal)
            .padding(.top)
            
            //MARK: - ScheduleView
            
            if viewmodel.schedules.isEmpty{
                VStack{
                    Spacer()
                    Text("아직 생성된 일정이 없습니다.")
                    Spacer()
                }

            }else{
                
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(viewmodel.schedules,id: \.self) { schedule in
                        TrainerScheduleCellView(isshowEndView: $isshowEndView, schedule: schedule)

                    }
                }
                .background(.white)
                .padding(.horizontal)
                .padding(.bottom)
            }
            

        }
        .onChange(of: selectedDate) { newValue in
            viewmodel.fetchData(newValue)
        }
        
        
    }
}

struct TrainerScheduleCellView:View{
    @EnvironmentObject var viewmodel:ScheduleViewModel
    @Binding var isshowEndView:Bool
    let schedule:userSchedule
    var body: some View{
        HStack{
            URLImageView(urlString: schedule.profileImage, imageSize: 50, youtube: false)
            
            VStack(alignment:.leading,spacing: 5){
                Text(schedule.username)
                    .font(.title2)
                    .fontWeight(.heavy)
                
                Text(convertString(content:schedule.schedule.time,dateFormat:"HH시 mm분"))
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Button {
                isshowEndView = true
            } label: {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 25))
                    .foregroundColor(Color.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(schedule.schedule.isDone)
        }
        .padding()
        .toast(isPresented: $isshowEndView,onDismiss: {
            viewmodel.fetchData(schedule.schedule.date)
        }, content: {
            ToastView {
                
                VStack{
                    Text("수업을 완료하시겠습니까?")
                        .font(.system(size: 20))
                    
                    Text("완료 후 PT횟수가 자동으로 차감됩니다.")
                        .font(.footnote)
                    
                    HStack{
                        Button {
                            isshowEndView = false
                        } label: {
                            Text("취소")
                        }
                        .buttonStyle(ToastButtonStyle(isPrimary: false))

                        
                        Button {
                            DispatchQueue.main.async {
//                                viewmodel.changeReservation(schedule.date, schedule.userId)
                            }
                            
                            isshowEndView = false
                        } label: {
                            Text("확인")
                        }
                        .buttonStyle(ToastButtonStyle(isPrimary: true))
                    }
                    
                }
                .padding()
            }
        })
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
//            TrainerScheduleView()
//            TrainerScheduleCellView()
//                .previewLayout(.sizeThatFits)
//                .padding()
            Button {
                print(123)
            } label: {
                Text("취소")
            }
            .buttonStyle(ToastButtonStyle(isPrimary: false))
            .previewLayout(.sizeThatFits)
            
            Button {
                print(123)
            } label: {
                Text("확인")
            }
            .buttonStyle(ToastButtonStyle(isPrimary: true))
            .previewLayout(.sizeThatFits)

        }

    }
}
