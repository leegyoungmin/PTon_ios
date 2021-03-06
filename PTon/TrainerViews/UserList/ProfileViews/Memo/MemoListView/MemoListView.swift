//
//  MemoListView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/12.
//

import Foundation
import SwiftUI

struct MemoListView:View{
    @StateObject var viewmodel:MemoListViewModel
    @State var tabList = ["공개","비공개"]
    @State var selectedIndex = 0
    let userName:String
    let trainerId:String
    let trainerName:String
    var body: some View{
        VStack{
            MemoTabs(tabs: $tabList, selection: $selectedIndex, underlineColor: .black){ title, selected in
                Text(title)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(selected ? .black:Color(uiColor: UIColor.lightGray))
            }
            .background(.white)
            
            
            VStack{
                if viewmodel.memoDatas(Bool.init(selectedIndex)).isEmpty{
                    emptyMemoView()
                }else{
                    List{
                        ForEach(viewmodel.memoDatas(Bool.init(selectedIndex)),id:\.self){ memo in
                            MemoListNavigationView(currentMemo: memo,
                                                   userName: self.userName,
                                                   trainerName: self.trainerName)
                            .environmentObject(self.viewmodel)
                        }
                        .onDelete { indexset in
                            guard let index = indexset.first else{return}
                            viewmodel.deleteData(data: viewmodel.memoDatas(Bool.init(selectedIndex))[index])
                        }
                    }
                    .listStyle(.plain)
                    .listRowSeparator(.hidden)
                    .padding()
                }
                
                HStack{
                    Spacer()
                    
                    NavigationLink {
                        MemoCreateView(viewmodel: MemoCreateViewModel(userid: viewmodel.userid))
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 50))
                            .shadow(color: .gray.opacity(0.1), radius: 1, x: 0, y: 1)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                   
                }
                .padding(.horizontal)
            }
        }
        .background(Color("Background"))
        .onDisappear {
            viewmodel.viewDisAppear()
        }
    }
}

struct MemoListCellView:View{
    let memo:Memo
    let userId:String
    let userName:String
    let trainerId:String
    
    @StateObject var viewModel:UserDetailMemoViewModel
    init(memo:Memo,userId:String,userName:String,trainerId:String){
        self.memo = memo
        self.userId = userId
        self.userName = userName
        self.trainerId = trainerId
        
        _viewModel = StateObject.init(wrappedValue: UserDetailMemoViewModel.init(userId, userName, trainerId, memo.uuid))
    }
    var body: some View{
        VStack(alignment:.leading,spacing:5){
            HStack{
                Text(memo.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "chevron.forward")
                    .foregroundColor(.accentColor)
            }
            
            HStack{
                Text(memo.time.replacingOccurrences(of: "-", with: "."))
                    .font(.body)
                    .foregroundColor(.gray.opacity(0.5))
                Spacer()
            }
            
            HStack{
                Text(memo.content)
                    .font(.body)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.top,10)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Text("\(viewModel.unReadCount)")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.accentColor)
                    )
                    .opacity(viewModel.unReadCount == 0 ? 0:1)
            }
        }
        .padding(5)
    }
}
//
//struct MemoListView_Previews:PreviewProvider{
//    static var previews: some View{
////        MemoListView(viewmodel: MemoListViewModel(userid: "kakao:1967260938"))
//        MemoListCellView(memo: Memo(
//            uuid: UUID().uuidString,
//            title: "Example_1",
//            content: "Example",
//            time: convertString(content: Date(), dateFormat: "yyyy.MM.dd HH:mm"),
//            isPrivate: false,
//            isRead: false,
//            firstMeal: ["식사1"],
//            secondMeal: ["식사2"],
//            thirdMeal: [], snack: [])
//        )
//        .previewLayout(.sizeThatFits)
//    }
//}
//

struct MemoListNavigationView:View{
    @EnvironmentObject var viewModel:MemoListViewModel
    let currentMemo:Memo
    let userName:String
    let trainerName:String
    var body: some View{
        ZStack{
            NavigationLink {
                TrainerDetailMemoView(viewmodel: DetailMemoViewModel(userId: viewModel.userid,
                                                              userName: self.userName,
                                                              trainerId: viewModel.trainerid,
                                                              trainerName: trainerName,
                                                              memoId: currentMemo.uuid,
                                                              userProfile: viewModel.userProfile),
                               currentMemo: currentMemo)
            } label: {
                EmptyView()
            }
            .buttonStyle(.plain)
            .opacity(0.0)

            MemoListCellView(memo: currentMemo,
                             userId: viewModel.userid,
                             userName: userName,
                             trainerId: viewModel.trainerid)
        }
    }
}

struct emptyMemoView:View{
    var body: some View{
        Spacer()
        Text("저장된 메모가 없습니다.")
        Spacer()
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
