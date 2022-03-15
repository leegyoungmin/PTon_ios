//
//  TrainerCalendarView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/11.
//

import SwiftUI

struct TrainerCalendarView: View {
    let dayOfWeek = ["일","월","화","수","목","금","토"]
    @Binding var currentDate:Date
    
    //Month update on arrow Button clicks
    @State var currentMonth:Int = 0
    
    var body: some View {
        VStack{
            VStack{
                HStack(spacing:0){
                    Button {
                        withAnimation {
                            currentMonth -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left.square.fill")
                            .font(.title2)
                    }
                    .foregroundColor(.accentColor)
                    
                    Spacer()
                    
                    Text("\(extraDate()[1])년 \(extraDate()[0])")
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            currentMonth += 1
                        }
                    } label: {
                        Image(systemName: "chevron.right.square.fill")
                            .font(.title2)
                    }
                    .foregroundColor(.accentColor)

                }
                .padding(.bottom,10)
                .padding(.top,10)
                
                VStack(spacing:0){
                    
                    let columns = Array(repeating: GridItem(.flexible()), count: 7)
                    
                    //MARK: - weekofDay View
                    LazyVGrid(columns: columns,spacing: 20) {
                        ForEach(dayOfWeek.indices,id: \.self){ index in
                            if index == 0{
                                Text(dayOfWeek[index])
                                    .foregroundColor(.red)
                            }else if index == 6{
                                Text(dayOfWeek[index])
                                    .foregroundColor(.blue)
                            }else{
                                Text(dayOfWeek[index])
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding(.bottom,10)
                    
                    Divider()
                    //MARK: - Date View
                    LazyVGrid(columns: columns,spacing: 20) {
                        
                        ForEach(extractDate()) { value in
                            if value.day != -1{
                                cardView(value: value)
                                    .background(
                                        Circle()
                                            .stroke(Color.accentColor)
                                            .opacity(isSameDay(date1: value.date, date2: currentDate) ? 1:0)
                                    )
                                    .onTapGesture {
                                        currentDate = value.date
                                    }
                            }else{
                                Rectangle()
                                    .fill(.clear)
                            }

                        }
                    }
                    .padding(.top,10)
                    
                    
                }
            }
            .padding(.horizontal)
            .onChange(of: currentMonth) { newValue in
                withAnimation {
                    currentDate = getCurrentMonth()
                }
            }
            
            TrainerScheduleView(viewmodel: ScheduleViewModel(), selectedDate: $currentDate)
        }
        .background(Color("Background"))
    }
}

struct MonthDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        TrainerCalendarView(currentDate: .constant(Date()))
    }
}

extension TrainerCalendarView{
    @ViewBuilder
    func cardView(value :DateValue) -> some View{
        VStack{
            if value.day != -1{
                Text("\(value.day)")
                    .foregroundColor(isSameDay(date1: value.date, date2: currentDate) ? .accentColor:.gray)
                    .font(.footnote)
                    .fontWeight(isSameDay(date1: value.date, date2: currentDate) ? .semibold:.regular)
            }
        }
        .frame(width: 20, height: 20, alignment: .center)
    }
    
    func isSameDay(date1:Date,date2:Date)->Bool{
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    func extraDate()->[String]{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        let date = formatter.string(from: currentDate)
        
        return date.components(separatedBy: " ")
    }
    
    func getCurrentMonth()->Date{
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else{return Date()}
        
        return currentMonth
    }
    
    func extractDate()->[DateValue]{
        //Getting current Month date
        
        let calendar = Calendar.current
        
        let currentMonth = getCurrentMonth()
        
        var days =  currentMonth.getAllDates().compactMap{ date -> DateValue in
            let day = calendar.component(.day, from: date)
            
            return DateValue(day: day, date: date)
        }
        
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())

        for _ in 0..<firstWeekday-1{
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        return days
    }
}

extension Date{
    func getAllDates()->[Date]{
        let calendar = Calendar.current
        
        //getting start date...
        
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
        
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        return range.compactMap{ day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}
