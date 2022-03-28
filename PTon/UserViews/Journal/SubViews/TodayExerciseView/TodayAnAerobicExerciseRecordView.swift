//
//  UserAnAerobicExerciseView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/26.
//

import Foundation
import SwiftUI
import ToastUI
import AlertToast


struct TodayAnAerobicExerciseRecordView:View{
    //MARK: - PROPERTIES
    @EnvironmentObject var viewModel:TodayExerciseViewModel
    let selectedDate:Date
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
    
    private func selectedExercises()->[String]{
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
                        Picker("", selection: $selectedExercise) {
                            ForEach(0..<selectedExercises().count,id:\.self){ index in
                                Text(selectedExercises()[index])
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
                    
                    viewModel.uploadData(selectedDate, data: data)
                    successToastView = true
                }
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
            .padding(.bottom)
        }//:VSTACK
        .padding(.horizontal)
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
            AlertToast(displayMode: .banner(.pop), type: .complete(.accentColor),title: "저장 완료",style: .style(titleColor: .accentColor))
        }
    }
}

//MARK: - PREVIEWS
struct TodayAnAerobicExerciseRecordView_previews:PreviewProvider{
    static let exercises:userExercise = Bundle.main.decode("Exercises.json")
    static var previews: some View{
        TodayAnAerobicExerciseRecordView(selectedDate: Date(), exercises: exercises.anAerobic)
    }
}