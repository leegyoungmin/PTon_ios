//
//  MealViews.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import SwiftUI

//TODO: - 데이터 로컬 저장 및 로컬에서 불러오기
struct MealViews:View{
    @StateObject var viewModel:MealRecordViewModel
    @Binding var selectedDate:Date
    @State var selectedTabs:Int = 0
    @State var mealTypes = mealType.allCases.map({$0.rawValue})
    @State var showingSheet:Bool = false
    @State var cameraView:UIImagePickerController.SourceType = .camera
    @State var isShowCamera:Bool = false
    @State var isEditMode:Bool = false
    @State var uiImage = UIImage()
    
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
            
            Text("그래프 들어가는 자리")
                .frame(width:UIScreen.main.bounds.width*0.8,height: 200, alignment: .center)
            
            mealTabs(tabs: $mealTypes,
                 selection: $selectedTabs,
                 underlineColor: .accentColor) { title, isSelected in
                Text(title)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .black:Color(uiColor: UIColor.lightGray))
            }
            
            
            LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())], alignment: .center,spacing: 20) {
                
                if selectedTabs == 0{
                    ForEach(viewModel.breakFirstMeals,id:\.self) { meal in
                        userMealCellView(meal: meal)
                    }
                }
                
                if selectedTabs == 1{
                    ForEach(viewModel.lauchMeals,id:\.self){ meal in
                        userMealCellView(meal: meal)
                    }
                }
                
                if selectedTabs == 2{
                    ForEach(viewModel.snackMeals,id:\.self){ meal in
                        userMealCellView(meal: meal)
                    }
                }
                
                if selectedTabs == 3{
                    ForEach(viewModel.dinnerMeals,id:\.self){ meal in
                        userMealCellView(meal: meal)
                    }
                }
                
                Button {
                    showingSheet = true
                } label: {
                    VStack(alignment: .center){
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .font(.system(size: 30))
                            .padding()
                            .overlay(
                                Circle()
                                    .stroke(.gray)
                            )
                        Text("식단을\n기록해주세요.")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundColor(.gray)

                    }
                }
                .buttonStyle(.plain)
                
            }
            .padding()
            .onAppear {
                viewModel.fetchData(selectedDate)
            }
            
            NavigationLink(isActive: $isEditMode) {
                MealEditViews(image: $uiImage,selectedDate: selectedDate, index: selectedTabs)
                    .environmentObject(self.viewModel)
            } label: {
                EmptyView()
            }

        }
        .background(.white)
        .cornerRadius(5)
        .shadow(color: .gray.opacity(0.5), radius: 3)
        .confirmationDialog("식단 사진 설정", isPresented: $showingSheet) {
            
            Button("사진찍기") {
                self.cameraView = .camera
                self.isShowCamera = true
            }
            Button("앨범에서 선택") {
                self.cameraView = .photoLibrary
                self.isShowCamera = true
            }
            Button("취소",role: .cancel) {
                self.showingSheet = false
            }
        }
        .fullScreenCover(isPresented: $isShowCamera,onDismiss: {
            self.isEditMode = true
        }) {
            if self.cameraView == .camera{
                MealCameraView(image: $uiImage,sourceType: .camera)
                    .edgesIgnoringSafeArea(.all)
            } else if self.cameraView == .photoLibrary{
                MealImagePickerView(image: $uiImage,isPresented: $isShowCamera)
            }
        }
    }
}

struct userMealCellView:View{
    let meal:userMeal
    var body: some View{
        VStack{
            
            URLImageView(urlString: meal.url, imageSize: 80, youtube: false)
            
            Text(meal.name)
                .font(.footnote)
                .foregroundColor(.gray.opacity(0.5))
            
            Text("180kcal")
        }
    }
}

struct MealViews_Previews:PreviewProvider{
    static var previews: some View{
        MealViews(viewModel: MealRecordViewModel("3yvE0bnUEHbvDKasU1Orf7DhvjX2", "kakao:1967260938"), selectedDate: .constant(Date()))
            .padding()
            .background(backgroundColor)
    }
}

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
