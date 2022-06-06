//
//  MessageView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/10.
//

import SwiftUI
import Kingfisher

struct MessageView: View {
    var currentMessage:message
    let userProfileUrl:String?
    var body: some View {
        HStack{
            if currentMessage.isCurrentUser{
                Spacer()
                ContentMessageView(contentMessage: currentMessage.content, isCurrentUser: true)
            }else{
                ContentMessageView(contentMessage: currentMessage.content, isCurrentUser: false)
                Spacer()
            }
        }
    }
}
struct noTimeMessageView:View{
    var currentMessage:message
    var body: some View{
        if !currentMessage.isCurrentUser{
            HStack(alignment:.bottom){
                ContentMessageView(contentMessage: currentMessage.content, isCurrentUser: currentMessage.isCurrentUser)
                Text(currentMessage.time)
                Spacer()
            }
        }else{
            Spacer()
            Text(currentMessage.time)
            ContentMessageView(contentMessage: currentMessage.content, isCurrentUser: currentMessage.isCurrentUser)
        }
    }
}

struct MessageView_previews:PreviewProvider{
    static var userMessage:String = """
이
"""
    static var previews: some View{
        Group{
            MessageView(currentMessage: message(chatId: "asd", content: userMessage, time: "12:10", date: "2022.10.20", isRead: false, isCurrentUser: true), userProfileUrl: "")
            
            MessageView(currentMessage: message(chatId: "asd", content: userMessage, time: "12:10", date: "2022.10.20", isRead: false, isCurrentUser: false), userProfileUrl: "")
        }
        .padding()
    }
}
