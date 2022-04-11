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
        HStack(alignment: .bottom){
            
            if !currentMessage.isCurrentUser{
                
                HStack(alignment:.center){
                    
                    CircleImage(url: userProfileUrl ?? "", size: CGSize(width: 40, height: 40))
                    HStack(alignment:.bottom){
                        ContentMessageView(contentMessage: currentMessage.content, isCurrentUser: currentMessage.isCurrentUser)
                        Text(currentMessage.time)
                        Spacer()
                    }
                    .padding(.top)
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
    static var previews: some View{
        Group{
            MessageView(currentMessage: message(chatId: "asdasd", content: "asd", time: "12:00", date: "03.21", data: nil, isRead: false, isCurrentUser: false), userProfileUrl: "")
            MessageView(currentMessage: message(chatId: "", content: "asd", time: "12:00", date: "03.21", data: nil, isRead: false, isCurrentUser: true), userProfileUrl: "")
        }
        .previewLayout(.sizeThatFits)
        .rotationEffect(.degrees(-180))
        
    }
}
