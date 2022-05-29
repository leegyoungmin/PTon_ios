//
//  userExerciseSearchView.swift
//  PTon
//
//  Created by 이경민 on 2022/05/29.
//

import SwiftUI
import InstantSearchSwiftUI


struct userExerciseSearchView: View {
    @ObservedObject var hitsController:HitsObservableController<exerciseResult>
    @ObservedObject var queryController:SearchBoxObservableController
    @ObservedObject var facetListController: FacetListObservableController
    @State var isEditing:Bool = false
    @State var isPresentSheet:Bool = false
    var body: some View {
        VStack {
            HStack{
                SearchBar(text: $queryController.query,
                          isEditing: $isEditing) {
                    queryController.submit()
                }
            }
            HitsList(hitsController) { hit, _ in
                HStack {
                    Text(hit?.engName ?? "")
                    Spacer()
                }
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentSheet = true
                } label: {
                    Text("필터")
                }

            }
        })
        .padding(.horizontal)
        .sheet(isPresented: $isPresentSheet, content: facets)
    }
    
    @ViewBuilder
    private func facets() -> some View{
        FacetList(facetListController) { facet, isSelected in
            VStack {
                FacetRow(facet: facet, isSelected: isSelected)
                Divider()
            }
        } noResults: {
            Text("No facet found")
        }
        .onAppear(perform: {
            print(facetListController.facets)
        })
    }
}

struct userExerciseSearchView_Previews: PreviewProvider {
    static let controller = ExerciseSearchController()
    static var previews: some View {
        userExerciseSearchView(hitsController: controller.hitsController, queryController: controller.queryInputController, facetListController: controller.facetListContorller)
    }
}
