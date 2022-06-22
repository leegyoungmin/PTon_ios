//
//  RequestingExerciseView.swift
//  Salud0.2
//
//  Created by 이관형 on 2021/12/08.
//

import Foundation
import SwiftUI
import Kingfisher

enum RequestingExerciseType:String,CaseIterable{
    case Fitness = "Fitness",Aerobic = "유산소",Back = "등",Chest = "가슴",Arm = "팔",Leg = "하체",Shoulder = "어깨", Abs = "복근"
}

struct RequestingExerciseView:View{
    @StateObject var viewmodel:RequestingExerciseViewModel
    @State var selection:Int = 0
    let exercisePartList = exercisePart.allCases
    var body: some View{
        VStack(spacing:0){
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [.init()], alignment: .center) {
                    ForEach(exercisePartList.indices,id:\.self){ index in
                        Button {
                            withAnimation {
                                selection = index
                            }
                        } label: {
                            Text(exercisePartList[index].description)
                                .font(.title3.bold())
                                .foregroundColor(selection == index ? Color.accentColor:.black)
                                .padding(.horizontal,10)
                        }
                    }
                }
            }
            .background(Color.white)
            .frame(height:40)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height:1.5)
                    .padding(.top,10)
                    .padding(.horizontal,-5)
                ,alignment: .bottom
            )
            if viewmodel.trainerSavedExercises.filter({$0.exercisePart == exercisePartList[selection]}).isEmpty{
                Spacer()
                Text("아직 저장된 운동이 없습니다.")
                Spacer()
            }else{
                List{
                    ForEach(viewmodel.trainerSavedExercises.filter({$0.exercisePart == exercisePartList[selection]}),id:\.self){ exercise in
                        if exercise.exerciseHydro == .compound{
                            RequestingExerciseAerobicCellView(exercise: exercise)
                                .listRowBackground(backgroundColor)
                            
                        }else if exercise.exerciseHydro == .AnAerobic{
                            RequestingExerciseAnAerobicCellView(exercise: exercise)
                                .listRowBackground(backgroundColor)
                            
                        }else{
                            if exercise.exercisePart != nil{
                                RequestingExerciseAnAerobicCellView(exercise: exercise)
                                    .listRowBackground(backgroundColor)
                                
                            }else{
                                RequestingExerciseAerobicCellView(exercise: exercise)
                                    .listRowBackground(backgroundColor)
                                
                            }
                        }
                    }
                }
                .environmentObject(self.viewmodel)
                .listStyle(.plain)
                .listRowSeparator(.hidden)
                .background(backgroundColor)
                
            }
            
            Button {
                DispatchQueue.main.async {
                    viewmodel.updateDataBase()
                    
                }
            } label: {
                HStack{
                    Spacer()
                    Text("요청하기")
                        .foregroundColor(.white)
                        .font(.title2.bold())
                        .padding(.vertical,10)
                    
                    Spacer()
                }

            }
            .background(Color.accentColor)
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.vertical,3)
        }
        .background(backgroundColor)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

struct RequestingExerciseAnAerobicCellView:View{
    @EnvironmentObject var viewModel:RequestingExerciseViewModel
    @State var inputWeight:String = ""
    @State var inputTime:String = ""
    @State var inputSet:String = ""
    @State var didSelected:Bool = false
    let exercise:TrainerSaveExercise
    
    private func isNotAllWriteData()->Bool{
        return inputWeight.isEmpty || inputTime.isEmpty || inputSet.isEmpty
    }
    
    var body: some View{
        HStack{
            
            KFImage(URL(string: exercise.url))
                .onFailureImage(KFCrossPlatformImage(named: "defaultImage"))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50, alignment: .center)
                .cornerRadius(35)
                .padding(5)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("운동 강도 자리")
                    .font(.footnote)
                    .fontWeight(.light)
                
                Text(exercise.exerciseName)
                    .fontWeight(.semibold)
                HStack{
                    VStack(spacing:0){
                        TextField("", text: $inputWeight)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.plain)
                            .background(backgroundColor)
                            .multilineTextAlignment(.center)
                            .font(.callout)
                        
                        Text("kg")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .frame(width: 40, height: 40, alignment: .center)
                    .padding(5)
                    .background(backgroundColor)
                    .cornerRadius(50)
                    
                    VStack(spacing:0){
                        TextField("", text: $inputTime)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.plain)
                            .background(backgroundColor)
                            .multilineTextAlignment(.center)
                            .font(.callout)
                        
                        Text("Time")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .frame(width: 40, height: 40, alignment: .center)
                    .padding(5)
                    .background(backgroundColor)
                    .cornerRadius(50)
                    
                    VStack(spacing:0){
                        TextField("", text: $inputSet)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.plain)
                            .background(backgroundColor)
                            .multilineTextAlignment(.center)
                            .font(.callout)
                        
                        Text("set")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .frame(width: 40, height: 40, alignment: .center)
                    .padding(5)
                    .background(backgroundColor)
                    .cornerRadius(50)
                }
                
            }
            .padding(.vertical)
            
