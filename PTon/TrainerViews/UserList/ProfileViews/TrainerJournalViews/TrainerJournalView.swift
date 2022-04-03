//
//  TrainerJournalView.swift
//  PTon
//
//  Created by 이경민 on 2022/04/03.
//

import SwiftUI
import SDWebImageSwiftUI

struct TrainerJournalView: View {
    @StateObject var viewModel:TrainerJournalViewModel
    let dayOfWeek = ["일","월","화","수","목","금","토"]
    let userName:String
    @State var currentDate = Date()
    @State var currentMonth:Int = 0
    @State var isShowZoomView:Bool = false
    @State var selectedUrl:String = ""
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
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
                                            withAnimation {
                                                viewModel.ObserveData(currentDate)
                                            }
                                            
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
                .onChange(of: currentMonth) { newValue in
                    withAnimation {
                        currentDate = getCurrentMonth()
                        viewModel.ObserveData(currentDate)
                    }
                }
                
                HStack{
                    Text("\(userName)님의 식단")
                        .font(.title3)
                        .fontWeight(.light)
                    Spacer()
                    Text("권장칼로리 2200Kcal")
                }
                .padding(.vertical,10)
                .overlay(
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.black)
                        .frame(height:1)
                    ,alignment: .bottom
                )
                .padding(.horizontal)
                
                ForEach(mealType.allCases,id:\.self){ type in
                    TrainerMealCellView(mealType: type,items: viewModel.meals.filter({$0.mealtype == type}),isShowZoom: $isShowZoomView,selectedUrl: $selectedUrl)
                }
                
                HStack{
                    Text("\(userName)님의 운동")
                        .font(.title3)
                        .fontWeight(.light)
                    Spacer()
                }
                .padding(.vertical,10)
                .overlay(
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.black)
                        .frame(height:1)
                    ,alignment: .bottom
                )
                .padding(.horizontal)
                
                if viewModel.exercises.isEmpty{
                    Text("작성된 운동이 없습니다.")
                        .frame(minHeight:200)
                }else{
                    ForEach(viewModel.exercises,id:\.self){ exercise in
                        if exercise.hydro == "Aerobic"{
                            HStack{
                                VStack(alignment:.leading){
                                    Text(exercise.exerciseName)
                                    
                                    HStack{
                                        Text("200Kcal")
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .frame(width:3,height: 18)
                                            .foregroundColor(.black)
                                        
                                        Text(exercise.time ?? "0")+Text("분")
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(backgroundColor)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        else if exercise.hydro == "AnAerobic"{
                            HStack{
                                VStack(alignment: .leading){
                                    HStack{
                                        Text(exercise.exerciseName)
                                        Text(exercise.part ?? "")
                                            .font(.footnote)
                                            .foregroundColor(.accentColor)
                                            .padding(5)
                                            .background(.white)
                                            .cornerRadius(5)
                                    }
                                    
                                    HStack{
                                        Text("200Kcal")
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .frame(width:3,height: 18)
                                            .foregroundColor(.black)
                                        
                                        
                                        Text(exercise.weight ?? "")+Text("Kg")
                                        
                                        Text("x")
                                        
                                        Text(exercise.time ?? "")+Text("회")
                                        
                                        Text(exercise.sets ?? "")+Text("세트")
                                        
                                    }
                                    
                                }
                                
                                Spacer()
                                
                            }
                            .padding()
                            .background(backgroundColor)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
                
                

                
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
    let items:[userMeal]
    @Binding var isShowZoom:Bool
    @Binding var selectedUrl:String
    var body: some View{
        VStack{
            HStack{
                Text(mealType.rawValue)
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())], alignment: .center,spacing: 20) {
                ForEach(items,id:\.self){ meal in
                    VStack{
                        
                        WebImage(url: URL(string: meal.url))
                            .placeholder(Image("defaultImage"))
                            .resizable()
                            .frame(width: 80, height: 80, alignment: .center)
                            .clipShape(Circle())
                            .onTapGesture {
                                withAnimation {
                                    self.selectedUrl = meal.url
                                    self.isShowZoom = true
                                }
                                
                            }
                        
                        Text(meal.name)
                            .font(.footnote)
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("180kcal")
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
        WebImage(url: URL(string: url))
            .placeholder(Image("defaultImage"))
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
    static var previews: some View {
        TrainerJournalView(viewModel: TrainerJournalViewModel(trainerId: "3yvE0bnUEHbvDKasU1Orf7DhvjX2", userId: "kakao:1967260938"), userName: "이경민")
//        TrainerMealCellView(mealType: .first, items: [userMeal(mealtype: .first, uuid: "asd", name: "회1접시", url: "https://firebasestorage.googleapis.com:443/v0/b/pton-1ffc0.appspot.com/o/food%2Ffood_3yvE0bnUEHbvDKasU1Orf7DhvjX2_kakao:1967260938_0_2022-04-03%2021:38?alt=media&token=43026c45-b0f4-45eb-a734-c0add71eb05a")])
//            .previewLayout(.sizeThatFits)
//            .padding(.horizontal)
    }
}

extension TrainerJournalView{
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
