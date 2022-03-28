//
//  TodayExerciseModifyView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/28.
//

import Foundation
import SwiftUI
import AlertToast
import ToastUI

struct TodayExerciseModifyView:View{
    @EnvironmentObject var viewModel:TodayExerciseViewModel
    let exercises:[String]
    let selectedDate:Date
    @State var index:Int
    @State var hourText:String
    @State var minuteText:String
    @State var exercise:todayExercise
    @State var errorMessage:String = ""
    @State var isShowErrorView:Bool = false
    @State var isShowSuccessView:Bool = false
    var body: some View{
        VStack{
            
            VStack{
                
                Divider()
                
                HStack{
                    Text("운동 종류")
                    
                    Spacer()
                    
                    Picker("", selection: $index) {
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
                        "Exercise":exercises[index],
                        "Hour":hour,
                        "Minute":minute,
                        "Time":viewModel.convertTime(hour, minute),
                        "Hydro":"Aerobic"
                    ]
                    
                    viewModel.updateData(selectedDate, data: data, uuid: exercise.uuid)
                    self.isShowSuccessView = true
                }
                
            } label: {
                HStack{
                    Spacer()
                    
                    Text("수정하기")
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
            AlertToast(displayMode: .banner(.pop), type: .complete(.accentColor),title: "수정 완료",style: .style(titleColor: .accentColor))
        }
        .navigationTitle("유산소 운동 수정")
        .onDisappear {
            viewModel.fetchData(selectedDate)
        }
    }
}

struct TodayAnAerobicModifyView:View{
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel:TodayExerciseViewModel
    let selectedDate:Date
    @State var exercise:todayExercise
    let exercises:AnAerobic
    @State var minuteText:String = ""
    @State var weightText:String = ""
    @State var setText:String = ""
    @State var numText:String = ""
    @State var alertText:String = ""
    @State var isShowToastView:Bool = false
    @State var successToastView:Bool = false
    
    @State var selectedPart:Int = 0
    @State var selectedExercise:Int = 0
    let exerciseParts:[String] = ["가슴","어깨","등","하체","팔","복근"]
    
    
    //MARK: - FUNCTIONS
    func selectedExercises()->[String]{
        var exercises:[String] = []
        if selectedPart == 0{
            exercises = self.exercises.chest
        } else if selectedPart == 1{
            exercises = self.exercises.shoulder
        } else if selectedPart == 2{
            exercises = self.exercises.back
        } else if selectedPart == 3{
            exercises = self.exercises.leg
        } else if selectedPart == 4{
            exercises = self.exercises.arm
        } else if selectedPart == 5{
            exercises = self.exercises.abs
        }
        
        return exercises
    }
    
    private func isEmpty(_ data:String)->Bool{
        return data.isEmpty
    }
    
    //MARK: - VIEWS
    var body: some View{
        VStack(alignment: .leading){
            
            VStack{
                
                Group{
                    Divider()
                    
                    HStack{
                        Text("운동 부위")
                        
                        Spacer()
                        
                        Picker("", selection: $selectedPart) {
                            ForEach(0..<AnAerobic.CodingKeys.allCases.count,id:\.self) { index in
                                Text(exerciseParts[index])
                            }
                        }

                    }
                    .frame(height:50)
                    .padding(.horizontal)
                }

                Group{
                    Divider()
                    
                    HStack{
                        Text("운동 종류")
                        
                        Spacer()
                        
                        if selectedPart == 0{
                            Picker("", selection: $selectedExercise) {
                                ForEach(0..<exercises.chest.count,id:\.self){ index in
                                    Text(exercises.chest[index])
                                }
                            }
                        }
                        
                        if selectedPart == 1{
                            Picker("", selection: $selectedExercise) {
                                ForEach(0..<exercises.shoulder.count,id:\.self){ index in
                                    Text(exercises.shoulder[index])
                                }
                            }
                        }
                        if selectedPart == 2{
                            Picker("", selection: $selectedExercise) {
                                ForEach(0..<exercises.back.count,id:\.self){ index in
                                    Text(exercises.back[index])
                                }
                            }
                        }
                        
                        if selectedPart == 3{
                            Picker("", selection: $selectedExercise) {
                                ForEach(0..<exercises.leg.count,id:\.self){ index in
                                    Text(exercises.leg[index])
                                }
                            }
                        }
                        if selectedPart == 4{
                            Picker("", selection: $selectedExercise) {
                                ForEach(0..<exercises.arm.count,id:\.self){ index in
                                    Text(exercises.arm[index])
                                }
                            }
                        }
                        
                        if selectedPart == 5{
                            Picker("", selection: $selectedExercise) {
                                ForEach(0..<exercises.abs.count,id:\.self){ index in
                                    Text(exercises.abs[index])
                                }
                            }
                        }
                        

                    }
                    .padding(.horizontal)
                    .frame(height:50)
                }

                
                Group{
                    Divider()
                    
                    HStack{
                        Text("운동 시간")
                        Spacer()
                        
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
                }

                Group{
                    Divider()
                    
                    HStack{
                        Text("운동 무게")
                        Spacer()
                        
                        VStack(alignment: .center,spacing:0){
                            TextField("", text: $weightText)
                                .frame(width: 40, alignment: .center)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.accentColor)
                            
                            Text("Kg")
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
                }

                Group{
                    Divider()
                    
                    HStack{
                        Text("세트/횟수")
                        Spacer()
                        
                        VStack(alignment: .center,spacing:0){
                            TextField("", text: $setText)
                                .frame(width: 40, alignment: .center)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.accentColor)
                            
                            Text("Set")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding(5)
                        .background(
                            Circle()
                                .foregroundColor(Color("Background"))
                        )
                        
                        VStack(alignment: .center,spacing:0){
                            TextField("", text: $numText)
                                .frame(width: 40, alignment: .center)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.accentColor)
                            
                            Text("Num")
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
                }
                
                
                Divider()
                
            }//:VSTACK
            .background(.white)
            .cornerRadius(5)
            .shadow(color: .gray.opacity(0.5), radius: 3)
            .padding(.top)
            
            
            Spacer()
            
            Button {
                let exercisePart = AnAerobic.CodingKeys.allCases[selectedPart].stringValue
                let exercise = selectedExercises()[selectedExercise]
                
                if isEmpty(minuteText){
                    alertText = "시간을 입력해주세요."
                    isShowToastView = true
                }else if isEmpty(weightText){
                    alertText = "무게를 입력해주세요."
                    isShowToastView = true
                }else if isEmpty(setText){
                    alertText = "세트수를 입력해주세요."
                    isShowToastView = true
                }else if isEmpty(numText){
                    alertText = "횟수를 입력해주세요."
                    isShowToastView = true
                }else{
                    UIApplication.shared.endEditing()
                    let data:[String:Any] = [
                        "Exercise":exercise,
                        "Part":exercisePart,
                        "Hydro":"AnAerobic",
                        "Sets":setText,
                        "Time":numText,
                        "Weight":weightText,
                        "Minute":minuteText
                    ]
                    
                    viewModel.updateData(selectedDate, data: data, uuid: self.exercise.uuid)
                    successToastView = true
                }
            } label: {
                HStack{
                    Spacer()
                    
                    Text("수정하기")
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
        .navigationTitle("무산소 운동 수정")
        .padding(.horizontal)
        .onDisappear(perform: {
            viewModel.fetchData(selectedDate)
        })
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
        .toast(isPresented: $isShowToastView) {
            ToastView {
                VStack{
                    Text(alertText)
                        .padding(.bottom)
                    
                    Button {
                        isShowToastView = false
                    } label: {
                        Text("확인")
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal,12)
                            .padding(.vertical, 5)
                            .background(Color.accentColor)
                            .cornerRadius(8.0)
                    }

                }
            }
        }
        .toast(isPresenting: $successToastView) {
            AlertToast(displayMode: .banner(.pop), type: .complete(.accentColor),title: "수정 완료",style: .style(titleColor: .accentColor))
        }
    }
}
