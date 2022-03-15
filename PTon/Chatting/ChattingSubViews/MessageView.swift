//
//  MessageView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/10.
//

import SwiftUI

struct MessageView: View {
    var currentMessage:Message
    var body: some View {
        HStack(alignment: .bottom){

            if !currentMessage.user.isCurrentUser{
                HStack(alignment:.bottom){
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(20)
                    ContentMessageView(contentMessage: currentMessage.content, isCurrentUser: currentMessage.user.isCurrentUser)
                    Text(currentMessage.time)
                    Spacer()
                }
            }
            else{
                Text(currentMessage.time)
                ContentMessageView(contentMessage: currentMessage.content, isCurrentUser: currentMessage.user.isCurrentUser)
            }
        }
        .rotationEffect(.radians(.pi))
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            MessageView(currentMessage: Message(content: "example_1", time: "12:00", date: "12-01", user: ChattingUser(name: "이경민1", isCurrentUser: false)))
            MessageView(currentMessage: Message(content: "example_1", time: "12:00", date: "12-01", user: ChattingUser(name: "이경민2", isCurrentUser: true)))
        }
        .previewLayout(.sizeThatFits)
        
    }
}
