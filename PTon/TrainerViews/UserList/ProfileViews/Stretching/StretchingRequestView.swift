//
//  StretchingRequestView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/13.
//

import SwiftUI

struct StretchingRequestView: View {
    //MARK: - PROPERTIES
    @Environment(\.dismiss) var dismiss
    let Stretchings:[Stretching] = Bundle.main.decode("Stretching.json")
    @StateObject var stretchingViewModel:StretchingViewModel
    @State var selectedDay = Date()
    
    //MARK: - VIEW
    var body: some View {
        VStack{
            HStack{
                DatePicker("", selection: $stretchingViewModel.selectedDay,displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: "ko_KR"))
                    .labelsHidden()
                    .onChange(of: stretchingViewModel.selectedDay) { newValue in
                        stretchingViewModel.fetchData()
                    }
                
                Spacer()
                
                Button {
                    stretchingViewModel.setTrainerStretching {
                        stretchingViewModel.setUserStretching {
                            dismiss.callAsFunction()
                        }
                    }
                } label: {
                    Text("저장하기")
                        .underline()
                        .foregroundColor(.accentColor)
                }
                
            }
            
            ScrollView(.vertical, showsIndicators: false){
                ForEach(stretchingViewModel.trainerList.indices,id:\.self) { index in
                    
                    HStack{
                        URLImageView(urlString:"https://img.youtube.com/vi/\(Stretchings[index].videoID)/maxresdefault.jpg", imageSize: 100, youtube: true)
                        
                        VStack(alignment:.leading,spacing:5){
                            HStack{
                                Text(Stretchings[index].title)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button {
                                    stretchingViewModel.trainerList[index].Checked.toggle()
                                } label: {
                                    Image(systemName: stretchingViewModel.trainerList[index].Checked ? "checkmark.circle.fill":"circle")
                                        .foregroundColor(stretchingViewModel.trainerList[index].Checked ? Color.accentColor:.gray)
                                        .font(.title3)
                                }

                            }
                            
                            Text(Stretchings[index].explain)
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                                .font(.footnote)
                        }
                    }
                    .padding(10)
                }
            }
            .background(.white)
            .padding(.bottom)
            
        }
        .padding(.horizontal)
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack{
                    Button {
                        dismiss.callAsFunction()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .tint(.accentColor)
                    }
                    .buttonStyle(.plain)

                    Text("스트레칭 요청하기")
                        .fontWeight(.semibold)
                }

            }
        }
    }
}
struct CheckboxStyle:ToggleStyle{
    func makeBody(configuration: Configuration) -> some View {
        return HStack{
            configuration.label
            
            Spacer()
            
            Image(systemName: configuration.isOn ? "checkmark.circle.fill":"circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(configuration.isOn ? .purple:.gray)
                .font(.system(size: 20, weight: .bold, design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

struct NoHitTesting: ViewModifier {
    func body(content: Content) -> some View {
        SwiftUIWrapper { content }.allowsHitTesting(false)
    }
}

extension View {
    func userInteractionDisabled() -> some View {
        self.modifier(NoHitTesting())
    }
}

struct SwiftUIWrapper<T: View>: UIViewControllerRepresentable {
    let content: () -> T
    func makeUIViewController(context: Context) -> UIHostingController<T> {
        UIHostingController(rootView: content())
    }
    func updateUIViewController(_ uiViewController: UIHostingController<T>, context: Context) {}
}


//MARK: - PREVIEWS
struct StretchingRequestView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            StretchingRequestView(stretchingViewModel: StretchingViewModel(trainerid: "example", userid: "example"))
        }
        
    }
}
