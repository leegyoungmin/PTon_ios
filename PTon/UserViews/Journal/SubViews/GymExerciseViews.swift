//
//  GymExerciseViews.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import SwiftUI

struct GymExerciseViews:View{
    @Binding var selectedDate:Date
    var body: some View{
        VStack{
            
            HStack{
                Text("GYM 운동")
                    .fontWeight(.bold)
                Spacer()
                
            }
            .padding()
            
            Text("기록된 운동이 없습니다.")
                .padding()
                .frame(width: 300, height: 100, alignment: .center)
        }
        .background(.white)
        .cornerRadius(5)
        .shadow(color: .gray.opacity(0.5), radius: 3)
    }
}

struct GymExerciseView_Previews:PreviewProvider{
    static var previews: some View{
        GymExerciseViews(selectedDate: .constant(Date()))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(backgroundColor)
    }
}
