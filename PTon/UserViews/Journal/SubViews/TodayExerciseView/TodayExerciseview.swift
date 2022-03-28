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
    @State var isShowAerobicEditView:Bool = false
    @State var isShowAnAerobicEditView:Bool = false
    @State var selectedIndex:Int = 0
    let exercise:userExercise = Bundle.main.decode("Exercises.json")
    
    //MARK: - FUNCTIONS
    private func gettingPart(_ index:Int)->Int{
        let exercise = viewModel.todayExercises[index]
        var index:Int = 0
        if exercise.part == "Chest"{
            index = 0
        }else if exercise.part == "Shoulder"{
            index = 1
        }else if exercise.part == "Back"{
            index = 2
        }else if exercise.part == "Leg"{
            index = 3
        }else if exercise.part == "Arm"{
            index = 4
        }else if exercise.part == "Abs"{
            index = 5
        }
        
        return index
    }
    
    func selectedExercises(index:Int)->Int{
        var exercises:[String] = []
        let exercise = viewModel.todayExercises[index]
        
        
        if gettingPart(index) == 0{
            exercises = self.exercise.anAerobic.chest
        } else if gettingPart(index) == 1{
            exercises = self.exercise.anAerobic.shoulder
        } else if gettingPart(index) == 2{
            exercises = self.exercise.anAerobic.back
        } else if gettingPart(index) == 3{
            exercises = self.exercise.anAerobic.leg
        } else if gettingPart(index) == 4{
            exercises = self.exercise.anAerobic.arm
        } else if gettingPart(index) == 5{
            exercises = self.exercise.anAerobic.abs
        }
        
        guard let firstIndex = exercises.firstIndex(where: {$0 == exercise.exerciseName}) else{return 0}
        
        return firstIndex
    }
    
    func selectedAerobicExercise(index:Int)->Int{
        var exercises = self.exercise.aerobic
        let exercise = viewModel.todayExercises[index]
        guard let firstIndex = exercises.firstIndex(where: {$0 == exercise.exerciseName}) else{return 0}
        return firstIndex
    }
    
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
                if viewModel.todayExercises.isEmpty{
                    Spacer()
                    
                    Text("아직 등록된 운동이 없습니다.")
                    Spacer()
                }else{
                    ForEach(viewModel.todayExercises.indices,id:\.self) { index in
                        
                        let currentExercisePart = viewModel.todayExercises[index].hydro
                        
                        if currentExercisePart == "Aerobic"{
                            todayExerciseAerobicCellView(selectedDate:selectedDate,
                                                         exercise: viewModel.todayExercises[index],
                                                         isshowNavigationView: $isShowAerobicEditView,
                                                         parentIndex: $selectedIndex,
                                                         selfIndex: index
                            )
                            .environmentObject(self.viewModel)
                        }
                        
                        if currentExercisePart == "AnAerobic"{
                            todayExerciseAnAerobicCellView(selectedDate: selectedDate,
                                                           exercise: viewModel.todayExercises[index],
                                                           isshowNavigationView: $isShowAnAerobicEditView,
                                                           parentIndex: $selectedIndex, selfIndex: index)
                            .environmentObject(self.viewModel)
                        }
                        
                    }
                }
                

            }
            .padding(.horizontal)
            .frame(minHeight:200)
            
            Divider()
            
            HStack{
                infoLabel("시간", "clock.badge.checkmark",viewModel.getAllTime())
                infoLabel("횔동량", "person.fill",0)
                infoLabel("1회 수", "person.fill",0)
                infoLabel("세트 수", "person.fill",0)
            }
            .padding(.vertical)
            
            NavigationLink(isActive: $isShowAerobicEditView) {
                LazyView(
                    TodayExerciseModifyView(exercises: exercise.aerobic,
                                            selectedDate: selectedDate,
                                            index: selectedAerobicExercise(index: selectedIndex),
                                            hourText: viewModel.todayExercises[selectedIndex].hour ?? "",
                                            minuteText: viewModel.todayExercises[selectedIndex].minute ?? "",
                                            exercise: viewModel.todayExercises[selectedIndex])
                    .environmentObject(self.viewModel)
                )
                
            } label: {
                EmptyView()
            }
            
            NavigationLink(isActive: $isShowAnAerobicEditView) {
                LazyView(
                    TodayAnAerobicModifyView(selectedDate: selectedDate,
                                             exercise: viewModel.todayExercises[selectedIndex], exercises: exercise.anAerobic,
                                             minuteText: viewModel.todayExercises[selectedIndex].minute ?? "",
                                             weightText: viewModel.todayExercises[selectedIndex].weight ?? "",
                                             setText: viewModel.todayExercises[selectedIndex].sets ?? "",
                                             numText: viewModel.todayExercises[selectedIndex].time ?? "",
                                             selectedPart: gettingPart(selectedIndex),
                                             selectedExercise: selectedExercises(index: selectedIndex)
                                            )
                    .environmentObject(self.viewModel)
                )
            } label: {
                
                EmptyView()
            }
            
            
        }
        .background(.white)
        .cornerRadius(5)
        .shadow(color: .gray.opacity(0.5), radius: 3)
        .onChange(of: selectedDate) { newValue in
            viewModel.fetchData(newValue)
        }
    }
    
    @ViewBuilder
    func infoLabel(_ title:String,_ imageString:String,_ innerData:Int) -> some View{
        VStack{
            Image(systemName: imageString)
                .font(.system(size: 25))
            
            Text(title)
                .padding(.top,5)
            
            Text("\(innerData)")
                .padding(.top,5)
        }
        .frame(width: 80, height: 100, alignment: .center)
    }
}

