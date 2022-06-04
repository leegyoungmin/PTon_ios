//
//  fitnessCenterExerciseView.swift
//  PTon
//
//  Created by 이경민 on 2022/06/03.
//

import Foundation
import SwiftUI
import Kingfisher

struct fitnessCenterExerciseView:View{
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel:userFitnessExerciseViewModel
    var body: some View{
        NavigationView{
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())],spacing: 10) {
                    ForEach(viewModel.exerciseList,id:\.self){ exercise in
                        ZStack(alignment:.bottom){
                            KFImage(URL(string: exercise.url))
                                .onFailureImage(KFCrossPlatformImage(named: "defaultImage"))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150, alignment: .center)
                                .cornerRadius(10)
                                .shadow(color: .gray, radius: 1, x: 0, y: 0)
                            
                            HStack{
                                Text(exercise.exerciseName)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .bold()
                                    .minimumScaleFactor(0.8)
                                
                                Spacer()
                            }
                            .padding(.vertical)
                            .padding(.leading,5)
                            .frame(width: 150, height: 30, alignment: .center)
                            .background(.black.opacity(0.3))
                            .cornerRadius(10, corners: .bottomLeft)
                            .cornerRadius(10, corners: .bottomRight)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss.callAsFunction()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }

                }
            }
        }
        
    }
}

struct fitnessCenterExerciseView_Previews:PreviewProvider{
    static var previews: some View{
        fitnessCenterExerciseView(viewModel: userFitnessExerciseViewModel(userId: "asdjkansd", fitnessCode: "000001"))
    }
}
