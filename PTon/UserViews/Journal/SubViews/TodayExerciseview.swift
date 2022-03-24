//
//  TodayExerciseview.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import SwiftUI

struct TodayExerciseView:View{
    @Binding var selectedDate:Date
    var body: some View{
        VStack{
            HStack{
                Text("오늘의 운동")
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    print(123)
                } label: {
                    Label {
                        Image(systemName: "plus.circle.fill")
                    } icon: {
                        Text("운동 등록하기")
                    }

                }
            }//:HSTACK
            .padding()
            
            HStack{
                Spacer()
                Text("기록된 운동이 없습니다.")
                Spacer()
            }
            .frame(width: 300, height: 150, alignment: .center)
            
            Divider()
            
            HStack{
                infoLabel("시간", "clock.badge.checkmark")
                infoLabel("시간", "person.fill")
                infoLabel("시간", "person.fill")
                infoLabel("시간", "person.fill")
            }
            .padding(.vertical)
            
        }
        .background(.white)
        .cornerRadius(5)
        .shadow(color: .gray.opacity(0.5), radius: 3)
    }
    
    @ViewBuilder
    func infoLabel(_ title:String,_ imageString:String) -> some View{
        VStack{
            Image(systemName: imageString)
                .font(.system(size: 25))
            
            Text(title)
                .padding(.top,5)
            
            Text("0")
                .padding(.top,5)
        }
        .frame(width: 80, height: 100, alignment: .center)
    }
}

struct TodayExerciseView_Previews:PreviewProvider{
    static var previews: some View{
        TodayExerciseView(selectedDate: .constant(Date()))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(backgroundColor)
            
    }
}
