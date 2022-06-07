//
//  MessageView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/10.
//

import SwiftUI
import Kingfisher

enum chattingType{
    case text
    case image
}

struct MessageView: View {
    var currentMessage:message
    let chattingType:chattingType
    let userProfileUrl:String?
    
    @ViewBuilder
    func textMessageView() -> some View{
        if currentMessage.isCurrentUser{
            ContentMessageView(contentMessage: currentMessage.content, isCurrentUser: true)
        }else{
            ContentMessageView(contentMessage: currentMessage.content, isCurrentUser: false)
        }
    }
    
    @ViewBuilder
    func ImageMessageView() -> some View{
        VStack(alignment:currentMessage.isCurrentUser ? .trailing:.leading){
            HStack{
                KFImage(URL(string: currentMessage.content))
                    .placeholder{
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight:300,alignment: currentMessage.isCurrentUser ? .trailing:.leading)
                    .cornerRadius(10)
            }
            .frame(maxWidth:300,alignment: currentMessage.isCurrentUser ? .trailing:.leading)
        }
        .frame(maxWidth:.infinity,alignment: currentMessage.isCurrentUser ? .trailing:.leading)
        .padding(currentMessage.isCurrentUser ? .trailing:.leading)
    }
    
    var body: some View {
        switch chattingType {
        case .text:
            textMessageView()
        case .image:
            ImageMessageView()
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
    하는 고동을 풍부하게 바이며, 있다. 같이, 희망의 하는 동력은 용기가 역사를 인생에 그들에게 이것이다. 인도하겠다는 때까지 있는 노래하며 아니더면, 속잎나고, 만천하의 풀이 소리다.이것은 교향악이다. 따뜻한 뛰노는 인생을 청춘의 이상, 두기 우리는 칼이다. 위하여 고행을 품으며, 사라지지 교향악이다. 우리 살 끓는 것이 이상 소금이라 구하지 사람은 있다. 이상은 청춘은 같이, 끓는 부패뿐이다. 속에서 원대하고, 고행을 기관과 하는 힘차게 위하여서, 싹이 부패뿐이다. 실로 힘차게 이것이야말로 대중을 위하여 시들어 바이며, 봄바람이다.

    이 귀는 날카로우나 피부가 것은 위하여, 그들의 보라. 용감하고 인간에 기관과 튼튼하며, 인생의 아름다우냐? 예수는 우리 이상의 착목한는 현저하게 있는 이상이 인간의 것이다. 무엇이 들어 오직 보내는 얼마나 창공에 끓는 열락의 풀이 교향악이다. 날카로우나 품에 충분히 위하여 예수는 못하다 인생에 위하여서. 같지 보이는 밝은 위하여, 피부가 오직 웅대한 뿐이다. 무한한 창공에 피부가 그들은 사라지지 쓸쓸하랴? 커다란 것은 방지하는 그들의 끓는다. 피고 노년에게서 맺어, 커다란 밝은 열락의 아니한 약동하다. 끓는 속에서 수 풍부하게 있는 인생을 창공에 이것이다. 보는 구할 풀이 싸인 것이다.보라, 그것은 용감하고 교향악이다.

    모래뿐일 것은 위하여, 우는 그들을 실로 새가 수 평화스러운 것이다. 봄바람을 군영과 싸인 황금시대를 따뜻한 장식하는 같은 많이 사막이다. 아름답고 있으며, 품으며, 속잎나고, 꽃이 있으랴? 끓는 용기가 그것을 자신과 꾸며 온갖 대중을 그것은 사막이다. 목숨을 되려니와, 가장 위하여, 약동하다. 이 피고, 만천하의 능히 그들의 있는 것이다. 옷을 가지에 구하기 굳세게 말이다. 우리는 하여도 위하여 가는 구하기 따뜻한 있다. 청춘을 간에 밥을 가장 내는 끓는다. 길지 피고, 그것은 그들을 동산에는 피가 우는 봄날의 수 교향악이다. 가슴에 그러므로 청춘의 풍부하게 천고에 이상을 열락의 타오르고 봄바람이다.
"""
    static var userMessageUrl:String = "https://firebasestorage.googleapis.com:443/v0/b/pton-1ffc0.appspot.com/o/ChatsImage%2F000001%2F3yvE0bnUEHbvDKasU1Orf7DhvjX2%2Fkakao:1967260938%2FChatsImage_2022_06_07_10_58_52?alt=media&token=df0c8fb0-dc9e-4422-8489-0abcb0d7e133"
    static var previews: some View{
        Group{
            MessageView(currentMessage: message(chatId: "asd", content: userMessage, time: "12:10", date: "2022.10.20", isRead: false, isCurrentUser: true), chattingType: .text, userProfileUrl: "")
            
            MessageView(currentMessage: message(chatId: "asd", content: userMessage, time: "12:10", date: "2022.10.20", isRead: false, isCurrentUser: false), chattingType: .text, userProfileUrl: "")
            
            MessageView(currentMessage: message(chatId: "asd", content: userMessageUrl, time: "12:10", date: "2022.10.12", isRead: false, isCurrentUser: false), chattingType: .image, userProfileUrl: "")
            
            MessageView(currentMessage: message(chatId: "asd", content: userMessageUrl, time: "12:10", date: "2022.10.12", isRead: false, isCurrentUser: true), chattingType: .image, userProfileUrl: "")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
