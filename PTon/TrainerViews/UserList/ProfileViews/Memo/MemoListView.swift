//
//  MemoListView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/12.
//

import Foundation
import SwiftUI

struct MemoListView:View{
    @State var tabList = ["공개","비공개"]
    @State var selectedIndex = 0
    let userid:String
    var body: some View{
        VStack{
            MemoTabs(tabs: $tabList, selection: $selectedIndex, underlineColor: .black){ title, selected in
                Text(title)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(selected ? .black:Color(uiColor: UIColor.lightGray))
            }
            .background(.white)
            
            
            ZStack{
                
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        
                        NavigationLink {
                            MemoCreateView(viewmodel: MemoCreateViewModel(userid: userid))
                        } label: {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 30))
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.trailing)
                
                Text("작성된 메모가 없습니다.")
            }
            
            Spacer()
        }
        .background(Color("Background"))
    }
}

//
//struct MemoListCellView:View{
//    @State var memo:Memo
//    @State var ButtonClicked:Bool = false
//    var body: some View{
//
//        HStack{
//            VStack(alignment: .leading, spacing: 0){
//                Text(memo.title)
//
//                Text(memo.date)
//                    .font(.footnote)
//                    .padding(.bottom,20)
//                    .foregroundColor(.gray)
//
//                Text(memo.contents)
//                    .lineLimit(2)
//                    .font(.footnote)
//                    .foregroundColor(.gray)
//            }
//
//
//            Spacer()
//
//            VStack{
//                Image(systemName: "chevron.forward")
//                    .foregroundColor(.accentColor)
//                Spacer()
//            }
//        }
//        .padding(5)
//        .padding(.horizontal,10)
//        .background(.white)
//        .padding(.top,5)
//
//    }
//}

struct MemoListView_Previews:PreviewProvider{
    static var previews: some View{
        MemoListView(userid: "asdasd")
    }
}


private struct MemoTabs<Label:View>:View{
    
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
                .frame(width:UIScreen.main.bounds.width/2)
                .padding(.bottom)
                .background(
                    Rectangle()
                        .foregroundColor(.clear)
                        .overlay(
                            Rectangle()
                                .frame(width:UIScreen.main.bounds.width/2,height:2)
                                .foregroundColor(isSelected ? .black:Color(uiColor: UIColor.lightGray))
                                .transition(.move(edge: .bottom))
                            ,alignment: .bottom
                        )
                )
        }
        .buttonStyle(.plain)
        
    }
}