            Spacer()
            
            Toggle(isOn: $didSelected) {
                Text("")
            }
            .toggleStyle(CheckboxStyle())
            .onChange(of: didSelected) { newValue in
                if isNotAllWriteData(){
                    
                }else{
                    print("did selected Change \(newValue)")
                    let data = RequestingExercise(exerciseName: exercise.exerciseName, exerciseHydro: "AnAerobic",
                                                  minute: viewModel.minuteEditor(time: Int(inputTime) ?? 0, sets: Int(inputSet) ?? 0),
                                                  paramter: exercise.paramter, part: exercise.exercisePart?.rawValue ?? "", set: Int(inputSet), time: Int(inputTime), url: exercise.url, weight: Int(inputWeight), done: false)
                    
                    viewModel.selectedExerciseList.append(data)
                }
            }
            .disabled(isNotAllWriteData())
        }
        .padding(.horizontal)
        .background(.white)
        .cornerRadius(1)
        .shadow(color: .gray.opacity(0.3), radius: 1, x: 0, y: 0)
    }
}

struct RequestingExerciseAerobicCellView:View{
    @EnvironmentObject var viewModel:RequestingExerciseViewModel
    @State var inputMinute:String = ""
    @State var didSelected:Bool = false
    let exercise:TrainerSaveExercise
    
    var body: some View{
        HStack(alignment: .center) {
            KFImage(URL(string: exercise.url))
                .onFailureImage(KFCrossPlatformImage(named: "defaultImage"))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50, alignment: .center)
                .cornerRadius(35)
                .padding(5)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("운동 강도자리")
                    .font(.footnote)
                    .fontWeight(.light)
                
                Text(exercise.exerciseName)
                    .fontWeight(.semibold)
                
                VStack(spacing:0){
                    TextField("", text: $inputMinute)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.plain)
                        .background(backgroundColor)
                        .multilineTextAlignment(.center)
                        .font(.callout)
                    
                    Text("분")
                        .foregroundColor(.gray.opacity(0.5))
                }
                .frame(width: 40, height: 40, alignment: .center)
                .padding(5)
                .background(backgroundColor)
                .cornerRadius(50)
            }
            .padding(.vertical)
            
            Spacer()
            
            Toggle(isOn: $didSelected) {
                Text("")
            }
            .toggleStyle(CheckboxStyle())
            .onChange(of: didSelected) { newValue in
                if inputMinute.isEmpty == false{
                    let data = RequestingExercise(exerciseName: exercise.exerciseName, exerciseHydro: "Aerobic", minute: Int(inputMinute) ?? 0, paramter: exercise.paramter, part: exercise.exercisePart?.rawValue ?? "", url: exercise.url, done: false)
                    
                    viewModel.selectedExerciseList.append(data)
                }
            }
            .disabled(inputMinute.isEmpty)
        }
        .padding(.horizontal)
        .background(.white)
        .cornerRadius(1)
        .shadow(color: .gray.opacity(0.3), radius: 1, x: 0, y: 0)
    }
}

struct RequestingExerciseView_Previews:PreviewProvider{
    static var viewModel = RequestingExerciseViewModel("", "", selecteDate: "")
    static var previews: some View{
//                        RequestingExerciseView(viewmodel: RequestingExerciseViewModel("kakao:1967260938", "000001", selecteDate: "asjndjkasd"))
        RequestingExerciseAnAerobicCellView(exercise: TrainerSaveExercise(exerciseName: "asd", paramter: 3.0, url: "", exerciseHydro: .compound, exercisePart: .Aerobic))
            .previewLayout(.sizeThatFits)
            .environmentObject(self.viewModel)
    }
}
