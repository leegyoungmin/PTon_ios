//
//  JornalView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/23.
//

import SwiftUI

struct JornalView: View {
    @State var selectedDate = Date()
    let dummyExercise = [StorageExerciseModel(exerciseName: "asdnasdnasdnasdnasdn", parameter: 0.3, exerciseEngName: "asdnj", exerciseURL: "asdnjkas", iscontains: true),
                         StorageExerciseModel(exerciseName: "asdnasdnasdnasdnasdnasdn", parameter: 0.3, exerciseEngName: "asdnj", exerciseURL: "asdnjkas", iscontains: true),
                         StorageExerciseModel(exerciseName: "asdnasdnasdnasdnasdn", parameter: 0.3, exerciseEngName: "asdnj", exerciseURL: "asdnjkas", iscontains: true)
    ]
    
    @State var weight:String = ""
    @State var fat:String = ""
    @State var muscle:String = ""
    var body: some View {
        VStack{
            
            DisclosureGroup {
                DatePicker("", selection: $selectedDate,displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .environment(\.locale, Locale(identifier: "ko_KR"))
            } label: {
                Text(convertDateToString(selectedDate))
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            

            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing:20){
                    VStack(spacing:6){
                        TitleView(title: "식단", titleType: "")
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack{
                                ForEach(["아침","점심","간식","저녁"],id: \.self) { title in
                                    MealCellView(title: title)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    VStack(spacing:6){
                        TitleView(title: "운동", titleType: "button")
                        
                        ForEach(self.dummyExercise,id: \.self) { exercise in
                            ExerciseCellView(exercise: exercise)
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing:6){
                        TitleView(title: "PT 기록", titleType: "")
                        
                        ForEach(self.dummyExercise,id:\.self) { exercise in
                            ExerciseCellView(exercise: exercise)
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing:6){
                        TitleView(title: "신체 정보", titleType: "button")
                        
                        TextField("체중", text: $weight)
                            .textFieldStyle(.roundedBorder)
                        TextField("체지방률", text: $fat)
                            .textFieldStyle(.roundedBorder)
                        TextField("근골격근량", text: $muscle)
                            .textFieldStyle(.roundedBorder)
                        
                    }
                    .padding(.horizontal)
                }
                
            }
        }
    }
    
    func convertDateToString(_ date:Date)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 dd일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

struct ExerciseCellView:View{
    let exercise:StorageExerciseModel
    var body: some View{
        HStack{
            Image(systemName: "person.fill")
                .font(.system(size: 30))
            
            VStack(alignment:.leading){
                Text(exercise.exerciseName)
                Text(exercise.exerciseEngName)
            }
            
            Spacer()
        }
    }
}

struct MealCellView:View{
    let title:String
    var body: some View{
        Image(systemName: "person.fill")
            .font(.system(size: 200))
            .background(.purple)
            .cornerRadius(20)
            .overlay(
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .offset(x: -70, y: -70)
            )
    }
}

struct TitleView:View{
    let title:String
    let titleType:String
    var body: some View{
        
        if titleType == "button"{
            HStack{
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                Spacer()
                
                NavigationLink {
                    Text(title)
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.purple)
                        .font(.largeTitle)
                }
                .buttonStyle(.plain)

            }
        }else{
            HStack{
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                Spacer()
            }
        }
        

    }
}
struct JornalView_Previews: PreviewProvider {
    static var previews: some View {
        JornalView()
    }
}
