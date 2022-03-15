//
//  StretchingView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/16.
//

import SwiftUI

struct StretchingView: View {
    @Binding var type:StretchingType
    var trainerid:String
    var userid:String
    var body: some View {
        if type == .request{
            RequestedStretchingView(viewmodel: RequestStretchingViewModel(trainerid: self.trainerid, userid: self.userid))
        }else{
            AllStretchingView()
        }
    }
}

struct StretchingView_Previews: PreviewProvider {
    static var previews: some View {
        StretchingView(type: .constant(.request),trainerid: "asjnd",userid: "asndkj")
    }
}
