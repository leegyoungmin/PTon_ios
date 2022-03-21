//
//  MessageView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/10.
//

import SwiftUI

struct MessageView: View {
    var currentMessage:message
    var body: some View {
        HStack(alignment: .bottom){

            if !currentMessage.isCurrentUser{
                HStack(alignment:.bottom){
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(20)
                    ContentMessageView(contentMessage: currentMessage.content, isCurrentUser: currentMessage.isCurrentUser)
                    Text(currentMessage.time)
                    Spacer()
                }
            }
            else{
                Spacer()
                Text(currentMessage.time)
                ContentMessageView(contentMessage: currentMessage.content, isCurrentUser: currentMessage.isCurrentUser)
            }
        }
    }
}

struct MessageView_previews:PreviewProvider{
    static var previews: some View{
        Group{
            MessageView(currentMessage: message(content: "asd", time: "12:00", date: "03.21", data: nil, isRead: false, isCurrentUser: false))
            MessageView(currentMessage: message(content: "asd", time: "12:00", date: "03.21", data: nil, isRead: false, isCurrentUser: true))
        }
        .previewLayout(.sizeThatFits)

    }
}
