//
//  MealSearchView.swift
//  PTon
//
//  Created by 이경민 on 2022/05/20.
//

import SwiftUI
import InstantSearchSwiftUI
import InstantSearchCore

struct MealSearchView: View {
    @ObservedObject var queryInputController:QueryInputObservableController
    @ObservedObject var hitsController:HitsObservableController<foodResult>
    @State private var isEditing = false
    
    var body: some View {
        VStack{
            HitsList(hitsController) { hit, _ in
                NavigationLink {
                    foodRecordView(selectedFood: hit)
                } label: {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack{
                            
                            VStack(alignment: .leading, spacing: 0){
                                Text(hit?.manufacture ?? "")
                                    .font(.callout)
                                
                                Text(hit?.foodname ?? "")
                                    .font(.body)
                                    .foregroundColor(.accentColor)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.callout)
                        }

                        
                        Divider()
                    }
                    .padding(.horizontal,15)
                }
                .buttonStyle(.plain)
            } noResults: {
                if queryInputController.query.isEmpty{
                    Text("검색어를 입력해주세요.")
                }else{
                    Text("검색된 결과가 없습니다.")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $queryInputController.query, placement: .navigationBarDrawer(displayMode: .always))
    }
}

struct foodRecordView:View{
    let selectedFood:foodResult?
    @State var inputValue:String = ""
    var body: some View{
        VStack(alignment:.leading){
            HStack{
                // 1. 사진 추가 버튼
                Button {
                    print(123)
                } label: {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 100, height: 100, alignment: .center)
                        .foregroundColor(Color(UIColor.secondarySystemFill))
                        .overlay(
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                        )
                }
                .buttonStyle(.plain)
                
                // 2. 음식 이름 및 인분 데이터
                VStack(alignment:.leading,spacing: 5){
                    Text(selectedFood?.foodname ?? "")
                        .font(.title)
                        .fontWeight(.heavy)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    HStack{
                        TextField("", text: $inputValue)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                        Text("인분")
                    }//:HSTACK
                }//:VSTACK
                
                Spacer()
            }//:HSTACK
            .padding(.horizontal)
            
            // 3. Kcal 그래프 타이틀
            VStack(alignment:.leading,spacing: 5){
                
                Text("음식 영양정보")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Rectangle()
                    .fill(.black)
                    .frame(height: 1)
                    .padding(.bottom)
            
            }//:VSTACK
            .padding(.horizontal)
            .padding(.top)
            
            DisclosureGroup {
                Text("Example")
            } label: {
                HStack{
                    Text("Kcal 정보")
                    Spacer()
                    Text("\(Int(selectedFood?.kcal ?? 0)) ")
                        .font(.title2)
                        .fontWeight(.bold)+Text("Kcal").foregroundColor(.secondary).font(.footnote)
                }
            }
            .padding()

            
            Spacer()
        }//:VSTACK
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    print(123)
                } label: {
                    Text("음식 추가")
                        .font(.system(size: 15))
                        .foregroundColor(.accentColor)
                }

            }
        }//:TOOLBAR
    }
}

//struct MealSearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealSearchView()
//    }
//}
