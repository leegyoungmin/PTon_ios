//
//  PublicMemoView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/16.
//

import SwiftUI

struct DetailMemoView: View {
    //MARK: - PROPERTIES
    @Environment(\.editMode) private var editMode
    @StateObject var viewmodel:DetailMemoViewModel
    @State var commentText:String = ""
    @State var proxyIndex:Int = 0
    @State var currentMemo:Memo
    @State var isModify:Bool = false
    
    //식단 empty 처리 함수
    func validationMeal() -> Bool{
        return (self.currentMemo.firstMeal.isEmpty ?? true) && (self.currentMemo.secondMeal.isEmpty ?? true) && (self.currentMemo.thirdMeal.isEmpty ?? true)
    }
    
    //MARK: - VIEW
    var body: some View {
        VStack(spacing:0) {
            
            if editMode?.wrappedValue.isEditing == false{
                ScrollView {
                    ScrollViewReader { proxy in
                        VStack(alignment:.leading,spacing:5){
                            
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
                            
                            
                            
                            //MARK: FOOD SECTION
                            if !validationMeal(){
                                Text("식단")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .padding(.vertical)
                                
                                MemoMealCellView(title:"아침",meals: currentMemo.firstMeal)
                                
                                MemoMealCellView(title:"점심",meals: currentMemo.secondMeal)
                                
                                MemoMealCellView(title:"저녁",meals: currentMemo.thirdMeal)
                               
                            }
                            
                            Divider()
                                .padding(.vertical)
                            
                            if currentMemo.isPrivate == false{
                                //MARK: - COMMENT SECTION
                                //comment List에 대한 분기처리
                                if !viewmodel.commentList.isEmpty{
                                    VStack(spacing:20){
                                        ForEach(viewmodel.commentList.sorted(by: {$0.time >= $1.time}).indices,id:\.self) { index in
                                            MemoCommentCellView(comment: viewmodel.commentList[index])
                                                .id(index)
                                                .environmentObject(self.viewmodel)
                                        }
                                        
                                    }
                                    .padding(.bottom)
                                    
                                }else{
                                    VStack{
                                        Text("아직 작성된 댓글이 없습니다.")
                                    }
                                    .padding(.bottom)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .onChange(of: proxyIndex) { newValue in
                            //proxy index 변경처리를 통한 스크롤 컨트롤
                            withAnimation {
                                if newValue == 0{
                                    UIApplication.shared.endEditing()
                                }else{
                                    proxy.scrollTo(newValue, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(currentMemo.title)
                .navigationBarTitleDisplayMode(.large)
                .onTapGesture {
                    proxyIndex = 0
                }
                
                if currentMemo.isPrivate == false{
                    //MARK: - 댓글 작성
                    VStack{
                        Divider()
                        
                        HStack{
                            
                            TextField("댓글 달기", text: $commentText)
                                .textFieldStyle(.plain)
                                .onTapGesture {
                                    proxyIndex = viewmodel.commentList.count - 1
                                }
                            
                            Button {
                                DispatchQueue.main.async {
                                    viewmodel.setCommentData(commentText)
                                    commentText = ""
                                }
                            } label: {
                                Image(systemName: "paperplane.fill")
                            }
                            .buttonStyle(.plain)
                            .tint(Color.accentColor)
                            
                        }
                        .padding([.horizontal,.bottom])
                        .padding(.top,5)
                        
                    }
                }
                
                
            }else{
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0){
                        Text(currentMemo.time.replacingOccurrences(of: "-", with: "."))
                            .font(.callout)
                            .foregroundColor(.gray.opacity(0.5))
                        
                        TextEditor(text: $currentMemo.content)
                            .font(.body)
                            .padding(.top)
                            .multilineTextAlignment(.leading)
                            .frame(minHeight:200,alignment: .top)
                        
                        Text("식단")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.vertical)
                        
                        mealEditCell(mealType: "아침", meals: $currentMemo.firstMeal)
                            .padding(.bottom)
                        
                        mealEditCell(mealType: "점심",meals: $currentMemo.secondMeal)
                            .padding(.bottom)
                        
                        mealEditCell(mealType: "저녁", meals: $currentMemo.thirdMeal)
                            .padding(.bottom)
                        
                    }
                    .padding(.horizontal)
                    .navigationTitle(currentMemo.title)
                    .navigationBarTitleDisplayMode(.large)
                    .onTapGesture {
                        withAnimation {
                            UIApplication.shared.endEditing()
                        }
                    }
                }
            }
            
            
        }
        .onDisappear {
            viewmodel.viewDisapper(data: currentMemo)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .tint(Color.accentColor)
                
            }
           
        }
        .onChange(of: editMode?.wrappedValue.isEditing) { newValue in
            if newValue == false{
                self.currentMemo.firstMeal.removeAll{$0 == ""}
                self.currentMemo.secondMeal.removeAll{$0 == ""}
                self.currentMemo.thirdMeal.removeAll{$0 == ""}
            }
        }
    }
}
struct mealEditCell:View{
    let mealType:String
    @Binding var meals:[String]
    var body: some View{
        VStack(alignment: .leading,spacing:10){
            Text(mealType)
                .font(.title2)
                .fontWeight(.semibold)
            
            ForEach(meals.indices,id: \.self) { index in
                HStack{
                    TextField("", text: $meals[index])
                    
                    Spacer()
                    
                    Button {
                        meals.remove(at: index)
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }
                .padding(10)
                .background(Color("Background"))
                .cornerRadius(10)
            }
            
            Button {
                meals.append("")
            } label: {
                HStack{
                    Spacer()
                    
                    Label {
                        Text("추가하기")
                    } icon: {
                        Image(systemName: "plus")
                    }
                    
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .padding(10)
            .background(Color("Background"))
            .cornerRadius(10)

        }
        .padding(.horizontal)
    }
}

//MARK: - 댓글 셀 뷰
struct MemoCommentCellView:View{
    @EnvironmentObject var viewModel:DetailMemoViewModel
    let comment:comment
    @State var stringTime:String = ""
    var body: some View{
        HStack{
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 50, height: 50, alignment: .center)
                .clipShape(Circle())
            
            VStack(alignment:.leading,spacing:5){
                CommentLabel(name: comment.writerName, comment: comment.content)
                
                HStack{
                    //MARK: - 댓글 작성 시간 및 현재 시간 비교 후 일수 및 시간 작성
                    Text(stringTime)
                        .onAppear {
                            viewModel.caculateDate(comment, completion: { stringTime in
                                self.stringTime = stringTime
                            })
                        }
                    
                    if viewModel.isWriter(comment.writerId){
                        Button {
                            viewModel.deleteData(comment: comment)
                        } label: {
                            Text("삭제하기")
                                .foregroundColor(.red)
                        }
                    }
                }
                .font(.footnote)
            }
            //MARK: - 댓글 더보기
            
            Spacer()
            
            Button {
                viewModel.toggleLike(comment: comment)
            } label: {
                Image(systemName: comment.isLike ? "heart.fill":"heart")
            }
            .disabled(viewModel.isWriter(comment.writerId))
            
        }
    }
    
    @ViewBuilder
    func CommentLabel(name:String,comment:String)->some View{
        Text(name).fontWeight(.semibold) + Text("  ") + Text(comment).font(.footnote)
    }
}

//MARK: - 메모 식사 셀 뷰
struct MemoMealCellView:View{
    let title:String
    let meals:[String]
    let gridItemLayout = Array(repeating: GridItem(.flexible(),spacing: 10), count: 2)
    var body: some View{
        
        if meals.count > 1{
            DisclosureGroup {
                LazyVGrid(columns: gridItemLayout, alignment: .leading,spacing: 10) {
                    ForEach(meals.indices,id:\.self) { index in
                        Text(meals[index])
                            .lineLimit(1)
                    }
                }
            } label: {
                Text(title)
            }
            .padding()
            .background(Color("Background"))
            .cornerRadius(10)
            .tint(Color.accentColor)
            
        }else if meals.count == 1{
            HStack{
                Text(title)
                    .foregroundColor(.accentColor)
                Spacer()
                Text(meals.first!)
            }
            .padding()
            .background(Color("Background"))
            .cornerRadius(10)
        }else{
            EmptyView()
        }
    }
}

//MARK: - PREVIEWS
struct PublicMemoView_Previews: PreviewProvider {
    static var viewModel = DetailMemoViewModel(userId: "asd", userName: "asd", trainerId: "asd", trainerName: "asd", memoId: "asd")
    static var previews: some View {
        //        PublicMemoView(viewmodel: viewModel, currentMemo:
        //                    Memo(
        //                        uuid: UUID().uuidString,
        //                        title: "Example_1",
        //                        content: "없이 불러 애기 가슴속에 않은 부끄러운 오면 이네들은 지나고 까닭입니다. 위에도 못 이름과, 파란 프랑시스 하나에 이제 별 있습니다. 이름을 때 언덕 옥 동경과 불러 이름자 토끼, 별에도 있습니다. 사람들의 하나 나는 북간도에 내일 헤일 청춘이 있습니다. 이웃 내 그리고 자랑처럼 봄이 시와 오는 별 봅니다. 덮어 애기 오는 다하지 위에 사랑과 까닭이요, 많은 까닭입니다. 다 풀이 써 별이 같이 된 아름다운 했던 까닭입니다. 멀리 잠, 애기 내린 까닭이요, 라이너 있습니다. 노루, 이름을 풀이 때 계십니다. 하나의 벌써 아스라히 둘 같이 것은 어머니, 계절이 가을 봅니다. 애기 노새, 걱정도 버리었습니다.",
        //                        time: convertString(content: Date(), dateFormat: "yyyy.MM.dd HH:mm"),
        //                        isPrivate: false,
        //                        firstMeal: ["고구마/바나나 2개","닭가슴살 100g","샐러드"],
        //                        secondMeal: ["일반식"],
        //                        thirdMeal: nil)
        //        )
        //        .onAppear {
        //            viewModel.commentList = [comment(writerId: "example", writerName: "이경민", content: "없이 불러 애기 가슴속에 않은 부끄러운 오면 이네들은 지나고 까닭입니다. 위에도 못 이름과, 파란 프랑시스 하나에 이제 별 있습니다. 이름을 때 언덕 옥 동경과 불러 이름자 토끼, 별에도 있습니다. 사람들의 하나 나는 북간도에 내일 헤일 청춘이 있습니다. 이웃 내 그리고 자랑처럼 봄이 시와 오는 별 봅니다. 덮어 애기 오는 다하지 위에 사랑과 까닭이요, 많은 까닭입니다. 다 풀이 써 별이 같이 된 아름다운 했던 까닭입니다. 멀리 잠, 애기 내린 까닭이요, 라이너 있습니다. 노루, 이름을 풀이 때 계십니다. 하나의 벌써 아스라히 둘 같이 것은 어머니, 계절이 가을 봅니다. 애기 노새, 걱정도 버리었습니다.", time: "12:00", isLike: false)]
        //        }
        
        //        MemoCommentCellView(comment: comment(writerId: "example", writerName: "이경민", content: "없이 불러 애기 가슴속에 않은 부끄러운 오면 이네들은 지나고 까닭입니다. 위에도 못 이름과, 파란 프랑시스 하나에 이제 별 있습니다. 이름을 때 언덕 옥 동경과 불러 이름자 토끼, 별에도 있습니다. 사람들의 하나 나는 북간도에 내일 헤일 청춘이 있습니다. 이웃 내 그리고 자랑처럼 봄이 시와 오는 별 봅니다. 덮어 애기 오는 다하지 위에 사랑과 까닭이요, 많은 까닭입니다. 다 풀이 써 별이 같이 된 아름다운 했던 까닭입니다. 멀리 잠, 애기 내린 까닭이요, 라이너 있습니다. 노루, 이름을 풀이 때 계십니다. 하나의 벌써 아스라히 둘 같이 것은 어머니, 계절이 가을 봅니다. 애기 노새, 걱정도 버리었습니다.", time: "12:00", isLike: false))
        //            .environmentObject(viewModel)
        //            .previewLayout(.sizeThatFits)
        
        mealEditCell(mealType: "아침", meals: .constant(["eaxmple1"]))
    }
}

extension DetailMemoViewModel{
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
                print(minute)
                
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
