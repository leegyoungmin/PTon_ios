//
//  CoachingView.swift
//  PTon
//
//  Created by 이관형 on 2022/02/18.
//

import SwiftUI

struct CoachingView: View {
    @StateObject var viewModel:CoachViewModel
    let compareType:[String] = ["Fitness","Aerobic","Back","Chest","Arm","Leg","Shoulder","Abs"]
    @State private var selectedTab = 0
    @State var selectedDate = Date()
    @State var exerciseType = RequestingExerciseType.allCases.map({$0.rawValue})
    
    var body: some View {
        VStack(spacing:0){
            //TODO: - 날짜 제한하기
            weekDatePickerView(currentDate: $selectedDate)
                .onChange(of: selectedDate) { newValue in
                    viewModel.reloadData(newValue)
                }
                .padding(.horizontal)
                .padding(.bottom)
            
            Tabs(tabs: $exerciseType,
                 selection: $selectedTab,
                 underlineColor: .accentColor) { title, isSelected in
                Text(title)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .black:Color(uiColor: UIColor.lightGray))
            }
            
            VStack{
                if exerciseType[selectedTab] == "Fitness"{
                    
                    if viewModel.coachExerciseList.filter({$0.exerciseType == "Fitness"}).isEmpty{
                        nullTextView()
                    }else{
                        ScrollView(.vertical, showsIndicators: false) {
                            ForEach(viewModel.coachExerciseList.filter({$0.exerciseType == "Fitness"}),id:\.self){ exercise in
                                CoachingFitnessExercise(selectedDate: $selectedDate, exercise: exercise)
                                    .environmentObject(self.viewModel)
                                    .padding(.horizontal)
                                    .padding(.vertical,5)
                            }
                        }
                    }
                } else if exerciseType[selectedTab] == "유산소"{
                    if viewModel.coachExerciseList.filter({$0.exerciseType == "Aerobic"}).isEmpty{
                        nullTextView()
                    }else{
                        ScrollView(.vertical, showsIndicators: false) {
                            ForEach(viewModel.coachExerciseList.filter({$0.exerciseType == "Aerobic"}),id:\.self) { exercise in
                                CoachingAerobicCellView(selectedDate: $selectedDate, exercise: exercise)
                                    .environmentObject(self.viewModel)
                                    .padding(.horizontal)
                                    .padding(.vertical,5)
                            }
                        }
                    }
                } else{
                    if viewModel.coachExerciseList.filter({$0.exercisePart == compareType[selectedTab]}).isEmpty{
                        nullTextView()
                    }else{
                        ScrollView(.vertical, showsIndicators: false) {
                            ForEach(viewModel.coachExerciseList.filter({$0.exercisePart == compareType[selectedTab]}),id:\.self){ exercise in
                                CoachingAnAerobicCellView(selectedDate: $selectedDate, exercise: exercise)
                                    .environmentObject(self.viewModel)
                                    .padding(.horizontal)
                                    .padding(.vertical,5)
                            }
                        }
                    }
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

struct CoachingFitnessExercise:View{
    @EnvironmentObject var viewModel:CoachViewModel
    @Binding var selectedDate:Date
    @State var exercise:coachExercise
    var body: some View{
        if exercise.exercisePart == "AnAerobic"{
            CoachingAnAerobicCellView(selectedDate: $selectedDate, exercise: exercise)
                .environmentObject(self.viewModel)
        }else if exercise.exercisePart == "Aerobic"{
            CoachingAerobicCellView(selectedDate: $selectedDate, exercise: exercise)
                .environmentObject(self.viewModel)
        }
    }
}

struct CoachingAerobicCellView:View{
    @EnvironmentObject var viewModel:CoachViewModel
    @Binding var selectedDate:Date
    @State var exercise:coachExercise
    var body: some View{
        HStack(spacing:10){
            URLImageView(urlString: exercise.imageUrl, imageSize: 50, youtube: false)
            
            VStack(alignment: .leading, spacing: 5){
                Text(exercise.exerciseName)
                    .font(.body)
                
                Text("추천 \(exercise.minute ?? 0) 분")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Text("예상 칼로리")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 15))
            }
            
            Spacer()
            
            Button {
                viewModel.ToggleDone(exercise, selectedDate: selectedDate)
                guard let index = viewModel.coachExerciseList.firstIndex(where: {$0.exerciseName == self.exercise.exerciseName}) else{return}
                self.viewModel.coachExerciseList[index].isDone.toggle()
            } label: {
                Image(systemName: exercise.isDone ? "checkmark.circle":"circle")
            }
            .disabled(
                convertString(content: selectedDate, dateFormat: "yyyy-MM-dd") != convertString(content: Date(), dateFormat: "yyyy-MM-dd")
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
    @Binding var selectedDate:Date
    @State var exercise:coachExercise
    var body: some View{
        HStack(spacing:10){
            URLImageView(urlString: exercise.imageUrl, imageSize: 50, youtube: false)
            
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
                    
                    Text("\(exercise.sets ?? 0)세트")
                }
                .foregroundColor(.gray)
                .font(.footnote)
                
                Text("예상 칼로리")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 15))
            }
            
            Spacer()
            
            Button {
                viewModel.ToggleDone(exercise, selectedDate: selectedDate)
                guard let index = viewModel.coachExerciseList.firstIndex(where: {$0.exerciseName == self.exercise.exerciseName}) else{return}
                self.viewModel.coachExerciseList[index].isDone.toggle()
                
            } label: {
                Image(systemName: exercise.isDone ? "checkmark.circle":"circle")
            }
            .disabled(
                convertString(content: selectedDate, dateFormat: "yyyy-MM-dd") != convertString(content: Date(), dateFormat: "yyyy-MM-dd")
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
