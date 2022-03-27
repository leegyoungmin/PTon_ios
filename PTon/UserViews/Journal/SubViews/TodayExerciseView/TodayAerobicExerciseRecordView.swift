//
//  UserAerobicExerciseView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/26.
//

import Foundation
import SwiftUI

struct TodayAerobicExeciseRecordView:View{
    //MARK: - PROPERTIES
    @EnvironmentObject var viewModel:TodayExerciseViewModel
    let selectedDate:Date
    let exercises:[String]
    @State var hourText:String = ""
    @State var minuteText:String = ""
    @State var selectedIndex = 0
    
    //MARK: - VIEWS
    var body: some View{
        VStack{
            
            VStack{
                
                Divider()
                
                HStack{
                    Text("운동 종류")
                    
                    Spacer()
                    
                    Picker("", selection: $selectedIndex) {
                        ForEach(0..<exercises.count,id:\.self) { index in
                            Text(exercises[index])
                        }
                    }
                    
                    Image(systemName: "chevron.down")
                    
                }
                .frame(height:50)
                .padding(.horizontal)
                

                Divider()
                
                HStack{
                    Text("시간/분")
                    
                    Spacer()
                    
                    VStack(alignment: .center,spacing:0){
                        TextField("", text: $hourText)
                            .frame(width: 40, alignment: .center)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.accentColor)
                        
                        Text("Hour")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(5)
                    .background(
                        Circle()
                            .foregroundColor(Color("Background"))
                    )
                    
                    VStack(alignment: .center,spacing:0){
                        TextField("", text: $minuteText)
                            .frame(width: 40, alignment: .center)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.accentColor)
                        
                        Text("Min")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(5)
                    .background(
                        Circle()
                            .foregroundColor(Color("Background"))
                    )
                }
                .padding(.horizontal)
                
                Divider()
                
            }//:VSTACK
            .background(.white)
            .cornerRadius(5)
            .shadow(color: .gray.opacity(0.5), radius: 3)
            .padding(.top)
            
            Spacer()
            
            Button {
                let hour = hourText.isEmpty ? "0":hourText
                let minute = minuteText.isEmpty ? "0":minuteText
                
                let data:[String:Any] = [
                    "Exercise":exercises[selectedIndex],
                    "Hour":hour,
                    "Minute":minute,
                    "Time":viewModel.convertTime(hour, minute),
                    "Hydro":"Aerobic"
                ]
                
                viewModel.uploadData(selectedDate, data: data)
            } label: {
                HStack{
                    Spacer()
                    
                    Text("추가하기")
                        .foregroundColor(.white)
                    
                    Spacer()

                }
            }
            .buttonStyle(.plain)
            .padding(10)
            .background(Color.accentColor)
            .cornerRadius(10)
            
        }//:VSTACK
        .padding(.horizontal)
    }
}

//MARK: - PREVIEWS
struct TodayAerobicExerciseRecordView_previews:PreviewProvider{
    static let exerecises:userExercise = Bundle.main.decode("Exercises.json")
    static var previews: some View{
        TodayAerobicExeciseRecordView(selectedDate: Date(), exercises: exerecises.aerobic)
    }
}

extension TodayExerciseViewModel{
    func convertTime(_ hour:String,_ minute:String)->Int{
        return ((Int(hour) ?? 0) * 60) + (Int(minute) ?? 0)
    }
}
