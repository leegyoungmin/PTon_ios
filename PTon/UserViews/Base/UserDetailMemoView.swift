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
                                ForEach(viewModel.comments.indices,id:\.self){ index in
                                    UserMemoCommentView(comment: viewModel.comments[index])
                                        .environmentObject(self.viewModel)
                                        .onAppear {
                                            viewModel.changeUnread(index)
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
                        let data = viewModel.makeInputData(content: commentText)
                        viewModel.uploadComment(data: data)
                        self.commentText = ""
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

struct UserMemoCommentView:View{
    @EnvironmentObject var viewModel:UserDetailMemoViewModel
    let comment:comment
    @State var stringTime:String = ""
    
    var body: some View{

        HStack{
            Image("defaultImage")
                .resizable()
                .frame(width: 50, height: 50, alignment: .center)
                .clipShape(Circle())
                .background(
                    Circle()
                        .stroke(backgroundColor,lineWidth: 2)
                )
            
            VStack(alignment:.leading,spacing: 5){
                CommentLabel(name: comment.writerName, comment: comment.content)
                
                HStack{
                    Text(stringTime)
                        .onAppear {
                            viewModel.caculateDate(comment) { stringTime in
                                self.stringTime = stringTime
                            }
                        }
                    
                    if viewModel.userId == comment.writerId{
                        Button {
                            viewModel.deleteComment(comment: comment)
                        } label: {
                            Text("삭제하기")
                                .foregroundColor(.red)
                        }

                    }
                }
                .font(.footnote)
            }
            
            Spacer()
            
            Button {
                self.viewModel.toggleLike(comment: comment)
            } label: {
                Image(systemName: comment.isLike ? "heart.fill":"heart")
            }
            .disabled(viewModel.userId == comment.writerId)

        }
        
    }
    
    @ViewBuilder
    private func CommentLabel(name:String,comment:String)->some View{
        Text(name).fontWeight(.semibold) + Text("  ") + Text(comment).font(.footnote)
    }
}

extension UserDetailMemoViewModel{
    func caculateDate(_ comment:comment,completion:@escaping(String)->Void){
        let dates = comment.time.components(separatedBy: ["-",":"," "])
        
        guard let year = Int(dates[0]),
              let month = Int(dates[1]),
              let day = Int(dates[2]),
              let hour = Int(dates[3]),
              let minute = Int(dates[4]) else {return}
        
        
        let calendar = Calendar(identifier: .gregorian)
        let comp = DateComponents(year:year,month: month,day: day,hour: hour,minute: minute)
        
        if let startDate = calendar.date(from: comp){
            let offsetComps = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: startDate, to: Date())
            if case let (y?,m?,d?,h?,minute?) = (offsetComps.year,offsetComps.month,offsetComps.day,offsetComps.hour,offsetComps.minute){
                
                if y > 0{
                    completion("\(y)년 전")
                }else if m > 0{
                    completion("\(m)달 전")
                }else if d > 0{
                    completion("\(d)일 전")
                }else if h > 0{
                    completion("\(h)시간 전")
                }else if minute > 0{
                    completion("\(minute)분 전")
                }else if minute == 0{
                    completion("지금")
                }
                
            }
        }
    }
}
