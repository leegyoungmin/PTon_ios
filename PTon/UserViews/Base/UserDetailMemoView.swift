//
//  UserDetailMemoView.swift
//  PTon
//
//  Created by 이경민 on 2022/05/14.
//

import SwiftUI

struct UserDetailMemoView: View {
    //MARK: - PROPERTIES
    @State var currentMemo:Memo
    @State var commentText:String = ""
    @State var proxyIndex:Int = 0
    @StateObject var viewModel:UserDetailMemoViewModel
    
    //MARK: - FUNCTIONS
    private func validationMeal() -> Bool{
        return (self.currentMemo.firstMeal.isEmpty) && (self.currentMemo.secondMeal.isEmpty) && (self.currentMemo.thirdMeal.isEmpty)
    }
    
    @ViewBuilder
    private func CommentLabel(name:String,comment:String)->some View{
        Text(name).fontWeight(.semibold) + Text("  ") + Text(comment).font(.footnote)
    }
    
    //MARK: - BODY
    var body: some View {
        ScrollView{
            ScrollViewReader{ proxy in
                VStack(alignment:.leading,spacing: 5){
                    Text(currentMemo.time.replacingOccurrences(of: "-", with: "."))
                        .font(.callout)
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text(currentMemo.content)
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundColor(.gray.opacity(0.9))
                        .padding(.top)
                        .multilineTextAlignment(.leading)
                        .frame(minHeight:200,alignment: .top)
                    
                    if !validationMeal(){
                        Text("식단")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.vertical)
                        
                        Group{
                            MemoMealCellView(title: "아침", meals: currentMemo.firstMeal)
                            
                            MemoMealCellView(title: "점심", meals: currentMemo.secondMeal)
                            
                            MemoMealCellView(title: "간식", meals: currentMemo.snack)
                            
                            MemoMealCellView(title: "저녁", meals: currentMemo.thirdMeal)
                        }
                        .padding(.bottom,10)
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
                    if currentMemo.isPrivate == false{
                        if viewModel.comments.isEmpty{
                            
                        }else{
                            VStack(spacing:20){
                                ForEach(viewModel.comments.sorted{ $0.time >=  $1.time }.indices,id:\.self){ index in
                                    
                                    HStack{
                                        Image("defaultImage")
                                            .resizable()
                                            .frame(width: 50, height: 50, alignment: .center)
                                            .clipShape(Circle())
                                            .background(
                                                Circle()
                                                    .stroke(backgroundColor,lineWidth: 2)
                                            )
                                        
                                        VStack{
                                            CommentLabel(name: viewModel.comments[index].writerName,
                                                         comment: viewModel.comments[index].content)
                                            
                                            HStack{
                                                Text(viewModel.comments[index].time)
                                                
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }//:VSTACK
                .padding(.horizontal)
            }//:SCROLLVIEWREADER
        }//:SCROLLVIEW
        .navigationTitle(currentMemo.title)
        .navigationBarTitleDisplayMode(.large)
        .onTapGesture {
            proxyIndex = 0
        }
        
        if currentMemo.isPrivate == false{
            VStack{
                Divider()
                
                HStack{
                    TextField("댓글 달기", text: $commentText)
                        .textFieldStyle(.plain)
                    
                    
                    Button {
                        print(123)
                    } label: {
                        Image(systemName: "paperplane.fill")
                    }
                    .buttonStyle(.plain)
                    .tint(.accentColor)

                }
                .padding([.horizontal,.bottom])
                .padding(.top,5)
            }
        }
    }
}

//struct UserDetailMemoView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDetailMemoView(currentMemo: Memo, viewModel: <#UserDetailMemoViewModel#>)
//    }
//}
