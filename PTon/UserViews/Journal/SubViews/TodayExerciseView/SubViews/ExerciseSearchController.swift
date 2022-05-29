//
//  ExerciseSearchController.swift
//  PTon
//
//  Created by 이경민 on 2022/05/29.
//

import Foundation
import InstantSearchCore
import InstantSearchSwiftUI

struct exerciseResult:Codable{
    var exerciseName:String
    var part:String
    var hydro:String
    var engName:String
    var parameter:Double
    var url:String
    
    enum CodingKeys:String,CodingKey{
        case exerciseName
        case part
        case hydro
        case engName = "EngLabel"
        case parameter
        case url
    }
}

class ExerciseSearchController{
    let searcher: HitsSearcher

    let searchBoxInteractor: SearchBoxInteractor
    let searchBoxController: SearchBoxObservableController

    let hitsInteractor: HitsInteractor<exerciseResult>
    let hitsController: HitsObservableController<exerciseResult>

    let statsInteractor: StatsInteractor
    let statsController: StatsObservableController

    let filterState: FilterState
    
    let facetListInteractor: FacetListInteractor
    let facetListController: FacetListObservableController

    init() {
      self.searcher = HitsSearcher(appID: "latency",
                                   apiKey: "1f6fd3a6fb973cb08419fe7d288fa4db",
                                   indexName: "CommonExercise")
      self.searchBoxInteractor = .init()
      self.searchBoxController = .init()
      self.hitsInteractor = .init()
      self.hitsController = .init()
      self.statsInteractor = .init()
      self.statsController = .init()
      self.filterState = .init()
      self.facetListInteractor = .init()
      self.facetListController = .init()
      setupConnections()
    }
    
    func setupConnections() {
      searchBoxInteractor.connectSearcher(searcher)
      searchBoxInteractor.connectController(searchBoxController)
      hitsInteractor.connectSearcher(searcher)
      hitsInteractor.connectController(hitsController)
      statsInteractor.connectSearcher(searcher)
//      statsInteractor.connectController(statsController)
      searcher.connectFilterState(filterState)
      facetListInteractor.connectSearcher(searcher, with: "part")
      facetListInteractor.connectFilterState(filterState, with: "part", operator: .or)
      facetListInteractor.connectController(facetListController, with: FacetListPresenter(sortBy: [.isRefined, .count(order: .descending)]))
    }
        
}
