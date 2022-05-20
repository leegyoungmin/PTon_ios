//
//  searchModel+mealSearchViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/05/20.
//

import Foundation
import InstantSearchSwiftUI
import InstantSearchCore

struct foodResult:Codable{
    var foodname:String
    var manufacture:String
    var intake:Double
    var kcal:Double
    var protein:Double
    var fat:Double
    var carbs:Double
    var sodium:Double
}

class AlgoliaController{
    let searcher:HitsSearcher
    
    let queryInputInteractor:QueryInputInteractor
    let queryInputController:QueryInputObservableController
    
    let hitsInteractor:HitsInteractor<foodResult>
    let hitsController: HitsObservableController<foodResult>
    
    init(){
        self.searcher = HitsSearcher(appID: "ZYD60NFWI1", apiKey: "3b7be953c85e84f564b6fd9e4f365d75", indexName: "food")
        self.queryInputController = .init()
        self.queryInputInteractor = .init()
        
        self.hitsController = .init()
        self.hitsInteractor = .init()
        
        setupConnections()
    }
    
    func setupConnections(){
        queryInputInteractor.connectSearcher(searcher)
        queryInputInteractor.connectController(queryInputController)
        hitsInteractor.connectSearcher(searcher)
        hitsInteractor.connectController(hitsController)
    }
}
