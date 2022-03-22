//
//  MessageView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/10.
//

import SwiftUI

struct MessageView: View {
    var currentMessage:message
    let userProfileUrl:String?
    var body: some View {
        HStack(alignment: .bottom){

            if !currentMessage.isCurrentUser{
                HStack(alignment:.bottom){
                    URLImageView(urlString: userProfileUrl, imageSize: 50, youtube: false)
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
        .rotationEffect(.degrees(-180))
    }
}

struct MessageView_previews:PreviewProvider{
    static var previews: some View{
        Group{
//            MessageView(currentMessage: message(chatId: "", content: "asd", time: "12:00", date: "03.21", data: nil, isRead: false, isCurrentUser: false))
//            MessageView(currentMessage: message(chatId: "", content: "asd", time: "12:00", date: "03.21", data: nil, isRead: false, isCurrentUser: true))
        }
        .previewLayout(.sizeThatFits)

    }
}
