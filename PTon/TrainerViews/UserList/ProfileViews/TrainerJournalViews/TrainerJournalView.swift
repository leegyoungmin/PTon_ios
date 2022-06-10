//
//  TrainerJournalView.swift
//  PTon
//
//  Created by 이경민 on 2022/04/03.
//

import SwiftUI
import Kingfisher

//MARK: - MONTH VIEW
struct TrainerJournalCalendarView:View{
    @EnvironmentObject var viewModel:TrainerJournalViewModel
    let dayOfWeek = ["일","월","화","수","목","금","토"]
    
    var body: some View{
        VStack{
            HStack(spacing:0){
                Button {
                    withAnimation {
                        viewModel.currentMonth -= 1
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
                        viewModel.currentMonth += 1
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
                                        .opacity(isSameDay(date1: value.date, date2: viewModel.currentDate) ? 1:0)
                                )
                                .onTapGesture {
                                    viewModel.currentDate = value.date
                                    
                                    viewModel.ObserveData()
                                }
                        }else{
                            Rectangle()
                                .fill(.clear)
                        }
                        
                    }
                }
                .padding(.top,10)
                
                
            }
            .padding(10)
            .background(backgroundColor)
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func cardView(value :DateValue) -> some View{
        VStack{
            if value.day != -1{
                Text("\(value.day)")
                    .foregroundColor(isSameDay(date1: value.date, date2: viewModel.currentDate) ? .accentColor:.gray)
                    .font(.footnote)
                    .fontWeight(isSameDay(date1: value.date, date2: viewModel.currentDate) ? .semibold:.regular)
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
        let date = formatter.string(from: viewModel.currentDate)
        
        return date.components(separatedBy: " ")
    }
    
    func getCurrentMonth()->Date{
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month, value: viewModel.currentMonth, to: Date()) else{return Date()}
        
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

//MARK: - JOURNAL VIEW
struct TrainerJournalView: View {
    @StateObject var viewModel:TrainerJournalViewModel
    let userName:String
    @State var isShowZoomView:Bool = false
    @State var selectedUrl:String = ""
    
    
    @ViewBuilder
    private func titleView(for title:String,_ isShowkcal:Bool)-> some View{
        HStack{
            Text("\(userName)님의 "+title)
                .font(.title3)
                .fontWeight(.light)
            Spacer()
            Text("권장칼로리 2200Kcal")
                .opacity(isShowkcal ? 1:0)
        }
        .padding(.vertical,10)
        .overlay(
            RoundedRectangle(cornerRadius: 1)
                .fill(.black)
                .frame(height:1)
            ,alignment: .bottom
        )
        .padding(.horizontal)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack{
                
                TrainerJournalCalendarView()
                    .environmentObject(self.viewModel)
                
                self.titleView(for: "식단", true)
                
                ForEach(mealType.allCases,id:\.self){type in
                    TrainerMealCellView(mealType: type,items: viewModel.meals.filter({$0.mealType == type}),isShowZoom: $isShowZoomView,selectedUrl: $selectedUrl)
                }
                
                self.titleView(for: "운동", false)
                TabView {
                    ForEach(viewModel.requestExercises.sorted(by: {$0.key < $1.key}),id:\.key){ key,value in
                        TrainerExerciseView(title: key, requestExercises: value)
                            .padding(.horizontal)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(minHeight:300,maxHeight: 400)
            }
        }
        .navigationTitle("일지확인")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isShowZoomView) {
            zoomView(url: $selectedUrl,isOpen: $isShowZoomView)
        }
        
    }
}

struct TrainerMealCellView:View{
    let mealType:mealType
    let items:[userFoodResult]
    @Binding var isShowZoom:Bool
    @Binding var selectedUrl:String
    var body: some View{
        VStack{
            HStack{
                Text(mealType.description())
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())], alignment: .center,spacing: 20) {
                ForEach(items,id:\.id){ meal in
                    VStack{
                        KFImage(URL(string: meal.url))
                            .onFailureImage(KFCrossPlatformImage(named: "appIcon"))
                            .resizable()
                            .frame(width: 80, height: 80, alignment: .center)
                            .clipShape(Circle())
                        
                        Text(meal.foodName)
                            .font(.footnote)
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("\(meal.kcal) kcal")
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                    }
                }
                
                Image(systemName: "plus.circle")
                    .font(.system(size: 50))
                    .foregroundColor(backgroundColor)
                
                
            }
            .padding()
            
            Divider()
        }
        .padding(.horizontal)
        .padding(.vertical,10)
    }
}

struct TrainerExerciseView:View{
    let title:String
    let requestExercises:[RequestExerciseResult]
    @State var index:Int = 0
    
