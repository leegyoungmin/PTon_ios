//
//  WeekDatePickerView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import SwiftUI

struct weekDatePickerView:View{
    private var calendar:Calendar
    private let monthDayFormatter:DateFormatter
    private let dayFormatter:DateFormatter
    private let weekDayFormatter:DateFormatter
    
    @Binding var selectedDate:Date
    private static var now = Date()
    
    init(selectedDate:Binding<Date>){
        self._selectedDate = selectedDate
        self.calendar = Calendar.init(identifier: .gregorian)
        self.calendar.locale = Locale(identifier: "ko_KR")
        self.monthDayFormatter = DateFormatter(dateFormat:"MM월",calendar:calendar)
        self.dayFormatter = DateFormatter(dateFormat:"dd",calendar:calendar)
        self.weekDayFormatter = DateFormatter(dateFormat:"EEEEE",calendar:calendar)
    }
    
    var body: some View {
        VStack{
            CalendarWeekListView(calendar: calendar,date: $selectedDate) { date in
                Button {
                    selectedDate = date
                    
                } label: {
                    Text("00")
                        .font(.system(size: 13))
                        .padding(8)
                        .foregroundColor(.clear)
                        .overlay(
                            Text(dayFormatter.string(from: date))
                                .foregroundColor(
                                    calendar.isDate(date, inSameDayAs: selectedDate) ? .black:calendar.isDateInToday(date) ? .blue:.gray
                                )
                        )
                        .overlay(
                            Circle()
                                .foregroundColor(.gray.opacity(0.4))
                                .opacity(calendar.isDate(date, inSameDayAs: selectedDate) ? 1:0)
                        )
                }

            } header: { date in
                Text("00")
                    .font(.system(size: 13))
                    .padding(8)
                    .foregroundColor(.clear)
                    .overlay(
                        Text(weekDayFormatter.string(from: date))
                            .font(.system(size: 15))
                    )
            } weekSwitcher: { date in
                
                
                HStack{
                    
                    Button {
                        withAnimation {
                            guard let newDate = calendar.date(byAdding: .weekOfMonth, value: -1, to: selectedDate) else{
                                return
                            }
                            
                            selectedDate = newDate
                        }
                    } label: {
                        Label {
                            Text("Previous")
                        } icon: {
                            Image(systemName: "chevron.left.square")
                        }
                        .labelStyle(.iconOnly)

                    }
                    
                    Spacer()
                    
                    Text(monthDayFormatter.string(from: selectedDate))
                        .font(.title2)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            guard let newDate = calendar.date(byAdding: .weekOfMonth, value: 1, to: selectedDate) else{
                                return
                            }
                            
                            selectedDate = newDate
                        }
                    } label: {
                        Label {
                            Text("Next")
                        } icon: {
                            Image(systemName: "chevron.right.square")
                        }
                        .labelStyle(.iconOnly)

                    }
                }
                .padding(.horizontal,10)
                
            }

        }
        .padding(5)
        
    }
}

struct CalendarWeekListView<Day:View,Header:View,WeekSwitcher:View>:View{
    private var calendar:Calendar
    @Binding var date:Date
    private let content:(Date)->Day
    private let header:(Date)->Header
    private let weekSwitcher:(Date)->WeekSwitcher
    private let daysInWeek = 7
    
    init(
        calendar:Calendar,
        date:Binding<Date>,
        @ViewBuilder content:@escaping (Date)-> Day,
        @ViewBuilder header:@escaping(Date)->Header,
        @ViewBuilder weekSwitcher:@escaping(Date)->WeekSwitcher
    ){
        self.calendar = calendar
        self._date = date
        self.content = content
        self.header = header
        self.weekSwitcher = weekSwitcher
    }
    
    var body: some View{
        let month = date.startOfMonth(using: calendar)
        let dates = makeDays()
        VStack{
            HStack{
                self.weekSwitcher(month)
            }
            
            HStack(spacing:20){
                ForEach(dates.prefix(daysInWeek),id:\.self,content: header)
            }
            
            HStack(spacing:20){
                ForEach(dates,id:\.self){ date in
                    content(date)
                }
            }
        }
    }
}

//MARK: - HELPER
private extension CalendarWeekListView{
    func makeDays()->[Date]{
        guard let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: date),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: firstWeek.end - 1) else{
            return []
        }
        
        let dateInterval = DateInterval(start: firstWeek.start, end: lastWeek.end)
        
        return calendar.generateDays(for: dateInterval)
    }
}

private extension Calendar{
    func generateDates(for dateInterval:DateInterval,matching componenets:DateComponents)->[Date]{
        var dates = [dateInterval.start]
        
        enumerateDates(startingAfter: dateInterval.start, matching: componenets, matchingPolicy: .nextTime) { result, exactMatch, stop in
            guard let date = result else{return}
            guard date < dateInterval.end else{
                stop = true
                return
            }
            
            dates.append(date)
        }
        
        return dates
    }
    
    func generateDays(for dateInterval:DateInterval)->[Date]{
        generateDates(for: dateInterval, matching: dateComponents([.hour,.minute,.second], from: dateInterval.start))
    }
}

private extension Date{
    func startOfMonth(using calendar:Calendar)->Date{
        calendar.date(from: calendar.dateComponents([.year,.month], from: self)) ?? self
    }
    
}
private extension DateFormatter{
    convenience init(dateFormat:String,calendar:Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
        self.locale = Locale(identifier: "ko_KR")
    }
}

struct WeekDatePickerView_previews:PreviewProvider{
    static var previews: some View{
        weekDatePickerView(selectedDate: .constant(Date()))
    }
}
