//
//  UserBaseInfoViews.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import Foundation
import SwiftUI

struct UserBaseInfoView:View{
    @Binding var selectedDate:Date
    var body: some View{
        VStack{
            
            HStack{
                
                Text("나의 신체정보")
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    print(123)
                } label: {
                    Text("저장")
                        .fontWeight(.light)
                        .foregroundColor(.white)
                        .padding(.horizontal,10)
                        .padding(.vertical,5)
                        .background(Color.accentColor)
                        .cornerRadius(20)
                }
                .buttonStyle(.plain)

            }//:HSTACK
            .padding(.horizontal)
            .padding(.top)
            
            Divider()
                .frame(height:2)
                .padding(.horizontal)
            
            HStack{
                Image("defaultImage")
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .leading)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(pink)
                    )
                
                Text("몸무게")
                Spacer()
                
                TextField("", text: .constant(""))
                    .frame(width:50)
                Text("kg")
            }
            .padding(.horizontal)
            
            Divider()
                .frame(height:2)
                .padding(.horizontal)
            
            HStack{
                Image("defaultImage")
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .leading)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(sky)
                    )
                
                Text("체지방률")
                Spacer()
                
                TextField("", text: .constant(""))
                    .frame(width:50)
                Text("%")
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            HStack{
                Image("defaultImage")
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .leading)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(yello)
                    )
                
                Text("근골격근량")
                Spacer()
                
                TextField("", text: .constant(""))
                    .frame(width:50)
                Text("kg")
            }
            .padding(.horizontal)
            .padding(.bottom,10)
        }
        .background(.white)
        .cornerRadius(5)
        .shadow(color: .gray.opacity(0.5), radius: 3)
    }
}

struct userBaseInfoView_Previews:PreviewProvider{
    static var previews: some View{
        UserBaseInfoView(selectedDate: .constant(Date()))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(backgroundColor)
    }
}
