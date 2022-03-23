//
//  RequestExerciseView.swift
//  TrainerSwiftui
//
//  Created by 이경민 on 2021/11/24.
//

import SwiftUI
import Foundation


struct RequestedExerciseView: View {
    @StateObject var viewmodel:RequestedExerciseViewModel
    @State var selectedDate = Date()
    let fitnessCode:String
    let exerciseType:[String] = ["Fitness","Aerobic","Back","Chest","Arm","Leg","Shoulder","Abs"]
    var body: some View {
        VStack{
            DatePicker("날짜선택", selection: $selectedDate,displayedComponents: .date)
                .datePickerStyle(.compact)
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .padding(.horizontal)
                .onChange(of: selectedDate) { newValue in
                    print("chagned date \(newValue)")
                    viewmodel.exercises.removeAll(keepingCapacity: true)
                    viewmodel.selectedDate = newValue
                    
                    viewmodel.fetchData(tasks: [
                        viewmodel.fetchFitness,
                        viewmodel.fetchAerobic,
                        viewmodel.fetchAnAerobic
                    ])
                }
            
            List{
                ForEach(exerciseType,id:\.self) { part in
                    RequestedSectionView(title: part, exercises: viewmodel.exercises.filter{$0.part == part})
                        .listRowSeparator(.hidden)
                        .environmentObject(self.viewmodel)
                }
            }
            .listStyle(.plain)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .onAppear {
                UITableViewHeaderFooterView.appearance().backgroundColor = .clear
                UITableView.appearance().sectionIndexBackgroundColor = .clear
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("운동 요청")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    RequestingExerciseView(viewmodel: RequestingExerciseViewModel(viewmodel.userid,self.fitnessCode, selecteDate: viewmodel.convertDate(selectedDate)))
                } label: {
                    Text("생성하기")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                
            }
        }
        .onAppear {
            viewmodel.exercises.removeAll(keepingCapacity: true)
            viewmodel.fetchData(tasks: [
                viewmodel.fetchFitness,
                viewmodel.fetchAerobic,
                viewmodel.fetchAnAerobic
            ])
        }
    }
}
struct RequestedSectionView:View{
    //MARK: - PROPERTIES
    @EnvironmentObject var viewmodel:RequestedExerciseViewModel
    let title:String
    let exercises:[requestedExercise]
    
    private func changeDescription(_ rowString:String) -> String{
        var description:String = ""
        
        if rowString == "Aerobic"{
            description = "유산소"
        }else if rowString == "Back"{
            description = "등"
        }else if rowString == "Chest"{
            description = "가슴"
        }else if rowString == "Abs"{
            description = "복근"
        }else if rowString == "Arm"{
            description = "팔"
        }else if rowString == "Leg"{
            description = "하체"
        }else if rowString == "Shoulder"{
            description = "어깨"
        }else if rowString == "Fitness"{
            description = "센터 운동"
        }
        
        return description
    }
    
    var body: some View{
        if !exercises.isEmpty{
            Section {
                RequestedListHeaderView(title: changeDescription(title))
                
                ForEach(exercises,id:\.self) { exercise in
                    if exercise.type == "Aerobic"{
                        RequestedExerciseAerobicCellView(exercise: exercise)
                            .environmentObject(self.viewmodel)
                    }else{
                        RequestedExerciseAnAerobicCellView(exercise: exercise)
                            .environmentObject(self.viewmodel)
                    }
                }
            }
        }else{
            Section{
                RequestedListHeaderView(title: changeDescription(title))
                HStack{
                    Text("\(changeDescription(title)) 파트에 저장된 운동이 없습니다.")
                }
            }
        }
    }
}

struct RequestedListHeaderView:View{
    let title:String
    var body: some View{
        VStack(alignment: .leading,spacing: 0){
            Text(title)
                .font(.title2)
            
            Rectangle()
                .frame(height: 1, alignment: .center)
        }
        .padding(.bottom,10)
        .background(.clear)
    }
}

struct RequestedExerciseAerobicCellView:View{
    @Environment(\.editMode) var editmode
    @EnvironmentObject var viewmodel:RequestedExerciseViewModel
    @State var isShowEdit:Bool = false
    let exercise:requestedExercise
    @State var minuteText:String = ""
    var body: some View{
        HStack{
            URLImageView(urlString: exercise.url, imageSize: 50, youtube: false)
            
            Text(exercise.name)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
            
            Spacer(minLength: 20)
            
            TextField("", text: $minuteText)
                .textFieldStyle(requestedExerciseTextfield(title: "Min"))
                .disabled(!isShowEdit)
                
            
            if isShowEdit{
                HStack{
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                            viewmodel.deleteData(exercise: exercise)
                            self.isShowEdit = false
                        }

                    Image(systemName: "checkmark.square.fill")
                        .font(.system(size: 20))
                        .onTapGesture {
                            withAnimation {
                                UIApplication.shared.endEditing()
                                viewmodel.setData(exercise: exercise, newvalue: ["Minute":Int(minuteText) ?? 0])
                                self.isShowEdit = false
                            }

                        }
                }
                .foregroundColor(.accentColor)
            }
        }
        .padding(.vertical)
        .padding(.horizontal,10)
        .background(
            Rectangle()
                .strokeBorder(.gray.opacity(0.1))
        )
        .onTapGesture {
            withAnimation {
                isShowEdit = false
            }
        }
        .onLongPressGesture(perform: {
            withAnimation {
                isShowEdit = true
            }

        })
        .onAppear {
            if exercise.minute != nil{
                minuteText = exercise.minute!.description
            }
        }
    }
}

