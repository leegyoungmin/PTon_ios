//
//  MealViews.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Kingfisher


//TODO: - 데이터 로컬 저장 및 로컬에서 불러오기
struct MealViews:View{
    @StateObject var viewModel:UserMealViewModel
    @Binding var selectedDate:Date
    @State var currentTab:mealType?
    @State var selectedIndex:Int = 0
    @State var titles:[String] = ["아침","점심","간식","저녁"]
    @State var isPresentSearch:Bool = false
    let algoriaController = AlgoliaController()
    
    func convertMealType(_ selection:Int)->mealType{
        switch selection{
        case 0:
            return .first
        case 1:
            return .second
        case 2:
            return .snack
        case 3:
            return .third
        default:
            return .first
        }
    }
    
    var body: some View{
        VStack{
            HStack{
                Text("오늘의 식단")
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(Int(viewModel.totalKcal)) / \(Int(viewModel.totalIngrendientKcal))kcal")
                    .foregroundColor(.gray)
            }
            .padding()
            
            ZStack{
                Circle()
                    .trim(from: 0, to: 0.5)
                    .stroke(Color.secondary,style: StrokeStyle(lineWidth:15,lineCap: .round))
                
                Circle()
                    .trim(from: 0, to: viewModel.chartRatio >= 0.5 ? 0.5:viewModel.chartRatio)
                    .stroke(viewModel.chartRatio >= 0.5 ? Color.red:Color.accentColor,style: StrokeStyle(lineWidth:15,lineCap: .round))
                    .animation(.easeIn, value: 5)
                VStack{
                    Text("현재칼로리")
                        .font(.title2)
                        .fontWeight(.light)
                        .foregroundColor(.secondary)
                    Text("\(Int(viewModel.totalKcal))kcal")
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                        .font(.largeTitle)
                }
                .rotationEffect(.degrees(-180))
                .offset(y:60)
            }
            .rotationEffect(.degrees(-180))
            .frame(width: UIScreen.main.bounds.width*0.8, height: 300, alignment: .center)
            .offset(y:300/5)
            .padding(-20)

            
            mealTabs(tabs: $titles, selection: $selectedIndex, underlineColor: .black) { title, isSelected in
                Text(title)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .black:.gray)
            }
            
            userMealTableView(selectedType: $currentTab, index: $selectedIndex,isPresent: $isPresentSearch)
                .environmentObject(self.viewModel)

        }
        .fullScreenCover(item: $currentTab, content: { type in
            
            MealSearchView(queryInputController: algoriaController.queryInputController,
                           hitsController: algoriaController.hitsController,
                           userId: viewModel.userId,
                           trainerId: viewModel.trainerId,
                           currentType: type,
                           selectedType: $currentTab)
        })
        .background(.white)
        .cornerRadius(5)
        .shadow(color: .gray.opacity(0.5), radius: 3)
        
    }
}

struct userMealTableView:View{
    //MARK: - VIEW PROPERTIES
    @EnvironmentObject var viewModel:UserMealViewModel
    @Binding var selectedType:mealType?
    @Binding var index:Int
    @Binding var isPresent:Bool
    let grid = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View{
        LazyVGrid(columns: grid, alignment: .center, spacing: 20) {
            ForEach(viewModel.recordedMeals.filter({$0.mealType == mealType.init(rawValue: index)}),id:\.self) { food in
                NavigationLink {
                    Text("Detail View")
                } label: {
                    VStack{
                        KFImage(URL(string: food.url))
                            .placeholder({ progress in
                                ProgressView()
                            })
                            .resizable()
                            .frame(width: 80, height: 80, alignment: .center)
                            .clipShape(Circle())
                            .background(
                                Circle()
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                        
                        Text(food.foodName)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                            .truncationMode(.middle)
                        
                        Text("\(food.kcal)Kcal")
                    }
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Image(systemName: "person.fill")
                }
            }
            
            Button {
                withAnimation {
                    selectedType = mealType.init(rawValue: index) ?? .first
                    isPresent = true
                }
            } label: {
                VStack(alignment: .center, spacing: 0) {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .font(.system(size: 40))
                        .padding()
                        .overlay(
                            Circle()
                                .stroke(.gray)
                        )
                    
                    Text("식단을\n기록해주세요.")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top)
                }
            }
            .buttonStyle(.plain)

        }
        .padding()
    }
}

extension MealViews{
    struct mealTabs<Label:View>:View{
        
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
                    .frame(width:UIScreen.main.bounds.width*0.9/4)
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
}
