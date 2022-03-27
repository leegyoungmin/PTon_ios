//
//  UserAnAerobicExerciseView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/26.
//

import Foundation
import SwiftUI


struct TodayAnAerobicExerciseRecordView:View{
    //MARK: - PROPERTIES
    @EnvironmentObject var viewModel:TodayExerciseViewModel
    let selectedDate:Date
    let exercises:AnAerobic
    @State var minuteText:String = ""
    @State var weightText:String = ""
    @State var setText:String = ""
    @State var numText:String = ""
    
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
    
    
    //MARK: - VIEWS
    var body: some View{
        VStack{
            
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
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
        
    }
}

//MARK: - PREVIEWS
struct TodayAnAerobicExerciseRecordView_previews:PreviewProvider{
    static let exercises:userExercise = Bundle.main.decode("Exercises.json")
    static var previews: some View{
        TodayAnAerobicExerciseRecordView(selectedDate: Date(), exercises: exercises.anAerobic)
    }
}
