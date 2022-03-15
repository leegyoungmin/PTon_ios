//
//  RequestingExerciseView.swift
//  Salud0.2
//
//  Created by 이관형 on 2021/12/08.
//

import Foundation
import SwiftUI


enum RequestingExerciseType:String,CaseIterable{
    case Fitness = "Fitness",Aerobic = "유산소",Back = "등",Chest = "가슴",Arm = "팔",Leg = "하체",Shoulder = "어깨", Abs = "복근"
}


struct RequestingExerciseView:View{
    let compareType:[String] = ["Fitness","Aerobic","Back","Chest","Arm","Leg","Shoulder","Abs"]
    @State private var selectedTab = 0
    @State var exerciseType = RequestingExerciseType.allCases.map({$0.rawValue})
    @StateObject var viewmodel:RequestingExerciseViewModel
    var body: some View{
        VStack{
            Tabs(tabs: $exerciseType,
                 selection: $selectedTab,
                 underlineColor: .accentColor) { title, isSelected in
                Text(title)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .black:Color(uiColor: UIColor.lightGray))
            }
            VStack{
                if viewmodel.ExerciseList[compareType[selectedTab]] != nil{
                    let exercises = viewmodel.ExerciseList[compareType[selectedTab]]!.sorted(by: {$0.name<$1.name})
                    
                    if exercises.isEmpty{
                        Spacer()
                        Text("저장된 운동이 없습니다.")
                        Spacer()
                    }else{
                        List{
                            ForEach(exercises,id: \.self) { exercise in
                                if exercise.type == "Aerobic"{
                                    RequestingExerciseAeCellView(isContain: exercise.isContain, exercise: exercise)
                                        .environmentObject(self.viewmodel)
                                }else{
                                    RequestingExerciseAnCellView(exercise: exercise,isContain: exercise.isContain)
                                        .environmentObject(self.viewmodel)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .listRowSeparator(.hidden)
                    }
                    
                    
                }else if viewmodel.ExerciseList["AnAerobic"] != nil{
                    let exercises = viewmodel.ExerciseList["AnAerobic"]!.filter{$0.part == compareType[selectedTab]}.sorted(by: {$0.name<$1.name})
                    
                    if exercises.isEmpty{
                        Spacer()
                        Text("저장된 운동이 없습니다.")
                        Spacer()
                    }else{
                        List{
                            ForEach(exercises,id:\.self){ exercise in
                                RequestingExerciseAnCellView(exercise: exercise,isContain: exercise.isContain)
                                    .environmentObject(self.viewmodel)
                            }
                        }
                        .listStyle(.plain)
                        .listRowSeparator(.hidden)
                    }
                }
                
                Button {
                    viewmodel.setData()
                } label: {
                    Text("운동전송하기")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width)
                }
                .padding(5)
                .padding(.top,5)
                .buttonStyle(.plain)
                .background(Color.accentColor.edgesIgnoringSafeArea(.bottom))
                
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
    }
    
    struct RequestingExerciseAeCellView:View{
        @EnvironmentObject var viewmodel:RequestingExerciseViewModel
        @State var isContain:Bool = false
        @State var minuteText:String = ""
        let exercise:RequestingExercise
        var body: some View{
            HStack{
                URLImageView(urlString: exercise.url, imageSize: 50, youtube: false)
                
                Text(exercise.name)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.1)
                
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
                
                Button {
                    if minuteText == ""{
                        print("안되용")
                    }else{
                        viewmodel.setExerciseData(data: exercise,set: "",weight: "",time: "",minute: minuteText)
                        self.isContain = true
                    }
                    
                } label: {
                    Image(systemName: isContain ? "checkmark.circle.fill":"circle")
                }
                .buttonStyle(.plain)
                .disabled(isContain)
                
            }
            .padding()
            .background(
                Rectangle()
                    .strokeBorder(.gray.opacity(0.1))
            )
            .onAppear {
                if exercise.minute != nil{
                    minuteText = exercise.minute!.description
                }
            }
        }
    }
    
    
    struct RequestingExerciseAnCellView:View{
        @EnvironmentObject var viewmodel:RequestingExerciseViewModel
        var exercise:RequestingExercise
        @State var isContain:Bool = false
        @State var weightText:String = ""
        @State var timeText:String = ""
        @State var setText:String = ""
        var body: some View{
            HStack{
                
                URLImageView(urlString: exercise.url, imageSize: 50, youtube: false)
                
                Text(exercise.name)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.5)
                
                Spacer()
                
                // 1. Kg
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
                
                //2. Time
                VStack(alignment: .center,spacing:0){
                    TextField("", text: $timeText)
                        .frame(width: 40, alignment: .center)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.accentColor)
                    
                    Text("Time")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(5)
                .background(
                    Circle()
                        .foregroundColor(Color("Background"))
                )
                
                //3. Set
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
                
                Button {
                    if setText == "" || weightText == "" || timeText == ""{
                        print("안되용")
                    }else{
                        viewmodel.setExerciseData(data: exercise,set: setText,weight: weightText,time: timeText, minute: "")
                        self.isContain = true
                    }
                    
                    
                } label: {
                    Image(systemName: isContain ? "checkmark.circle.fill":"circle")
                }
                .buttonStyle(.plain)
                .disabled(isContain)
                
                
            }
            .padding()
            .background(
                Rectangle()
                    .strokeBorder(.gray.opacity(0.1))
            )
            .onAppear {
                if exercise.set != nil && exercise.weight != nil && exercise.time != nil{
                    self.setText = exercise.set!.description
                    self.weightText = exercise.weight!.description
                    self.timeText = exercise.time!.description
                }
            }
        }
    }
    
    struct RequestingExerciseView_Previews:PreviewProvider{
        static var previews: some View{
                    RequestingExerciseView(viewmodel: RequestingExerciseViewModel("asdasd", "asdasd", selecteDate: "asjndjkasd"))
//            RequestingExerciseAnCellView(exercise: RequestingExercise(name: "asd", type: "asda", paramter: "asda", url: "asdas"))
//                .previewLayout(.sizeThatFits)
        }
    }
    
}

struct Tabs<Label:View>:View{
    
    @Binding var tabs:[String]
    @Binding var selection:Int
    let underlineColor:Color
    let label:(String,Bool) -> Label
    
    var body: some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 0) {
                ForEach(tabs,id:\.self) {
                    self.tab(title:$0)
                }
            }
        }
    }
    
    private func tab(title:String) -> some View{
        let index = self.tabs.firstIndex(of: title)!
        let isSelected = index == selection
        return Button {
            withAnimation {
                self.selection = index
            }
        } label: {
            label(title, isSelected)
                .frame(width:UIScreen.main.bounds.width/5)
                .padding(.bottom)
                .background(
                    Rectangle()
                        .foregroundColor(.clear)
                        .overlay(
                            Rectangle()
                                .frame(width:UIScreen.main.bounds.width/5,height:2)
                                .foregroundColor(isSelected ? .black:Color(uiColor: UIColor.lightGray))
                                .transition(.move(edge: .bottom))
                            ,alignment: .bottom
                        )
                )
        }
        .buttonStyle(.plain)
        
    }
}
