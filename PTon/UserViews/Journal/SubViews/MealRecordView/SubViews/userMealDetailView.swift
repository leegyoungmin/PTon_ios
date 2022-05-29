//
//  userMealDetailView.swift
//  PTon
//
//  Created by 이경민 on 2022/05/27.
//

import SwiftUI
import Kingfisher

//MARK: - User Meal Detail View
struct userMealDetailView:View{
    @Environment(\.dismiss) private var dismiss
    let food:userFoodResult
    
    var body: some View{
        ScrollView(.vertical, showsIndicators: false) {
            GeometryReader { proxy in
                
                VStack{
                    if proxy.frame(in: .global).minY <= 0{
                        ZStack{
                            
                            KFImage(URL(string: food.url))
                                .onFailureImage(KFCrossPlatformImage(named: "defaultImage"))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .offset(y:proxy.frame(in: .global).minY/9)
                                .clipped()
                            VStack{
                                HStack{
                                    Button {
                                        withAnimation {
                                            dismiss.callAsFunction()
                                        }
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .font(.title)
                                            .foregroundColor(.black)
                                    }
                                    .buttonStyle(.plain)


                                    Spacer()
                                }
                                .padding(.top,30)
                                
                                Spacer()
                            }
                            .padding([.top,.leading])
                        }
                        
                    }else{
                        ZStack{
                            KFImage(URL(string: food.url))
                                .onFailureImage(KFCrossPlatformImage(named: "defaultImage"))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: proxy.size.width, height: proxy.size.height + proxy.frame(in: .global).minY)
                                .clipped()
                                .offset(y:-proxy.frame(in: .global).minY)
                            
                            
                            VStack{
                                HStack{
                                    Button {
                                        withAnimation {
                                            dismiss.callAsFunction()
                                        }
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .font(.title)
                                            .foregroundColor(.black)
                                    }
                                    .buttonStyle(.plain)
                                    Spacer()
                                }
                                .padding(.top,30)
                                
                                Spacer()
                            }
                            .padding([.top,.leading])
                            .offset(y:-proxy.frame(in: .global).minY)
                        }
                    }
                }
                
                
            }
            .frame(height:300)
            
            VStack(alignment: .leading,spacing: 0) {
                HStack{
                    Text(food.foodName)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .font(.system(size: 50, weight: .heavy, design: .default))
                    
                    Spacer()
                }

                HStack{
                    Text("kcal 정보")
                    Spacer()
                    Text("\(food.kcal)kcal / \(food.intake)g")
                }
                .font(.system(size: 20, weight: .semibold, design: .default))
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding(.top)

                Text("영양정보")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.leading,5)
                    .padding(.top)
                
                VStack{
                    mealDetailNutrientCellView(title: "탄수화물", value: food.carbs, unit: "g")
                    mealDetailNutrientCellView(title: "단백질", value: food.protein, unit: "g")
                    mealDetailNutrientCellView(title: "지방", value: food.fat, unit: "g")
                    mealDetailNutrientCellView(title: "나트륨", value: food.sodium, unit: "mg")
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding(.top,10)
            }
            .frame(width:350)
        }
        .background(backgroundColor)
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
    }
}

struct mealDetailNutrientCellView:View{
    let title:String
    let value:Int
    let unit:String
    var body: some View{
        HStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.accentColor)
                .frame(width:5,height:30)
            Text(title)
            Spacer()
            Text("\(value)\(unit)")
        }
    }
}

struct userMealDetailView_Previews: PreviewProvider {
    static var previews: some View {
        userMealDetailView(food: userFoodResult(id: "asd", mealType: .first, carbs: 10, fat: 10, foodName: "asdnjas", intake: 10, kcal: 10, protein: 10, sodium: 10, url: "https://firebasestorage.googleapis.com:443/v0/b/pton-1ffc0.appspot.com/o/FoodJournal%2Fkakao:1967260938%2FFoodJournal_2022_05_27_02_46_28.jpg?alt=media&token=79c5c690-b56d-4dc7-9c90-e4ab50eba78c"))
    }
}
