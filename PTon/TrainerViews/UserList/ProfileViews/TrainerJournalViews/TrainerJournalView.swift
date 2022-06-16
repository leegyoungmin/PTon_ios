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
                                    
                                    //                                    viewModel.ObserveData()
                                    
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

enum TrainerJournalSelectedType:Identifiable{
    var id:Self{self}
    case record
    case request
}

//MARK: - JOURNAL VIEW
struct TrainerJournalView: View {
    @StateObject var viewModel:TrainerJournalViewModel
    let userName:String
    @State var isShowZoomView:Bool = false
    @State var selectedUrl:String = ""
    @State var isShowDetailView:Bool = false
    @State var selecteItemType:TrainerJournalSelectedType? = nil
    @State var selectedExercisePart:exercisePart? = nil
    
    private func checkRecordHas(_ exercisePart:exercisePart)->Bool{
        return viewModel.recordedExercises.filter({$0.part == exercisePart.rawValue}).count == 0 ? false:true
    }
    
    private func checkRequestHas(_ exercisePart:exercisePart)->Bool{
        return viewModel.requestExercises.filter({$0.part == exercisePart}).count == 0 ? false:true
    }
    
    @ViewBuilder
    private func titleView(for title:String,_ isShowkcal:Bool)-> some View{
        HStack{
            Text("\(userName)님의 "+title)
                .font(.title3)
                .fontWeight(.light)
            Spacer()
            Text("권장칼로리 \(viewModel.kcal)kcal")
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
                
                ForEach(mealType.allCases,id:\.self){ type in
                    TrainerMealCellView(mealType: type, items: viewModel.meals[type] ?? [])
                }
                
                self.titleView(for: "운동", false)
                if viewModel.requestExercises.isEmpty && viewModel.recordedExercises.isEmpty{
                    Text("아직 기록된 운동이 없습니다.")
                        .frame(height:300)
                } else {
                    TabView {
                        ForEach(exercisePart.allCases,id:\.self){ part in
                            if checkRecordHas(part) || checkRequestHas(part){
                                TrainerExerciseView(exercisePart: part, selectedType: $selecteItemType,selectedExercisePart: $selectedExercisePart)
                                    .environmentObject(self.viewModel)
                            }
                        }
                    }
                    .frame(height:300)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
            }
        }
        .navigationTitle("일지확인")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedExercisePart,onDismiss: {
            self.selectedExercisePart = nil
            self.selecteItemType = nil
        }, content: { part in
            if selecteItemType == .record{
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(viewModel.filterRecordExercise(part),id:\.self){ exercise in
                        trainerRecordExerciseCellView(exercise: exercise)
                    }
                }
            }else {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(viewModel.filterRequestExercise(part),id:\.self){ exercise in
                        trainerRequestExerciseCellView(exercise: exercise)
                    }
                }
            }
        })
    }
}

