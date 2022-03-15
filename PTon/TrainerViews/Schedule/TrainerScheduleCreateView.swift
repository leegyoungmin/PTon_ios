//
//  TrainerScheduleCreateView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/11.
//

import SwiftUI
//import BottomSheet

struct TrainerScheduleUserListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewmodel: ScheduleViewModel
    @State var isShowInput:Bool = false
    @State var selectedIndex:Int = -1
    @State var offset:CGSize = .zero
    var body: some View {
        VStack(spacing:0){
            
            if !viewmodel.traineeList.isEmpty{
                List{
                    ForEach(viewmodel.traineeList.indices,id:\.self){ index in
                        if viewmodel.traineeList[index].username != nil{
                            NavigationLink {
                                TrainerScheduleMakeView(userIndex: index)
                                    .navigationBarTitleDisplayMode(.inline)
                                    .environmentObject(self.viewmodel)
                                    .onDisappear {
                                        self.dismiss.callAsFunction()
                                    }
                            } label: {
                                TrainerScheduleUserListCellView(trainee: viewmodel.traineeList[index])
                            }
                            
                        }
                    }
                }
                .listStyle(.plain)
                .padding()
            }
        }
        .background(Color("Background"))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("회원목록")
                    .font(.system(size: 25))
                    .fontWeight(.semibold)
            }
        }
        .gesture(
            DragGesture()
                .onChanged{ value in
                    if (value.predictedEndLocation.x - value.startLocation.x) > 30{
                        withAnimation {
                            self.offset = value.translation
                        }
                        
                    }
                }
                .onEnded {
                    if $0.translation.width > -30{
                        withAnimation {
                            self.offset = .zero
                            dismiss.callAsFunction()
                        }
                    }else{
                        withAnimation {
                            self.offset = .zero
                        }
                    }
                }
        )
        .offset(x:offset.width)
    }
}

struct TrainerScheduleUserListCellView:View{
    let trainee:trainee
    var body: some View{
        HStack{
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 50, height: 50, alignment: .leading)
                .cornerRadius(25)
            
            Text(trainee.username!)
            
            Spacer()
        }
    }
}

struct TrainerScheduleMakeView:View{
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewmodel:ScheduleViewModel
    let userIndex:Int
    @State var selectedDate = Date()
    @State var isShowDateSheet:Bool = false
    @State var isShowTimeSheet:Bool = false
    @State var isSelectedDateSheet:Bool = false
    @State var isSelectedTimeSheet:Bool = false
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
                self.viewmodel.updateReservation(selectedDate, userIndex)
                self.dismiss.callAsFunction()
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
//        .bottomSheet(isPresented: $isShowDateSheet,detents: [.medium()],isModalInPresentation: false,onDismiss: {
//            self.isSelectedDateSheet = true
//        }) {
//            DatePickerView(selectedDate: $selectedDate, type: .date)
//        }
//        .bottomSheet(isPresented: $isShowTimeSheet,detents: [.medium()],isModalInPresentation: false,onDismiss: {
//            self.isSelectedTimeSheet = true
//        }) {
//            DatePickerView(selectedDate: $selectedDate, type: .hourAndMinute)
//        }
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
                .padding(.horizontal)
                
                DatePicker("", selection: $selectedDate,displayedComponents: type)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "ko_KR"))
                    .background(.gray.opacity(0.2))
                    .cornerRadius(10)
            }

        }else{
            VStack{
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
//            TrainerScheduleMakeView()
            DatePickerView(selectedDate: .constant(Date()), type: .hourAndMinute)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
