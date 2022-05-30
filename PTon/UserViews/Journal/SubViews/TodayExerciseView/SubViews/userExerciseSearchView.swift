//
//  userExerciseSearchView.swift
//  PTon
//
//  Created by 이경민 on 2022/05/29.
//

import SwiftUI
import InstantSearchCore
import InstantSearchSwiftUI
import Kingfisher

struct userExerciseSearchView: View {
    @ObservedObject var hitsController:HitsObservableController<exerciseResult>
    @ObservedObject var queryController:SearchBoxObservableController
    @ObservedObject var facetListController: FacetListObservableController
    
    @State var isEditing:Bool = false
    @State var isPresentSheet:Bool = false
    var body: some View {
        ZStack{
            //1. 검색 뷰
            VStack {
                //검색 결과 뷰
                HitsList(hitsController) { hit, _ in
                    //TODO: - 데이터 생성 뷰 변경
                    NavigationLink {
                        Text(hit?.engName ?? "")
                    } label: {
                        HStack(spacing:10){
                            KFImage(URL(string: hit?.url ?? ""))
                                .onFailureImage(KFCrossPlatformImage(named: "defaultImage"))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 70, alignment: .center)
                                .clipped()
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke()
                                )
                                .padding(1)
                            
                            VStack(alignment:.leading,spacing:5) {
                                
                                Text(hit?.part ?? "")
                                    .font(.caption)
                                    .fontWeight(.thin)
                                
                                Text(hit?.exerciseName ?? "")
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                
                                Text(hit?.engName ?? "")
                                    .font(.footnote)
                                    .fontWeight(.light)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.leading)
                                    .minimumScaleFactor(0.5)
                                
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .opacity(0.5)
                            
                        }
                    }
                }
                
            }//:HITSLIST
            .padding(.horizontal)
            .disabled(isPresentSheet)
            
            //2. 필터 뷰
            if isPresentSheet{
                facets()
            }
        }//:ZSTACK
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("운동 검색하기")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        isPresentSheet = true
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }//:TOOLBAR
        .searchable(text: $queryController.query, placement: .navigationBarDrawer(displayMode: .always))
    }
    
    
    @ViewBuilder
    func facets() -> some View{
        VStack{
            HStack(spacing:0){
                Text("필터 지정")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.vertical,5)
            
            FacetList(facetListController) { facet, isSelected in
                FacetRow(facet: facet, isSelected: isSelected)
                    .padding(.vertical,10)
            } noResults: {
                Text("No facet found")
            }
            
            Button {
                isPresentSheet = false
            } label: {
                Text("저장")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth:UIScreen.main.bounds.width)
                    .padding(10)
                    .background(.white)
                    .cornerRadius(20)
            }
            .buttonStyle(.plain)

        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(20)
        .padding()
    }
}

struct userExerciseSearchView_Previews: PreviewProvider {
    static let controller = ExerciseSearchController()
    static let view = userExerciseSearchView(hitsController: controller.hitsController,
                                             queryController: controller.searchBoxController,
                                             facetListController: controller.facetListController)
    static var previews: some View {
        Group{
            NavigationView{
                view
            }


            view.facets().previewLayout(.sizeThatFits)
        }

    }
}