struct trainerRequestExerciseCellView:View{
    let exercise:TrainerExercise
    var body: some View{
        VStack(spacing:0){
            HStack{
                KFImage(URL(string: exercise.exerciseData.url))
                    .onFailureImage(KFCrossPlatformImage(named: "defaultImage"))
                    .resizable()
                    .scaledToFill()
                    .frame(width:80,height:80)
                    .cornerRadius(50)
                    .overlay(
                        Circle()
                            .stroke(backgroundColor)
                    )
                
                
                VStack(alignment:.leading,spacing: 10){
                    HStack {
                        Text(exercise.exerciseName)
                            .font(.title3.bold())
                        Spacer()
                    }
                    
                    HStack(alignment: .center, spacing: 5) {
                        VStack(spacing:0){
                            Text(exercise.exerciseData.weight == nil ? "-":"\(exercise.exerciseData.weight!)")
                            Text("kg")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(width: 60, height: 60, alignment: .center)
                        .background(backgroundColor)
                        .cornerRadius(50)
                        .clipShape(Circle())
                        
                        Spacer()
                        
                        VStack(spacing:0){
                            Text(exercise.exerciseData.time == nil ? "-":"\(exercise.exerciseData.time!)")
                            Text("회")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(width: 60, height: 60, alignment: .center)
                        .background(backgroundColor)
                        .cornerRadius(50)
                        .clipShape(Circle())
                        
                        Spacer()
                        
                        VStack(spacing:0){
                            Text(exercise.exerciseData.set == nil ? "-":"\(exercise.exerciseData.set!)")
                            Text("세트")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(width: 60, height: 60, alignment: .center)
                        .background(backgroundColor)
                        .cornerRadius(50)
                        .clipShape(Circle())
                        
                        Spacer()
                    }//HSTACK
                    
                }//VSTACK
                
            }//HSTACK
            
            Divider()
                .padding(.top,5)
        }
        .padding()
    }
}

struct trainerRecordExerciseCellView:View{
    let exercise:TrainerRecordExercise
    
    var body: some View{
        VStack(spacing:0){
            HStack{
                KFImage(URL(string: exercise.url))
                    .onFailureImage(KFCrossPlatformImage(named: "defaultImage"))
                    .resizable()
                    .scaledToFill()
                    .frame(width:80,height:80)
                    .cornerRadius(50)
                    .overlay(
                        Circle()
                            .stroke(backgroundColor)
                    )
                
                
                VStack(alignment:.leading,spacing: 10){
                    HStack {
                        Text(exercise.exerciseName)
                            .font(.title3.bold())
                        Spacer()
                        Text("\(Int(exercise.expectKcal))kcal")
                    }
                    
                    HStack(alignment: .center, spacing: 5) {
                        VStack(spacing:0){
                            Text(exercise.weight ?? "")
                            Text("kg")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(width: 60, height: 60, alignment: .center)
                        .background(backgroundColor)
                        .cornerRadius(50)
                        .clipShape(Circle())
                        
                        Spacer()
                        
                        VStack(spacing:0){
                            Text(exercise.time ?? "")
                            Text("회")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(width: 60, height: 60, alignment: .center)
                        .background(backgroundColor)
                        .cornerRadius(50)
                        .clipShape(Circle())
                        
                        Spacer()
                        
                        VStack(spacing:0){
                            Text(exercise.set ?? "")
                            Text("세트")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(width: 60, height: 60, alignment: .center)
                        .background(backgroundColor)
                        .cornerRadius(50)
                        .clipShape(Circle())
                        
                        Spacer()
                    }//HSTACK
                    
                }//VSTACK
                
            }//HSTACK
            
            Divider()
                .padding(.top,5)
        }
        .padding()
    }
}

struct TrainerMealCellView:View{
    let mealType:mealType
    let items:[TrainerMealRecorded]
    var body: some View{
        VStack{
            HStack{
                Text(mealType.description())
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())], alignment: .center,spacing: 20) {
                ForEach(items,id:\.foodName){ meal in
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
    @EnvironmentObject var viewModel:TrainerJournalViewModel
    let exercisePart:exercisePart
    @Binding var selectedType:TrainerJournalSelectedType?
    @Binding var selectedExercisePart:exercisePart?
    
    var body: some View{
        VStack(alignment: .center,spacing:0) {
            Text(exercisePart.description)
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            HStack(alignment:.center,spacing:10){
                Spacer()
                
                Button {
                    if viewModel.filterRecordExercise(exercisePart).count != 0{
                        selectedExercisePart = exercisePart
                        selectedType = .record
                    }
                    
                } label: {
                    VStack(alignment: .center,spacing: 20) {
                        Text("일지 수행 운동 수")
                        
                        Text("\(viewModel.recordExerciseCount(exercisePart))")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                Button {
                    if viewModel.filterRequestExercise(exercisePart).count != 0{
                        selectedExercisePart = exercisePart
                        selectedType = .request
                    }
                } label: {
                    VStack(alignment: .center,spacing: 20) {
                        Text("요청 운동 수행률")
                        
                        Text(convertPercent(viewModel.requestExerciseSuccessRate(exercisePart)))
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                
            }//HSTACK
            
            Divider()
                .padding(.vertical,10)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                VStack(alignment: .center, spacing: 5) {
                    Text("운동칼로리")
                    Text("\(viewModel.convertKcal(exercisePart))kcal")
                }
                VStack(alignment: .center, spacing: 5) {
                    Text("수행운동수")
                    Text("\(viewModel.recordExerciseCount(exercisePart))개")
                }
                VStack(alignment: .center, spacing: 5) {
                    Text("요청운동개요")
                    Text(viewModel.requestExerciseAllCount(exercisePart) == 0 ? "-":"\(viewModel.requestExerciseSuccessCount(exercisePart))/\(viewModel.requestExerciseAllCount(exercisePart))")
                }
            }
            
        }//VSTACK
        .padding(.vertical)
        .background(backgroundColor)
        .cornerRadius(10)
        .padding(.horizontal)
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
        //        Text("Example")
        //        TrainerExerciseView(exercisePart: .Leg, selectedType: .constant(nil), selectedExercisePart: .constant(.Leg))
        //            .environmentObject(self.viewModel)
        Group {
            //            TrainerJournalView(viewModel: viewModel, userName: "이경민")
            trainerRecordExerciseCellView(exercise: TrainerRecordExercise(engName: "asd", exerciseName: "180로테이션 스쿼트 점프", expectKcal: 139.0, hydro: "AnAerobic", minute: 20, parameter: 3.0, part: "Leg", set: "20", time: "20", url: "", weight: "20"))
                .previewLayout(.sizeThatFits)
        }
        
        
    }
}
