//
//  TodayExerciseview.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import SwiftUI
import Kingfisher

struct iconItem:Hashable{
    var iconName:String
    var dataType:dataType
}

enum dataType{
    case time
    case kcal
    case numberCount
    case setCount
    
    var description:String{
        switch self {
        case .time:
            return "시간"
        case .kcal:
            return "활동량"
        case .numberCount:
            return "1회 수"
        case .setCount:
            return "세트 수"
        }
    }
}

enum pageType:Int,Identifiable{
    var id:RawValue{rawValue}
    case gym = -1
    case general = 1
}

struct TodayExerciseView:View{
    let controller = ExerciseSearchController()
    let rows = Array(repeating: GridItem(.flexible()), count: 4)
    let iconItems:[iconItem] = [
        iconItem(iconName: "timeIcon", dataType: .time),
        iconItem(iconName: "kcalIcon", dataType: .kcal),
        iconItem(iconName: "numberIcon", dataType: .numberCount),
        iconItem(iconName: "setIcon", dataType: .setCount)
    ]
    @StateObject var viewModel:userExerciseSearchViewModel
    @State var selectedIndex:Int = 0
    @State var isshowAlert:Bool = false
    @State var userSelctedType:pageType?
    
    //MARK: - FUNCTIONS
    private func checkStrength(_ raw:Double)->Color{
        switch raw{
        case 0...2.5:
            return Color.green
        case 2.5...3.5:
            return Color.yellow
        case 3.5...:
            return Color.red
        default:
            return Color.green
        }
    }
    
    var body: some View{
        VStack{
            //1. Header View
            HStack{
                Text("오늘의 운동")
                    .fontWeight(.bold)
                
                Spacer()
                
                
                Button {
                    isshowAlert = true
                } label: {
                    Label("운동등록하기", systemImage: "plus.circle.fill")
                        .font(.footnote)
                }
                
            }
            .padding()
            
            if viewModel.recordedData.isEmpty{
                Text("기록된 운동이 없습니다.")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .frame(height:250)
            }else{
                TabView(selection: $selectedIndex) {
                    
                    ForEach(viewModel.recordedData,id:\.id) { exercise in
                        VStack{
                            HStack(spacing:10){
                                KFImage(URL(string: exercise.url))
                                    .resizable()
                                    .onFailureImage(KFCrossPlatformImage(named: "defaultImage"))
                                    .frame(width: 80, height: 80, alignment: .center)
                                    .cornerRadius(30)
                                    .shadow(color: .gray, radius: 1, x: 0, y: 0)
                                
                                VStack(alignment:.leading,spacing:3){
                                    
                                    Text(exercise.exerciseName)
                                        .font(.title3)
                                        .fontWeight(.heavy)
                                    
                                    Text(exercise.engName)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                    HStack{
                                        if exercise.part.description.contains("운동"){
                                            Text(exercise.part.description)
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                        }else{
                                            Text(exercise.part.description+" 운동")
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Circle()
                                            .fill(checkStrength(exercise.parameter))
                                            .frame(width: 10, height: 10)
                                    }
                                    
                                }
                                
                                Spacer()
                            }
                            .padding()
                            
                            Divider()
                            
                            LazyVGrid(columns: rows, alignment: .center) {
                                ForEach(iconItems,id:\.self){ icon in
                                    VStack{
                                        Image(icon.iconName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                        
                                        Text(icon.dataType.description)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                        
                                        userDataView(exercise: exercise, icon.dataType)
                                            .font(.footnote)
                                        
                                    }
                                    
                                }
                            }
                            .padding()
                            
                        }
                    }
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height:250)
            }
            

        }
        .background(.white)
        .cornerRadius(5)
        .shadow(color: .gray.opacity(0.5), radius: 3)
        .confirmationDialog("운동 추가 방법", isPresented: $isshowAlert,titleVisibility: .visible) {
            Button {
                self.userSelctedType = .general
            } label: {
                Text("일반 운동 검색")
            }
            
            Button {
                self.userSelctedType = .gym
            } label: {
                Text("피트니스 센터 운동")
            }
            
        }
        .fullScreenCover(item: $userSelctedType) { type in
            if type.rawValue < 0{
                fitnessCenterExerciseView(viewModel: userFitnessExerciseViewModel(userId: viewModel.userId, fitnessCode: viewModel.fitnessCode))
            }else{
                userExerciseSearchView(hitsController: controller.hitsController,
                                       queryController: controller.searchBoxController,
                                       facetListController: controller.facetListController)
                .environmentObject(self.viewModel)
            }
        }
    }
    
    @ViewBuilder
    private func userDataView(exercise:userExerciseData,_ dataType:dataType) -> some View{
        switch dataType {
        case .time:
            Text("\(exercise.minute)분")
        case .kcal:
            Text("\(Int(exercise.expectedKcal))kcal")
        case .numberCount:
            Text("\(exercise.time ?? "0")회")
        case .setCount:
            Text("\(exercise.set ?? "0")세트")
        }
    }
}

struct TodayExerciseView_Previews:PreviewProvider{
    static var previews: some View{
        TodayExerciseView(viewModel: userExerciseSearchViewModel(userId: "kakao:1967260938", fitnessCode: "000001", selectedDate: Date()))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
