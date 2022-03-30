//
//  WeekDatePickerView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import SwiftUI

struct weekDatePickerView:View{
    let dayOfWeek = ["일","월","화","수","목","금","토"]
    @Binding var currentDate:Date
    
    //Month update on arrow Button clicks
    @State var currentMonth:Int = 0
    var body: some View{
        VStack(spacing:0){
            VStack(spacing:0){
                HStack(spacing:0){
                    Button {
                        withAnimation {
                            currentMonth -= 7
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
                            currentMonth += 7
                        }
                    } label: {
                        Image(systemName: "chevron.right.square.fill")
                            .font(.title2)
                    }
                    .foregroundColor(.accentColor)

                }
                .padding(.vertical,10)
                
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
                                        print("Get value date ::: \(value.date)")
                                        currentDate = value.date
                                        print("get current Date ::: \(currentDate)")
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
            .onChange(of: currentMonth) { newValue in
                withAnimation {
                    currentDate = getCurrentMonth()
                }
            }
            .onAppear {
                print("Get data month ::: \(getCurrentMonth())")
                print("get day ::: \(extractDate())")
            }
        }
        .background(.white)
    }
}

struct weekDatePickerView_Previews:PreviewProvider{
    static var previews: some View{
        weekDatePickerView(currentDate: .constant(Date()))
            .previewLayout(.sizeThatFits)
    }
}

extension Date{
    func getAllWeek()->[Date]{
        let calendar = Calendar.current
        //getting start date...
        
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year,.month,.day,.weekday], from: self))!
        
        let range = calendar.range(of: .weekday, in: .weekOfMonth, for: startDate)!

        return range.compactMap{ day -> Date in
            return calendar.date(byAdding: .weekday, value: day, to: startDate)!
        }
    }
}


extension weekDatePickerView{
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

        guard let currentMonth = calendar.date(byAdding: .weekday, value: currentMonth, to: Date()) else{return Date()}

        return currentMonth
    }

    func extractDate()->[DateValue]{
        //Getting current Month date

        let calendar = Calendar.current

        let currentMonth = getCurrentMonth()

        var days =  currentMonth.getAllWeek().compactMap{ date -> DateValue in
            let dateWeek = calendar.component(.weekday, from: date)
            let day = calendar.component(.day, from: date)

            return DateValue(dateWeek: dateWeek, day: day, date: date)
        }

        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for index in (0..<firstWeekday-1).reversed(){
            let day = calendar.component(.day, from: days.first?.date.addingTimeInterval(-86400) ?? Date())
            days.insert(DateValue(dateWeek: index, day: day, date: days.first?.date.addingTimeInterval(-86400) ?? Date()) , at: 0)
            days.removeLast()
        }

        
        print("Date in selected Date \(days)")
        return days
    }

}

