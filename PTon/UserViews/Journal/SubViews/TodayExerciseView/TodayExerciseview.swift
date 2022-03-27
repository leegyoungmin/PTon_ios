//
//  TodayExerciseview.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import SwiftUI

struct TodayExerciseView:View{
    @Binding var selectedDate:Date
    @StateObject var viewModel:TodayExerciseViewModel
    var body: some View{
        VStack{
            HStack{
                Text("오늘의 운동")
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink {
                    TodayExerciseRecordView(selectedDate: selectedDate)
                        .environmentObject(self.viewModel)
                } label: {
                    Label {
                        Image(systemName: "plus.circle.fill")
                    } icon: {
                        Text("운동 등록하기")
                    }
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                
            }//:HSTACK
            .padding()
            
            VStack{
                ForEach(viewModel.todayExercises,id:\.self) { exercise in
                    
                    if exercise.hydro == "Aerobic"{
                        todayExerciseAerobicCellView(exercise: exercise)
                    }
                    
                    if exercise.hydro == "AnAerobic"{
                        todayExerciseAnAerobicCellView(exercise: exercise)
                    }
                
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            HStack{
                infoLabel("시간", "clock.badge.checkmark")
                infoLabel("횔동량", "person.fill")
                infoLabel("1회 수", "person.fill")
                infoLabel("세트 수", "person.fill")
            }
            .padding(.vertical)
            
        }
        .background(.white)
        .cornerRadius(5)
        .shadow(color: .gray.opacity(0.5), radius: 3)
    }
    
    @ViewBuilder
    func infoLabel(_ title:String,_ imageString:String) -> some View{
        VStack{
            Image(systemName: imageString)
                .font(.system(size: 25))
            
            Text(title)
                .padding(.top,5)
            
            Text("0")
                .padding(.top,5)
        }
        .frame(width: 80, height: 100, alignment: .center)
    }
}

struct todayExerciseAerobicCellView:View{
    let exercise:todayExercise
    var body: some View{
        HStack{
            VStack(alignment: .leading){
                Text(exercise.exerciseName)
                
                HStack{
                    
                    //MARK: - Kcal 세팅하기
                    
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
        
    }
}

struct todayExerciseAnAerobicCellView:View{
    let exercise:todayExercise
    var body: some View{
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
    }
}

struct TodayExerciseView_Previews:PreviewProvider{
    static var previews: some View{
//        TodayExerciseView(selectedDate: .constant(Date()), viewModel: TodayExerciseViewModel(userId: "kakao:1967260938"))
//            .previewLayout(.sizeThatFits)
//            .padding()
//            .background(backgroundColor)
        todayExerciseAnAerobicCellView(exercise: todayExercise(uuid: "example", exerciseName: "Eaxmple Exercise", hydro: "AnAerobic", time: "3", part: "Back", sets: "20", weight: "10"))
            .previewLayout(.sizeThatFits)
            .padding()
        todayExerciseAerobicCellView(exercise: todayExercise(uuid: "example", exerciseName: "Example Exercise ", hydro: "Aerobic", hour: "1", minute: "30", time: "90"))
            .previewLayout(.sizeThatFits)
            .padding()
            
    }
}
