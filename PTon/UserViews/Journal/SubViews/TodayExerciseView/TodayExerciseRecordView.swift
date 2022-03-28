//
//  TodayExerciseRecordView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/26.
//

import SwiftUI

struct TodayExerciseRecordView: View {
    //MARK: - PROPERTIES
    @EnvironmentObject var viewModel:TodayExerciseViewModel
    let selectedDate:Date
    @State var exerciseList:[String] = ["유산소","무산소"]
    @State var selectedTab:Int = 0
    
    var exercise:userExercise = Bundle.main.decode("Exercises.json")
    
    //MARK: - VIEWS
    var body: some View {
        VStack(spacing:0){
            ExerciseRecordTab(tabs: $exerciseList, selection: $selectedTab, underlineColor: .black) { title, isSelected in
                
               Text(title)
                   .font(.system(size: 14))
                   .fontWeight(.semibold)
                   .foregroundColor(isSelected ? .black:Color(uiColor: UIColor.lightGray))
            }
            
            if selectedTab == 0{
                TodayAerobicExeciseRecordView(selectedDate:selectedDate,
                                              exercises: exercise.aerobic)
                .environmentObject(self.viewModel)
            }else{
                TodayAnAerobicExerciseRecordView(selectedDate:selectedDate,exercises: exercise.anAerobic)
                    .environmentObject(self.viewModel)
            }
        }//:VSTACK
        .onDisappear {
            viewModel.fetchData(selectedDate)
        }

    }
}

//MARK: - PREVIEWS
struct TodayExerciseRecordView_Previews: PreviewProvider {
    static var previews: some View {
        TodayExerciseRecordView(selectedDate: Date())
            .environmentObject(TodayExerciseViewModel(userId: "kakao:1967260938"))
    }
}


struct ExerciseRecordTab<Label:View>:View{
    
    @Binding var tabs:[String]
    @Binding var selection:Int
    let underlineColor:Color
    let label:(String,Bool) -> Label
    
    var body: some View{
        HStack(alignment: .center, spacing: 0) {
            ForEach(tabs,id:\.self) {
                self.tab(title:$0)
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
                .frame(width:UIScreen.main.bounds.width/2)
                .padding(.bottom)
                .background(
                    Rectangle()
                        .foregroundColor(.clear)
                        .overlay(
                            Rectangle()
                                .frame(height:2)
                                .foregroundColor(isSelected ? .black:Color(uiColor: UIColor.lightGray))
                                .transition(.move(edge: .bottom))
                            ,alignment: .bottom
                        )
                )
        }
        .buttonStyle(.plain)
        
    }
}
