//
//  UserAerobicExerciseView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/26.
//

import Foundation
import SwiftUI
import AlertToast

struct TodayAerobicExeciseRecordView:View{
    //MARK: - PROPERTIES
    @EnvironmentObject var viewModel:TodayExerciseViewModel
    let selectedDate:Date
    let exercises:[String]
    @State var hourText:String = ""
    @State var minuteText:String = ""
    @State var selectedIndex = 0
    @State var errorMessage:String = ""
    @State var isShowErrorView:Bool = false
    @State var isShowSuccessView:Bool = false
    
    //MARK: - VIEWS
    //TODO: - ontap Gesture 추가하기(end Editing)
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
                
                UIApplication.shared.endEditing()
                
                if hour == "0" && minute == "0"{
                    errorMessage = "시간과 분중 적어도 하나 입력해주세요."
                    isShowErrorView = true
                }else{
                    let data:[String:Any] = [
                        "Exercise":exercises[selectedIndex],
                        "Hour":hour,
                        "Minute":minute,
                        "Time":viewModel.convertTime(hour, minute),
                        "Hydro":"Aerobic"
                    ]
                    
                    viewModel.uploadData(selectedDate, "0", "0", "0", "0", data: data) { isSuccess in
                        self.isShowSuccessView = true
                    }
                }
                
            } label: {
                HStack{
                    Spacer()
                    
                    Text("저장하기")
                        .foregroundColor(.white)
                    
                    Spacer()

                }
            }
            .buttonStyle(.plain)
            .padding(10)
            .background(Color.accentColor)
            .cornerRadius(10)
            .padding(.bottom)
            
        }//:VSTACK
        .padding(.horizontal)
        .toast(isPresenting: $isShowErrorView) {
            AlertToast(displayMode: .banner(.pop), type: .error(.red),title: errorMessage)
        }
        .toast(isPresenting: $isShowSuccessView) {
            AlertToast(displayMode: .banner(.pop), type: .complete(.accentColor),title: "저장 완료",style: .style(titleColor: .accentColor))
        }
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
