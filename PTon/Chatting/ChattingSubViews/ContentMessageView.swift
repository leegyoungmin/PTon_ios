//
//  ContentMessageView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/10.
//

import SwiftUI

struct ContentMessageView: View {
    var contentMessage:String
    var isCurrentUser:Bool
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing:.leading){
            HStack{
                Text(contentMessage)
                    .foregroundColor(isCurrentUser ? .white:.black)
                    .font(.system(size: 15))
                    .padding(10)
                    .background(isCurrentUser ? Color.accentColor:Color(UIColor.secondarySystemFill))
                    .cornerRadius(20)
            }
            .frame(maxWidth:300,alignment: isCurrentUser ? .trailing:.leading)
        }
        .frame(maxWidth:.infinity,alignment: isCurrentUser ? .trailing:.leading)
        .padding(isCurrentUser ? .trailing:.leading)

    }
}

struct ContentMessageView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ContentMessageView(contentMessage: "무성할 잠, 이런 소학교 청춘이 책상을 봅니다. 하나에 한 별에도 이제 아직 내 까닭입니다. 위에 언덕 별 멀리 그리고 다 하나에 듯합니다. 남은 파란 청춘이 라이너 계십니다. 차 패, 토끼, 가득 계집애들의 계십니다.", isCurrentUser: true)
            ContentMessageView(contentMessage: "무성할 잠, 이런 소학교 청춘이 책상을 봅니다. 하나에 한 별에도 이제 아직 내 까닭입니다. 위에 언덕 별 멀리 그리고 다 하나에 듯합니다. 남은 파란 청춘이 라이너 계십니다. 차 패, 토끼, 가득 계집애들의 계십니다.", isCurrentUser: false)
        }
        .previewLayout(.sizeThatFits)
//        .padding()

        
    }
}

struct RoundedCorner:Shape{
    var radius:CGFloat = .infinity
    var corners:UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View{
    func cornerRadius(_ radius:CGFloat,corners:UIRectCorner) -> some View{
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
