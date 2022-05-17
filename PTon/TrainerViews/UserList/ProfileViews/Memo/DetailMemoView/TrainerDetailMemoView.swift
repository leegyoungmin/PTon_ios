//
//  PublicMemoView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/16.
//

import SwiftUI

struct TrainerDetailMemoView: View {
    //MARK: - PROPERTIES
    @Environment(\.editMode) private var editMode
    @StateObject var viewmodel:DetailMemoViewModel
    @State var currentMemo:Memo
        
    //MARK: - VIEW
    var body: some View {
        VStack(spacing:0) {
            if editMode?.wrappedValue.isEditing == false{
                ReadModeMemoView(currentMemo: $currentMemo)
                    .environmentObject(self.viewmodel)
            }else{
                EditModeMemoView(currentMemo: $currentMemo)
            }
        }//:VSTACK
        .onDisappear {
            viewmodel.viewDisapper(data: currentMemo)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                
                if viewmodel.isTrainer(){
                    EditButton()
                        .tint(Color.accentColor)
                }
            }
        }//:TOOLBAR
        .onChange(of: editMode?.wrappedValue.isEditing) { newValue in
            if newValue == false{
                self.currentMemo.firstMeal.removeAll{$0 == ""}
                self.currentMemo.secondMeal.removeAll{$0 == ""}
                self.currentMemo.thirdMeal.removeAll{$0 == ""}
            }
        }
    }
}



//MARK: - PREVIEWS
struct PublicMemoView_Previews: PreviewProvider {
    static var viewModel = DetailMemoViewModel(userId: "asd", userName: "asd", trainerId: "asd", trainerName: "asd", memoId: "asd", userProfile: "")
    static var previews: some View {
        mealEditCell(mealType: "아침", meals: .constant(["eaxmple1"]))
    }
}

extension DetailMemoViewModel{
    func caculateDate(_ comment:comment,completion:@escaping(String)->Void){
        let dates = comment.time.components(separatedBy: ["-",":"," "])
        
        guard let year = Int(dates[0]),
              let month = Int(dates[1]),
              let day = Int(dates[2]),
              let hour = Int(dates[3]),
              let minute = Int(dates[4]) else {return}
        
        
        let calendar = Calendar(identifier: .gregorian)
        let comp = DateComponents(year:year,month: month,day: day,hour: hour,minute: minute)
        
        if let startDate = calendar.date(from: comp){
            let offsetComps = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: startDate, to: Date())
            if case let (y?,m?,d?,h?,minute?) = (offsetComps.year,offsetComps.month,offsetComps.day,offsetComps.hour,offsetComps.minute){
                
                if y > 0{
                    completion("\(y)년 전")
                }else if m > 0{
                    completion("\(m)달 전")
                }else if d > 0{
                    completion("\(d)일 전")
                }else if h > 0{
                    completion("\(h)시간 전")
                }else if minute > 0{
                    completion("\(minute)분 전")
                }else if minute == 0{
                    completion("지금")
                }
                
            }
        }
    }
}
