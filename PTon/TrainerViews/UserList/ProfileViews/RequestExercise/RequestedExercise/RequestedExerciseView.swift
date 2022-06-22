//
//  RequestExerciseView.swift
//  TrainerSwiftui
//
//  Created by 이경민 on 2021/11/24.
//

import SwiftUI
import Foundation
import Kingfisher
import BottomSheet

struct RequestedExerciseView: View {
    @StateObject var viewmodel:RequestedExerciseViewModel
    @State var selectedItem:RequestingExercise?
    let fitnessCode:String
    let exerciseType:[String] = ["Fitness","Aerobic","Back","Chest","Arm","Leg","Shoulder","Abs"]
    var body: some View {
        VStack(alignment:.center){
            weekDatePickerView(selectedDate: $viewmodel.selectedDate)
            
            List{
                ForEach(exercisePart.allCases,id:\.self) { part in
                    Section {
                        
                        if !viewmodel.exercises.filter({$0.part == part.rawValue}).isEmpty{
                            ForEach(viewmodel.exercises.filter({$0.part == part.rawValue}),id:\.self){ exercise in
                                RequestedExerciseCellView(exercise: exercise) {
                                    withAnimation {
                                        selectedItem = exercise
                                    }
                                }
                            }
                            .onDelete(perform: { index in
                                let exercise = viewmodel.exercises.filter({$0.part == part.rawValue})[index.last!]
                                print(exercise)
                                viewmodel.removeData(exercise: exercise)
                            })
                            .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            
                            
                        }else{
                            HStack(alignment:.center){
                                Spacer()
                                Text("아직 추가된 운동이 없습니다.")
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    } header: {
                        listHeaderView(part.description)
                    }
                    .listSectionSeparator(.hidden, edges: .all)
                    .listRowBackground(backgroundColor)
                }
            }
            .listStyle(.plain)
            .listRowBackground(backgroundColor)
            .background(backgroundColor)
            
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("운동 요청")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    RequestingExerciseView(viewmodel: RequestingExerciseViewModel(viewmodel.userid,self.fitnessCode, selecteDate:convertString(content: viewmodel.selectedDate, dateFormat: "yyyy-MM-dd")))
                } label: {
                    Text("생성하기")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                
            }
        }
        .bottomSheet(item: $selectedItem, height: 600, topBarCornerRadius: 15, showTopIndicator: false) { item in
            
            RequestedExerciseEditView(exercise: item,completion: {
                self.selectedItem = nil
            })
            .environmentObject(self.viewmodel)

        }
    
        
    }
    
    @ViewBuilder
    private func listHeaderView(_ title:String)->some View{
        VStack(alignment:.leading){
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray)
                .frame(height:2)
            
        }
    }
}

struct RequestedExerciseEditView:View{
    @EnvironmentObject var viewModel:RequestedExerciseViewModel
    @State var exercise:RequestingExercise
    @State var minuteInput:String = ""
    @State var weightInput:String = ""
    @State var setInput:String = ""
    @State var numberInput:String = ""
    var completion:()->()
    
