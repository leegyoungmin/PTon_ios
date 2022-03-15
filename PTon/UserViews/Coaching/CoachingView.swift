//
//  CoachingView.swift
//  PTon
//
//  Created by 이관형 on 2022/02/18.
//

import SwiftUI

struct CoachingView: View {
    
    @State var tabIndex = 0
    @State var showingCalendar = false //showingAlert
    @State var selectedDate: Date? = nil //savedDate
    @State var selectedStringDate: String? //savedObjDate
    @State var nowDate: String = "" //tempDate
    @State var trainerId: String
    
    var body: some View {
        VStack{
            HStack{
                Image(systemName: "calendar")
                    .resizable()
                    .frame(width: 32, height: 32, alignment: .trailing)
                    .onTapGesture{
                        showingCalendar = true
                    }
                Spacer()
                
                
                //날짜 보여주기
                //현재: 2021-02-18
//TODO: 보여주는 창은 2월 18일
                Text(selectedStringDate ?? nowDate)
                    .onAppear{
                        nowDate = { () -> String in
                            let formatterYear = DateFormatter()
                            formatterYear.dateFormat = "yyyy-MM-dd"
                            return formatterYear.string(from: Date())
                        }()
                    }
                    .onChange(of: self.selectedStringDate){ newValue in
                        nowDate = newValue!
                    }
                Spacer()
            }
            .padding(.horizontal)
            
            
            //날짜 띄우기
            //TODO: animation IOS 15.0 버전에 맞게 value 추가 y축 계산
            if showingCalendar{
                CoachDatePicker(showingCalendar: $showingCalendar,
                                selectedDate: $selectedDate,
                                selectedStringDate: $selectedStringDate,
                                selectingDate: selectedDate ?? Date())
//                    .animation(.linear)
                    .transition(.opacity)
            }
            
            
            CoachTabBar(tabIndex: $tabIndex)
            switch(tabIndex){
            case 0: CoachingRoutineView()
            case 1: CoachingFitnessView(date: nowDate, trainerId: self.trainerId)
            case 2: CoachingCompoundView(date: nowDate, trainerId: self.trainerId)
            case 3: CoachingBackView(date: nowDate, trainerId: self.trainerId)
            case 4: CoachingChestView(date: nowDate, trainerId: self.trainerId)
            case 5: CoachingArmView(date: nowDate, trainerId: self.trainerId)
            case 6: CoachingLegView(date: nowDate, trainerId: self.trainerId)
            case 7: CoachingAbsView(date: nowDate, trainerId: self.trainerId)
            default: CoachingRoutineView()
            }
            Spacer()
        }
        .navigationBarHidden(false)
    }
}

struct CoachDatePicker: View{
    
    @Binding var showingCalendar: Bool
    @Binding var selectedDate: Date?
    @Binding var selectedStringDate: String?
    @State var selectingDate: Date = Date()
    
    var body: some View{
        ZStack{
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                DatePicker("Coaching", selection: $selectingDate, in: Date()..., displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    
                Divider()
                
                HStack{
                    Button(action: {
                        print("취소 버튼 Clicked")
                        showingCalendar = false
                    }, label: {
                        Text("취소")
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        selectedDate = selectingDate
                        var savedStringDate: String = ""
                        savedStringDate = DateFormattertoString(date: selectingDate)
                        selectedStringDate = savedStringDate
                        showingCalendar = false
                    }, label: {
                        Text("저장")
                            .bold()
                    })
                    
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.white
                            .cornerRadius(30))
        }
    }
    
    func DateFormattertoString(date: Date?) -> String{
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date ?? Date())
    }
    
}


struct CoachTabBar: View{
    @Binding var tabIndex: Int
    
    var body: some View{
        ScrollView(.horizontal, showsIndicators: false, content: {
            HStack(spacing: 30){
                TabBarButton(text: "루틴", isSelected: .constant(tabIndex == 0))
                    .onTapGesture {
                        onButtonTapped(index: 0)
                    }
                TabBarButton(text: "피트니스", isSelected: .constant(tabIndex == 1))
                    .onTapGesture {
                        onButtonTapped(index: 1)
                    }
                TabBarButton(text: "복합운동", isSelected: .constant(tabIndex == 2))
                    .onTapGesture {
                        onButtonTapped(index: 2)
                    }
                TabBarButton(text: "등", isSelected: .constant(tabIndex == 3))
                    .onTapGesture{
                        onButtonTapped(index: 3)
                    }
                TabBarButton(text: "가슴", isSelected: .constant(tabIndex == 4))
                    .onTapGesture {
                        onButtonTapped(index: 4)
                    }
                TabBarButton(text: "팔", isSelected: .constant(tabIndex == 5))
                    .onTapGesture{
                        onButtonTapped(index: 5)
                    }
                TabBarButton(text: "다리", isSelected: .constant(tabIndex == 6))
                    .onTapGesture {
                        onButtonTapped(index: 6)
                    }
                TabBarButton(text: "복근", isSelected: .constant(tabIndex == 7))
                    .onTapGesture {
                        onButtonTapped(index: 7)
                    }
                Spacer()
            }
        })
            .border(width: 1, edges: [.bottom], color: .black)
    }
    private func onButtonTapped(index: Int){
        withAnimation{tabIndex = index}
    }
}

struct CoachingView_Previews:PreviewProvider{
    static var previews: some View{
        CoachingView(trainerId: "ㅁㄴㅇㅁㄴㅇ")
    }
}

struct TabBarButton: View{
    let text: String
    @Binding var isSelected: Bool
    
    var body: some View{
        Text(text)
            .fontWeight(isSelected ? .heavy : .regular)
            .font(.system(size: 20))
            .padding(.bottom, 10)
            .border(width: isSelected ? 2: 1, edges: [.bottom], color: .black)
    }
    
}


struct EdgeBorder: Shape{
    var width: CGFloat
    var edges: [Edge]
    
    func path(in rect: CGRect) -> Path{
        var path = Path()
        for edge in edges {
            var x: CGFloat{
                switch edge{
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }
            
            var y: CGFloat{
                switch edge{
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }
            var w: CGFloat{
                switch edge{
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }
            
            var h: CGFloat{
                switch edge{
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

extension View{
    func border(width: CGFloat, edges: [Edge], color: SwiftUI.Color) -> some View{
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
