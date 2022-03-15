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
        Text(contentMessage)
            .font(.system(size: 13))
            .padding(10)
            .foregroundColor(isCurrentUser ? .white:.black)
            .background(isCurrentUser ? Color.accentColor:.gray.opacity(0.5))
            .cornerRadius(5, corners: isCurrentUser ? [.topLeft,.bottomLeft,.bottomRight]:[.topRight,.bottomLeft,.bottomRight])
    }
}

struct ContentMessageView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ContentMessageView(contentMessage: "example message", isCurrentUser: true)
            ContentMessageView(contentMessage: "example message", isCurrentUser: false)
        }
        .previewLayout(.sizeThatFits)

        
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