    var body: some View{
        
        VStack{
            HStack{
                Text(exercise.exerciseName)
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding()

            if exercise.exerciseHydro == "Aerobic"{
                HStack{
                    Text("시간")
                        .font(.title2.bold())
                    
                    Spacer()
                    
                    TextField(String(exercise.minute), text: $minuteInput)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .frame(width:100)
                        .keyboardType(.numberPad)
                    
                    Text("분")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)

            }else{
                Group {
                    HStack{
                        Text("무게")
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        TextField(String(exercise.weight ?? 0), text: $weightInput)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.roundedBorder)
                            .frame(width:100)
                            .keyboardType(.numberPad)
                        
                        Text("kg")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(width:50)

                    }
                    .padding(.horizontal)
                    
                    
                    HStack{
                        Text("개수")
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        TextField(String(exercise.time ?? 0), text: $numberInput)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.roundedBorder)
                            .frame(width:100)
                            .keyboardType(.numberPad)
                        
                        Text("개")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(width:50)

                    }
                    .padding(.horizontal)
                    
                    HStack{
                        Text("세트수")
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        TextField(String(exercise.set ?? 0), text: $setInput)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.roundedBorder)
                            .frame(width:100)
                            .keyboardType(.numberPad)
                        
                        Text("세트")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(width:50)
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
            
            Button {
                
                if exercise.exerciseHydro == "Aerobic"{
                    if !minuteInput.isEmpty,let minuteInt = Int(minuteInput){
                        self.exercise.minute = minuteInt
                    }
                }else{
                    
                    if !weightInput.isEmpty, let weightInt = Int(weightInput){
                        self.exercise.weight = weightInt
                    }
                    
                    if !numberInput.isEmpty, let numberInt = Int(numberInput){
                        self.exercise.time = numberInt
                    }
                    
                    if !setInput.isEmpty, let setInt = Int(setInput){
                        self.exercise.set = setInt
                    }
                    
                }
                viewModel.modifyElementExercise(exercise)
                
                completion()
            } label: {
                Text("수정하기")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .onTapGesture {
            withAnimation {
                UIApplication.shared.endEditing()
            }
        }
    }
}

struct RequestedExerciseCellView:View{
    let exercise:RequestingExercise
    @State var isEditing:Bool = false
    
    @State var minuteInput:String = ""
    @State var weightInput:String = ""
    @State var timeInput:String = ""
    @State var setInput:String = ""
    @State var completion:()->()
    
    @ViewBuilder
    private func exerciseInfoCellView(info:Int,unit:String,input:Binding<String>)->some View{
        VStack{
            Text(String(info))
                .multilineTextAlignment(.center)
                .foregroundColor(Color.accentColor)
                .font(.system(size: 13))
            
            Text(unit)
                .font(.footnote)
        }
        .padding()
        .background(
            Circle()
                .fill(backgroundColor)
                .frame(width: 50, height: 50, alignment: .center)
        )
    }
    
    var body: some View{
        HStack(spacing:10){
            KFImage(URL(string: exercise.url))
                .onFailureImage(KFCrossPlatformImage(named: "defaultImage"))
                .resizable()
                .scaledToFit()
                .frame(width:50,height:50)
                .cornerRadius(30)
                .padding()
            
            VStack(alignment:.leading,spacing:5){
                Text("강도가 들어갈 자리")
                    .font(.footnote)
                    .padding(.top,5)
                
                Text(exercise.exerciseName)
                HStack{
                    if exercise.exerciseHydro == "Aerobic"{
                        exerciseInfoCellView(info: exercise.minute, unit: "분", input: $minuteInput)
                    }else{
                        Group{
                            exerciseInfoCellView(info: exercise.weight ?? 0, unit: "kg", input: $weightInput)
                            exerciseInfoCellView(info: exercise.time ?? 0, unit: "회",input: $timeInput)
                            exerciseInfoCellView(info: exercise.set ?? 0, unit: "세트",input: $setInput)
                        }
                    }
                }
            }
            
            Spacer()
            
            Button {
                completion()
            } label: {
                Text("수정")
            }
            .padding(5)

        }
        .padding(5)
        .background(.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 0)
    }
}


struct RequestExerciseView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group{
            //            RequestedExerciseView(viewmodel: RequestedExerciseViewModel("kakao:1967260938"), fitnessCode: "000001")
            RequestedExerciseCellView(exercise: RequestingExercise(exerciseName: "Dumbbell shoulder Press", exerciseHydro: "AnAerobic", minute: 20, paramter: 3.2, part: exercisePart.Shoulder.rawValue, set: 20, time: 10, url: "", weight: 30, done: false)) {
                print("End Editing")
            }
            
            RequestedExerciseCellView(exercise: RequestingExercise(exerciseName: "Dumbbell shoulder Press", exerciseHydro: "Aerobic", minute: 20, paramter: 3.2, part: exercisePart.Shoulder.rawValue, set: 20, time: 10, url: "", weight: 30, done: false)) {
                print("End Editing")
            }
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .background(backgroundColor)
    }
}