    func RequestRate()->Double{
        let doneCount = Double(requestExercises.filter({$0.done == true}).count)
        return doneCount / Double(requestExercises.count)
    }
    
    var body: some View{
        VStack(alignment: .center) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            HStack{
                Spacer()
                
                Button {
                    print(123)
                } label: {
                    VStack(alignment: .center,spacing: 20) {
                        Text("일지 수행 운동 수")
                        
                        Text("65%")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button {
                    print(123)
                } label: {
                    VStack(alignment: .center,spacing: 20) {
                        Text("요청 운동 수행률")
                        
                        Text(convertPercent(Double(RequestRate())))
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }//HSTACK
            .padding(.bottom)
            
            Divider()
            
            HStack{
                ForEach(1..<5,id:\.self){ index in
                    Text("\(index)")
                        .font(.title3)
                }
            }
            .padding()
            
        }//VSTACK
        .background(backgroundColor)
        .cornerRadius(20)
    }
}

struct zoomView:View{
    @Binding var url:String
    @Binding var isOpen:Bool
    @State var imageScale:CGFloat = 1
    @State var imageOffset:CGSize = .zero
    @State var isShowBar:Bool = false
    
    func resetImageState() {
        return withAnimation(.spring()) {
            imageScale = 1
            imageOffset = .zero
        }
    }
    
    var body: some View{
        
        KFImage(URL(string: url))
            .resizable()
            .scaledToFit()
            .scaleEffect(imageScale)
            .aspectRatio(contentMode: .fit)
            .offset(x: imageOffset.width, y: imageOffset.height)
        //MARK: - 2. TWO TAP GESTURE
            .onTapGesture(count: 2, perform: {
                if imageScale == 1 {
                    withAnimation(.spring()) {
                        imageScale = 5
                    }
                } else {
                    resetImageState()
                }
            })
        //MARK: - 2. ONE TAP GESTURE
            .onTapGesture(count: 1, perform: {
                withAnimation {
                    isShowBar.toggle()
                }
                
            })
        // MARK: - 3. DRAG GESTURE
            .gesture(
                DragGesture()
                    .onChanged { value in
                        withAnimation(.linear(duration: 1)){
                            if imageScale == 1{
                                imageOffset.height = value.translation.height
                            }else{
                                imageOffset = value.translation
                            }
                        }
                    }
                    .onEnded { value in
                        if (value.startLocation.y - value.predictedEndLocation.y) < 100 && imageScale == 1{
                            withAnimation(.spring()){
                                isOpen = false
                            }
                        }else{
                            resetImageState()
                        }
                    }
            )
        // MARK: - 4. MAGNIFICATION
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        withAnimation(.linear(duration: 1)) {
                            if imageScale >= 1 && imageScale <= 5 {
                                imageScale = value
                            } else if imageScale > 5 {
                                imageScale = 5
                            } else {
                                resetImageState()
                            }
                        }
                    }
                    .onEnded { _ in
                        if imageScale > 5 {
                            imageScale = 5
                        } else if imageScale <= 1 {
                            resetImageState()
                        }
                    }
            )
    }
}

struct TrainerJournalView_Previews: PreviewProvider {
    @StateObject static var viewModel = TrainerJournalViewModel(trainerId: "3yvE0bnUEHbvDKasU1Orf7DhvjX2", userId: "kakao:1967260938")
    static var previews: some View {
        Text("Example")
    }
}
