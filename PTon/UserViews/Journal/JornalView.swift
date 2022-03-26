//
//  JornalView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/23.
//

import SwiftUI

struct JornalView: View {
    @State var selectedDate = Date()
    let trainerId:String
    let userId:String
    var body: some View {
        VStack{
            weekDatePickerView(currentDate: $selectedDate)
                .padding(.horizontal)
                .padding(.bottom,10)
            
            ScrollView(.vertical, showsIndicators: false){
                MealViews(viewModel: MealRecordViewModel(self.trainerId, self.userId), selectedDate: $selectedDate)
                    .padding(.horizontal)
                    .padding(.vertical,20)
                
                TodayExerciseView(selectedDate: $selectedDate, viewModel: TodayExerciseViewModel(userId: self.userId))
                    .padding(.horizontal)
                    .padding(.bottom,20)
                
                GymExerciseViews(selectedDate: $selectedDate)
                    .padding(.horizontal)
                    .padding(.bottom,20)
                
                UserBaseInfoView(selectedDate: $selectedDate)
                    .padding(.horizontal)
                    .padding(.bottom,20)
                
            }
            .background(backgroundColor)
        }
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

struct JornalView_Previews: PreviewProvider {
    static var previews: some View {
        JornalView(trainerId: "3yvE0bnUEHbvDKasU1Orf7DhvjX2", userId: "kakao:1967260938")
    }
}
