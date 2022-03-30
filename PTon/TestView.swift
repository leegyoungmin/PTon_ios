//
//  TestView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/29.
//

import Foundation
import SwiftUI

struct TestView:View{
    var body: some View{
        VStack{
            Spacer()
            Text("Test")
                .onTapGesture {
                    requestGet(url: "https://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList?serviceKey=fNF57A6%2FdZZtGoxp9uTDfVjCQNAvKcuopT35EvbFrxJBvOiHVNgZ9tzux9EvsZEsJTHNV78yj%2FPuVA5c7vbHSQ%3D%3D&pageNo=1&numOfRows=3&type=json", completion: { (success,data) in
                        print(success)
                    })
                }
            Spacer()
        }
    }
}
