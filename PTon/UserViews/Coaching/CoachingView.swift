//
//  CoachingView.swift
//  PTon
//
//  Created by 이관형 on 2022/02/18.
//

import SwiftUI
import Kingfisher

struct Tabs<Label:View>:View{
    
    @Binding var tabs:[String]
    @Binding var selection:Int
    let underlineColor:Color
    let label:(String,Bool) -> Label
    
    var body: some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 0) {
                ForEach(tabs,id:\.self) {
                    self.tab(title:$0)
                }
            }
        }
    }
    
    private func tab(title:String) -> some View{
        let index = self.tabs.firstIndex(of: title)!
        let isSelected = index == selection
        return Button {
            withAnimation {
                self.selection = index
            }
        } label: {
            label(title, isSelected)
                .frame(width:UIScreen.main.bounds.width/5)
                .padding(.bottom)
                .background(
                    Rectangle()
                        .foregroundColor(.clear)
                        .overlay(
                            Rectangle()
                                .frame(width:UIScreen.main.bounds.width/5,height:2)
                                .foregroundColor(isSelected ? .black:Color(uiColor: UIColor.lightGray))
                                .transition(.move(edge: .bottom))
                            ,alignment: .bottom
                        )
                )
        }
        .buttonStyle(.plain)
        
    }
}


struct CoachingView: View {
    @StateObject var viewModel:CoachViewModel
    let exercisePartList = exercisePart.allCases
    @State private var selectedTab = 0
    @State var exerciseType = RequestingExerciseType.allCases.map({$0.rawValue})
    
    var body: some View {
        VStack(spacing:0){
            weekDatePickerView(selectedDate: $viewModel.selectedDate)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [.init()], alignment: .center) {
                    ForEach(exercisePartList.indices,id:\.self){ index in
                        Button {
                            withAnimation {
                                selectedTab = index
                            }
                        } label: {
                            Text(exercisePartList[index].description)
                                .font(.title3.bold())
                                .foregroundColor(selectedTab == index ? Color.accentColor:.black)
                                .padding(.horizontal,10)
                        }
                    }
                }
            }
            .background(Color.white)
            .frame(height:40)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height:1.5)
                    .padding(.top,10)
                    .padding(.horizontal,-5)
                ,alignment: .bottom
            )
            
            VStack{
                
                if viewModel.coachExerciseList.filter({$0.part == exercisePartList[selectedTab].rawValue}).isEmpty{
                    
                    nullTextView()
                    
                }else{
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(viewModel.coachExerciseList.filter({$0.part == exercisePartList[selectedTab].rawValue}),id:\.self){ exercise in
                            if exercise.exerciseHydro == "Aerobic"{
                                CoachingAerobicCellView(exercise: exercise)
                                    .environmentObject(self.viewModel)
                            }else{
                                CoachingAnAerobicCellView(exercise: exercise)
                                    .environmentObject(self.viewModel)
                            }
                        }
                    }
                    .padding()
                }
                

            }
            .padding(.top,10)
            .background(backgroundColor)
        }
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    @ViewBuilder
    func nullTextView() -> some View{
        VStack{
            Spacer()
            HStack{
                Spacer()
                Text("요청된 운동이 없습니다.")
                Spacer()
            }
            
            Spacer()
        }
    }
}

struct CoachingAerobicCellView:View{
    @EnvironmentObject var viewModel:CoachViewModel
    @State var exercise:RequestingExercise
    
    
    
    var body: some View{
        HStack(spacing:10){
            
            CircleImage(url: exercise.url, size: CGSize(width: 50, height: 50))
            
            
            VStack(alignment: .leading, spacing: 5){
                Text(exercise.exerciseName)
                    .font(.body)
                
                Text("추천 \(exercise.minute) 분")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Text("예상 소모 칼로리 \(viewModel.exerciseKcal(exercise))kcal")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 15))
            }
            
            Spacer()
            
            Button {
                viewModel.ToggleDone(exercise)

            } label: {
                Image(systemName: exercise.done ? "checkmark.circle":"circle")
            }
            .disabled(
                convertString(content: viewModel.selectedDate, dateFormat: "yyyy-MM-dd") != convertString(content: Date(), dateFormat: "yyyy-MM-dd")
            )
            
        }
        .padding()
        .background(.white)
        .cornerRadius(3)
        .shadow(color: .gray.opacity(0.2), radius: 1, x: -1, y: -1)
        .shadow(color: .gray.opacity(0.2), radius: 1, x: 1, y: 1)
        
    }
}

struct CoachingAnAerobicCellView:View{
    @EnvironmentObject var viewModel:CoachViewModel
    @State var exercise:RequestingExercise
    var body: some View{
        HStack(spacing:10){
            
            CircleImage(url: exercise.url, size: CGSize(width: 50, height: 50))
            
            VStack(alignment: .leading, spacing: 5){
                Text(exercise.exerciseName)
                    .font(.body)
                
                HStack{
                    Text("\(exercise.weight ?? 0)kg")
                    
                    Divider()
                        .frame(height:10)
                    
                    Text("\(exercise.time ?? 0)회")
                    
                    Divider()
                        .frame(height:10)
                    
                    Text("\(exercise.set ?? 0)세트")
                }
                .foregroundColor(.gray)
                .font(.footnote)
                
                Text("예상 소모 칼로리 \(viewModel.exerciseKcal(exercise))kcal")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 15))
            }
            
            Spacer()
            
            Button {
                viewModel.ToggleDone(exercise)
            } label: {
                Image(systemName: exercise.done ? "checkmark.circle":"circle")
            }
            .disabled(
                convertString(content: viewModel.selectedDate, dateFormat: "yyyy-MM-dd") != convertString(content: Date(), dateFormat: "yyyy-MM-dd")
            )
            
        }
        .padding()
        .background(.white)
        .cornerRadius(3)
        .shadow(color: .gray.opacity(0.2), radius: 1, x: -1, y: -1)
        .shadow(color: .gray.opacity(0.2), radius: 1, x: 1, y: 1)
    }
}

struct CoachingView_Previews:PreviewProvider{
    static var dummyExercise = coachExercise(exerciseName: "example", exerciseType: "AnAerobic", exercisePart: "Back", sets: 10, weight: 10, time: 10, minute: 20, parameter: 3.2, imageUrl: "", isDone: false)
    static var previews: some View{
        CoachingView(viewModel: CoachViewModel("3yvE0bnUEHbvDKasU1Orf7DhvjX2", "kakao:1967260938"))
        //        CoachingAnAerobicCellView(exercise: dummyExercise)
        //            .previewLayout(.sizeThatFits)
        //            .padding()
    }
}
