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


struct GoogleButton:UIViewRepresentable{
    private var button = GIDSignInButton()
    
    func makeUIView(context: Context) -> some UIView {
        button.colorScheme = .light
        return button
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        button.colorScheme = .light
    }
}

final class AppleLogin:UIViewRepresentable{
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton()
    }
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
}
