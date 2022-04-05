//
//  TrainerScheduleCreateView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/11.
//

import SwiftUI
import BottomSheet
import AlertToast
import SDWebImageSwiftUI

struct TrainerScheduleUserListView:View{
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel:ScheduleMakeViewModel
    @State var isShowMakeView:Bool = false
    var body: some View{
        VStack{
            HStack{
                Text("현재회원목록")
                    .font(.system(size: 20))
                    .fontWeight(.light)
                Spacer()
            }
            .padding(.top)
            
            if viewModel.users.isEmpty{
                Text("설정된 회원이 없습니다.")
            }else{
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(viewModel.users,id:\.self) { user in
                        
                        NavigationLink {
                            TrainerScheduleMakeView(user: user.user)
                                .environmentObject(self.viewModel)
                        } label: {
                            TrainerScheduleUserListCellView(user: user)
                                .environmentObject(self.viewModel)
                        }
                        .disabled(viewModel.isNotPossible(max: user.memberShip.IntMaxLisense, min: user.memberShip.IntuserLisence))

                    }
                }
            }
        }
        .padding(.horizontal)
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationTitle("일정 생성")
    }
}

struct TrainerScheduleUserListCellView:View{
    @EnvironmentObject var viewModel:ScheduleMakeViewModel
    let user:schedulUser
    var body: some View{
        HStack{
            WebImage(url: URL(string: user.user.userProfile ?? ""))
                .resizable()
                .placeholder(Image("defaultImage"))
                .frame(width: 50, height: 50, alignment: .center)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.accentColor))
            
            VStack(alignment: .leading){
                Text(user.user.userName)
                
                if viewModel.isNotPossible(max: user.memberShip.IntMaxLisense, min: user.memberShip.IntuserLisence){
                    Text("회원권 횟수가 만료되었습니다.")
                }else{
                    Text("\(user.memberShip.IntuserLisence)회 / \(user.memberShip.IntMaxLisense)회")
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right.circle")
                .foregroundColor(.accentColor)
        }
        .padding(5)
    }
}



struct TrainerScheduleMakeView:View{
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewmodel:ScheduleMakeViewModel
    let user:trainee
    @State var selectedDate = Date()
    @State var isShowDateSheet:Bool = false
    @State var isShowTimeSheet:Bool = false
    @State var isSelectedDateSheet:Bool = false
    @State var isSelectedTimeSheet:Bool = false
    @State var isShowAlertView:Bool = false
    var body: some View{
        VStack{
            Spacer()
            VStack{
                //수업 정보
                VStack(spacing:5){
                    titleView(1, "수업정보")

                    HStack{
                        Text("PT운동")
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width*0.8, height: 20, alignment: .leading)
                    .padding(.bottom,5)
                    .background(
                        Rectangle()
                            .fill(.gray.opacity(0.8))
                            .frame(height:1)
                        ,alignment: .bottom
                    )
                    .padding(.vertical,5)
                    .padding(.bottom,50)
                }

                //수업 일자
                VStack{
                    titleView(2, "수업일자")

                    HStack{
                        Text("\(convertString(content:selectedDate,dateFormat:"yyyy . MM . dd"))")
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                            .foregroundColor(isSelectedDateSheet ? .black:.gray)

                        Spacer()

                        Image(systemName: "calendar")
                            .font(.system(size: 20))
                    }
                    .frame(width: UIScreen.main.bounds.width*0.8, height: 20, alignment: .leading)
                    .onTapGesture {
                        isShowDateSheet = true
                    }
                    .padding(.bottom,5)
                    .background(
                        Rectangle()
                            .fill(.gray.opacity(0.8))
                            .frame(height:1)
                        ,alignment: .bottom
                    )
                    .padding(.vertical,5)
                    .padding(.bottom,50)
                }

                //수업 시간
                VStack{
                    titleView(3, "수업시간")

                    HStack{
                        Text("\(convertString(content:selectedDate,dateFormat:"HH:mm")) 부터")
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                            .foregroundColor(isSelectedTimeSheet ? .black:.gray)

                        Spacer()

                        Image(systemName: "timer")
                            .font(.system(size: 20))
                    }
                    .frame(width: UIScreen.main.bounds.width*0.8, height: 20, alignment: .leading)
                    .onTapGesture {
                        isShowTimeSheet = true
                    }
                    .padding(.bottom,5)
                    .background(
                        Rectangle()
                            .fill(.gray.opacity(0.8))
                            .frame(height:1)
                        ,alignment: .bottom
                    )
                    .padding(.vertical,5)
                    .padding(.bottom,50)
                }

            }

            Spacer()

            Button {
                viewmodel.updateReservation(date: selectedDate, user: user)
                self.isShowAlertView = true
            } label: {
                Text("예약하기")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 300, alignment: .center)
                    .padding(.horizontal)
                    .padding(.vertical,10)
                    .background(Color.accentColor)
                    .cornerRadius(20)
            }
            .padding(.bottom,30)
            .disabled(isSelectedDateSheet == false || isSelectedTimeSheet == false)
        }
        .padding(.horizontal)
        .bottomSheet(isPresented: $isShowDateSheet,detents: [.medium()],isModalInPresentation: false,onDismiss: {
            self.isSelectedDateSheet = true
        }) {
            DatePickerView(selectedDate: $selectedDate, type: .date)
        }
        .bottomSheet(isPresented: $isShowTimeSheet,detents: [.medium()],isModalInPresentation: false,onDismiss: {
            self.isSelectedTimeSheet = true
        }) {
            DatePickerView(selectedDate: $selectedDate, type: .hourAndMinute)
        }
        .toast(isPresenting: $isShowAlertView, duration: 1, tapToDismiss: true, alert: {
            AlertToast(displayMode: .banner(.pop), type: .complete(.accentColor),title: "예약이 완료되었습니다.")
        }, onTap: {
            isShowAlertView = false
        }, completion: {
            self.dismiss.callAsFunction()
        })
    }

    func titleView(_ number:Int,_ title:String)->some View{
        return HStack(spacing:5){
            Image(systemName: "\(number).circle.fill")
                .foregroundColor(.accentColor)
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.gray.opacity(0.8))

            Spacer()
        }
    }
}

struct DatePickerView:View{
    @Binding var selectedDate:Date
    let type:DatePickerComponents
    var body: some View{

        if type == .hourAndMinute{
            VStack{
                HStack{
                    Text("시간 설정")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding()

                Spacer()
                
                DatePicker("", selection: $selectedDate,displayedComponents: type)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "ko_KR"))
                    .background(.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Spacer()

            }

        }else{
            VStack(spacing:20){
                HStack{
                    Text("날짜 설정")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.horizontal)

                DatePicker("", selection: $selectedDate ,displayedComponents: type)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding(.horizontal)
            }
        }


    }
}

struct TrainerScheduleCreateView_Previews: PreviewProvider {
    static var previews: some View {

        Group{
            TrainerScheduleUserListView(viewModel: ScheduleMakeViewModel(trainees: []))
        }
    }
}

