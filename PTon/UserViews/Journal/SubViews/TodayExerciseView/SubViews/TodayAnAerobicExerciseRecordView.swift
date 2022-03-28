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
                
                //MINUTE
                makeElementView("운동 시간", $minuteText, "Min")
                
                //WEIGHT
                makeElementView("운동 무게", $weightText, "Kg")

                //SET & NUMBER
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
                
                viewModel.uploadData(selectedDate, minuteText, setText, numText, weightText, data: data) { isSuccess in
                    if isSuccess{
                        successToastView = true
                    }else{
                        isShowToastView =  true
                    }
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
        .toast(isPresenting: $isShowToastView, alert: {
            AlertToast(displayMode: .banner(.pop), type: .error(.red),title: viewModel.errorDescription)
        })
        .toast(isPresenting: $successToastView) {
            AlertToast(displayMode: .banner(.pop), type: .complete(.accentColor),title: "저장 완료",style: .style(titleColor: .accentColor))
        }
    }
    @ViewBuilder
    func makeElementView(_ title:String,_ dataString:Binding<String>,_ unit:String) -> some View{
        Group{
            Divider()
            
            HStack{
                Text(title)
                Spacer()
                
                VStack(alignment: .center,spacing:0){
                    TextField("", text: dataString)
                        .frame(width: 40, alignment: .center)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.accentColor)
                    
                    Text(unit)
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
    }
}

//MARK: - PREVIEWS
struct TodayAnAerobicExerciseRecordView_previews:PreviewProvider{
    static let exercises:userExercise = Bundle.main.decode("Exercises.json")
    static var previews: some View{
        TodayAnAerobicExerciseRecordView(selectedDate: Date(), exercises: exercises.anAerobic)
    }
}
