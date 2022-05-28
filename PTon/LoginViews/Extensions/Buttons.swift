//
//  GoogleButton.swift
//  PTon
//
//  Created by 이경민 on 2022/02/04.
//

import Foundation
import SwiftUI
import GoogleSignIn
import AuthenticationServices

struct GoogleShape:View{
    var body: some View{
        HStack(spacing:0){
            Image("g-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .padding(.leading,8)
            
            Text("구글 계정으로 계속하기")
                .padding(.horizontal,24)
        }
        .frame(width: 300, height: 50, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray.opacity(0.5),lineWidth: 2)
        )
    }
}

struct AppleShape:View{
    var body: some View{
        HStack(spacing:0){
            Image("a-logo")
            
            Text("애플 계정으로 계속하기")
                .padding(.horizontal,24)
                .foregroundColor(.white)
        }
        .frame(width: 300, height: 50, alignment: .center)
        .background(.black)
        .cornerRadius(10)
            
    }
}

struct kakaoShape:View{
    var body: some View{
        HStack(spacing:0){
            Image("k-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30, alignment: .center)
            
            Text("카카오 계정으로 계속하기")
                .padding(.horizontal,24)
                .foregroundColor(.black)
        }
        .frame(width: 300, height: 50, alignment: .center)
        .background(Color(red: 254/255, green: 229/255, blue: 0))
        .cornerRadius(10)
    }
}

final class AppleLogin:UIViewRepresentable{
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton()
    }
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
}

struct LoginButtons_previews:PreviewProvider{
    static var previews: some View{
        Group {
            GoogleShape()
            AppleShape()
            kakaoShape()
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
