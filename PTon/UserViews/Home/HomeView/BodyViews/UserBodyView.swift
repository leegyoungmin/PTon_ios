//
//  UserBodyView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/31.
//

import Foundation
import SwiftUI
import SwiftUICharts
import ExytePopupView

struct UserBodyCellView:View{
    let title:String
    let imageName:String
    let data:Double
    let unit:String
    let color:Color
    var body: some View{
        HStack{
            Image(imageName)
                .resizable()
                .frame(width: 25, height: 25, alignment: .center)
                .padding(10)
                .background(color)
                .cornerRadius(5)
            
            Text(title)
                .font(.title3)
                .fontWeight(.light)
            
            Spacer()
            
            Text("\(data)\(unit)")
                .foregroundColor(.accentColor)
            
        }
    }
}

struct chartView:View{
    let dataType:bodyDataType
    var data:[(String,Double)]
    
    init(_ dataType:bodyDataType,data:[(String,Double)]){
        self.dataType = dataType
        self.data = data
    }
    
    private func convertTitle()->String{
        var title:String = ""
        if self.dataType == .weight{
            title = "체중변화"
        }else if self.dataType == .fat{
            title = "체지방량변화"
        }else if self.dataType == .muscle{
            title = "근골격근량변화"
        }
        return title
    }
    
    private func convertUnit()->String{
        var unit:String = ""
        if self.dataType == .weight || self.dataType == .muscle{
            unit = "Kg"
        }else{
            unit = "%"
        }
        return unit
    }
    
    var body: some View{
        let chartStyle = ChartStyle(backgroundColor: .white, accentColor: .white, gradientColor: .init(start: .blue.opacity(0.3), end: .purple.opacity(0.3)), textColor: .black, legendTextColor: .black, dropShadowColor: .white)
        
        BarChartView(data: ChartData(values: data), title: convertTitle(), legend: convertUnit(), style: chartStyle, form: ChartForm.extraLarge, dropShadow: false, cornerImage: nil, valueSpecifier: "%.0f", animatedToBack: true)
        
    }
}