struct todayExerciseAerobicCellView:View{
    @EnvironmentObject var viewModel:TodayExerciseViewModel
    let selectedDate:Date
    let exercise:todayExercise
    @State var isShowDeleteButton:Bool = false
    @Binding var isshowNavigationView:Bool
    @Binding var parentIndex:Int
    let selfIndex:Int
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
            
            
            if isShowDeleteButton{
                Button {
                    
                    withAnimation {
                        guard let firstIndex = viewModel.todayExercises.firstIndex(where: {$0.uuid == exercise.uuid}) else{return}
                        
                        viewModel.todayExercises.remove(at: firstIndex)
                        
                        viewModel.removeData(selectedDate, uuid: exercise.uuid)
                        
                        self.isShowDeleteButton = false
                    }
                    
                    
                } label: {
                    Image(systemName: "trash.fill")
                }
                
            }
            
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(10)
        .onTapGesture {
            withAnimation {
                parentIndex = selfIndex
                isshowNavigationView = true
            }
        }
        .onLongPressGesture {
            
            withAnimation(.spring()) {
                isShowDeleteButton = true
                
            }
        }
        
    }
}

struct todayExerciseAnAerobicCellView:View{
    @EnvironmentObject var viewModel:TodayExerciseViewModel
    let selectedDate:Date
    let exercise:todayExercise
    @State var isShowDeleteButton:Bool = false
    @Binding var isshowNavigationView:Bool
    @Binding var parentIndex:Int
    let selfIndex:Int
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
            if isShowDeleteButton{
                Button {
                    
                    withAnimation {
                        guard let firstIndex = viewModel.todayExercises.firstIndex(where: {$0.uuid == exercise.uuid}) else{return}
                        
                        viewModel.todayExercises.remove(at: firstIndex)
                        
                        viewModel.removeData(selectedDate, uuid: exercise.uuid)
                        
                        self.isShowDeleteButton = false
                    }
                    
                    
                } label: {
                    Image(systemName: "trash.fill")
                }
                
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(10)
        .onTapGesture {
            withAnimation {
                parentIndex = selfIndex
                isshowNavigationView = true
            }
        }
        .onLongPressGesture {
            isShowDeleteButton = true
        }
    }
}

struct TodayExerciseView_Previews:PreviewProvider{
    static var previews: some View{
        //        TodayExerciseView(selectedDate: .constant(Date()), viewModel: TodayExerciseViewModel(userId: "kakao:1967260938"))
        //            .previewLayout(.sizeThatFits)
        //            .padding()
        //            .background(backgroundColor)
        todayExerciseAnAerobicCellView(selectedDate: Date(), exercise: todayExercise(uuid: "example", exerciseName: "Eaxmple Exercise", hydro: "AnAerobic", time: "3", part: "Back", sets: "20", weight: "10"), isshowNavigationView: .constant(false),parentIndex: .constant(-1),selfIndex: 1)
            .previewLayout(.sizeThatFits)
            .padding()
        todayExerciseAerobicCellView(selectedDate: Date(), exercise: todayExercise(uuid: "example", exerciseName: "Example Exercise ", hydro: "Aerobic", hour: "1", minute: "30", time: "90"), isshowNavigationView: .constant(false),parentIndex: .constant(-1),selfIndex: 1)
            .previewLayout(.sizeThatFits)
            .padding()
        
    }
}
