//
//  NavigationBarColor.swift
//  PTon
//
//  Created by 이경민 on 2022/02/09.
//

import Foundation
import SwiftUI

struct NavigationBarModifier:ViewModifier{
    var backgroundColor:UIColor?
    
    init(backgroundColor:UIColor?){
        self.backgroundColor = backgroundColor
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = .clear
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBarAppearance()
    }
    
    func body(content: Content) -> some View {
        ZStack{
            content
            VStack{
                GeometryReader{geometry in
                    Color(self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    
                    Spacer()
                }
            }
        }
    }
}

extension View{
    func navigationBarColor(_ backgroundColor:UIColor?)-> some View{
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }
}
