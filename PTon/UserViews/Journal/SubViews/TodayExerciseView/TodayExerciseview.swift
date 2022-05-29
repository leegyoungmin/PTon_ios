//
//  TodayExerciseview.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import SwiftUI

struct TodayExerciseView:View{
    let controller = ExerciseSearchController()
    let rows = Array(repeating: GridItem(.flexible()), count: 4)
    var body: some View{
        VStack{
            //1. Header View
            HStack{
                Text("오늘의 운동")
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink {
                    userExerciseSearchView(hitsController: controller.hitsController, queryController: controller.queryInputController, facetListController: controller.facetListContorller)
                } label: {
                    Label("운동등록하기", systemImage: "plus.circle.fill")
                        .font(.footnote)
                }

            }
            .padding()
            
            Text("기록된 운동이 없습니다.")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .frame(height:150)
            
            Divider()
            
            LazyVGrid(columns: rows, alignment: .center) {
                ForEach(1..<5) { index in
                    VStack (spacing:8){
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        
                        Text("시간 \(index)")
                    }
                }

            }
            .padding()
        }
        .background(.white)
        .cornerRadius(5)
        .shadow(color: .gray.opacity(0.5), radius: 3)
    }
}

struct TodayExerciseView_Previews:PreviewProvider{
    static var previews: some View{
        TodayExerciseView()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
