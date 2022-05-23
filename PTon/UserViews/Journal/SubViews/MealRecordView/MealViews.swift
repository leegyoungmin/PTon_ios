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
    @StateObject var viewModel:MealRecordViewModel
    @Binding var selectedDate:Date
    @State var currentTab:mealType = .first
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
                
                Text("0kcal / 600kcal")
                    .foregroundColor(.gray)
            }
            .padding()
            
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 200, height: 100, alignment: .center)
                .padding()
            
            mealTabs(tabs: $titles, selection: $selectedIndex, underlineColor: .black) { title, isSelected in
                Text(title)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .black:.gray)
            }
            
            ZStack{
                NavigationLink(isActive: $isPresentSearch) {
                    MealSearchView(queryInputController: algoriaController.queryInputController,
                                   hitsController: algoriaController.hitsController, isPresented: $isPresentSearch,
                                   userId: viewModel.userId,
                                   trainerId: viewModel.trainerId,
                                   mealType: convertMealType(selectedIndex)
                    )
                } label: {
                    EmptyView()
                }
                
                userMealTableView(index: $selectedIndex,isPresent: $isPresentSearch)
            }
        }
        .background(.white)
        .cornerRadius(5)
        .shadow(color: .gray.opacity(0.5), radius: 3)
    }
}

struct userMealTableView:View{
    //MARK: - VIEW PROPERTIES
    @Binding var index:Int
    @Binding var isPresent:Bool
    let grid = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View{
        LazyVGrid(columns: grid, alignment: .center, spacing: 20) {
            ForEach(1...4,id:\.self) { _ in
                VStack{
                    Circle()
                        .fill()
                    
                    Text("소시지 구이")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    Text("180Kcal")
                        .foregroundColor(.black)
                }
            }
            
            Button {
                withAnimation {
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
