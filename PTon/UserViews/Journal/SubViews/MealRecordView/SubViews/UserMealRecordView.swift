//
//  UserMealRecordView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/24.
//

import SwiftUI

struct UserMealRecordView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack{
            Button {
                dismiss.callAsFunction()
            } label: {
                Text("Dismiss")
            }

        }
    }
}

struct UserMealRecordView_Previews: PreviewProvider {
    static var previews: some View {
        UserMealRecordView()
    }
}
