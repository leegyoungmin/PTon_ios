//
//  MemoListViewModel.swift
//  PTon
//
//  Created by 이경민 on 2022/03/15.
//

import Foundation


class MemoListViewModel:ObservableObject{
    @Published var memos:[memo] = []
    
}