struct RequestedExerciseAnAerobicCellView:View{
    @EnvironmentObject var viewmodel:RequestedExerciseViewModel
    @State var weightText:String = ""
    @State var timeText:String = ""
    @State var setText:String = ""
    @State var isEditMode:Bool = false
    let exercise:requestedExercise
    var body: some View{
        HStack{
            URLImageView(urlString: exercise.url, imageSize: 50, youtube: false)
            
            Text(exercise.name)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
            
            Spacer(minLength: 20)
            
            // 1. Kg
            TextField("", text: $weightText)
                .textFieldStyle(requestedExerciseTextfield(title: "Kg"))
                .disabled(!isEditMode)
            
            //2. Time
            TextField("", text: $timeText)
                .textFieldStyle(requestedExerciseTextfield(title: "Time"))
                .disabled(!isEditMode)
            
            //3. Set
            TextField("", text: $setText)
                .textFieldStyle(requestedExerciseTextfield(title: "Set"))
                .disabled(!isEditMode)
            
            if isEditMode{
                HStack{
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                            viewmodel.deleteData(exercise: exercise)
                            self.isEditMode = false
                        }

                    Image(systemName: "checkmark.square.fill")
                        .font(.system(size: 20))
                        .onTapGesture {
                            withAnimation {
                                UIApplication.shared.endEditing()
                                let data:[String:Any] = [
                                    "Weight":Int(weightText) ?? 0,
                                    "Time":Int(timeText) ?? 0,
                                    "Set":Int(setText) ?? 0,
                                    "Minute":viewmodel.minuteEditor(time: Int(timeText) ?? 0,
                                                                    sets: Int(setText) ?? 0)
                                ]
                                viewmodel.setData(exercise: exercise, newvalue: data)
                                self.isEditMode = false
                            }

                        }
                }
                .foregroundColor(.accentColor)
            }
        }
        .padding(.vertical)
        .padding(.horizontal,10)
        .background(
            Rectangle()
                .strokeBorder(.gray.opacity(0.1))
        )
        .onAppear {
            if exercise.sets != nil{
                self.setText = exercise.sets!.description
            }
            if exercise.weight != nil{
                self.weightText = exercise.weight!.description
            }
            if exercise.time != nil{
                self.timeText = exercise.time!.description
            }
        }
        .onTapGesture {
            withAnimation {
                isEditMode = false
            }
        }
        .onLongPressGesture {
            withAnimation {
                isEditMode = true
            }
        }
    }
}

struct requestedExerciseTextfield:TextFieldStyle{
    let title:String
    func _body(configuration: TextField<_Label>) -> some View {
        VStack(spacing:0){
            configuration
                .frame(width: 40, alignment: .center)
                .multilineTextAlignment(.center)
                .foregroundColor(.accentColor)
            
            Text(title)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(5)
        .background(
            Circle()
                .foregroundColor(Color("Background"))
        )
    }
}

struct RequestExerciseView_Previews: PreviewProvider {
    @State static var tempDate: String = ""
    
    static var previews: some View {
        Group{
            RequestedExerciseAnAerobicCellView(exercise: requestedExercise(name: "InlineChestPress", url: "asdjjaksnd", isDone: false, parameter: 0.1, minute: 123, time: 123, weight: 123, sets: 123, type: "Fitness", part: "Back"))
                .previewLayout(.sizeThatFits)
            RequestedExerciseAerobicCellView(exercise: requestedExercise(name: "InlineChestPress", url: "asdjjaksnd", isDone: false, parameter: 0.1, minute: 123, time: 123, weight: 123, sets: 123, type: "Fitness", part: "Back"))
                .previewLayout(.sizeThatFits)
                .previewInterfaceOrientation(.portraitUpsideDown)
            RequestedExerciseAerobicCellView(exercise: requestedExercise(name: "asd", url: "asdjjaksnd", isDone: false, parameter: 0.1, minute: 123, time: 123, weight: 123, sets: 123, type: "Fitness", part: "Back"))
                .previewLayout(.sizeThatFits)
                .previewInterfaceOrientation(.portraitUpsideDown)
        }
    }
}
