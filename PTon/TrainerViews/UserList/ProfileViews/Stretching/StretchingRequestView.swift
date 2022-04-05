//
//  StretchingRequestView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/13.
//

import SwiftUI
import SDWebImageSwiftUI
import AlertToast

struct StretchingRequestView: View {
    //MARK: - PROPERTIES
    @Environment(\.dismiss) var dismiss
    let Stretchings:[Stretching] = Bundle.main.decode("Stretching.json")
    @StateObject var stretchingViewModel:StretchingViewModel
    @State var selectedDay = Date()
    @State var isShowAlert:Bool = false
    let AlertMessage:String = "저장완료"
    
    //MARK: - VIEW
    var body: some View {
        VStack{
            weekDatePickerView(currentDate: $selectedDay)
                .padding()
                .background(.white)
                .onChange(of: selectedDay) { newvalue in
                    stretchingViewModel.fetchData(date: newvalue)
                    print(stretchingViewModel.trainerList.count)
                }
            
            ScrollView(.vertical, showsIndicators: false){
                ForEach(stretchingViewModel.trainerList.indices,id:\.self) { index in
                    
                    HStack{
                        
                        WebImage(url: URL(string: "https://img.youtube.com/vi/\(Stretchings[index].videoID)/maxresdefault.jpg"))
                            .placeholder(Image("defaultImage"))
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50, alignment: .center)
                        
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
            .padding(.horizontal)
            .padding(.bottom,5)
            
        }
        .disabled(isShowAlert)
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toast(isPresenting: $isShowAlert,duration: 1, alert: {
            AlertToast(displayMode: .banner(.pop), type: .complete(.accentColor),title: AlertMessage)
        },completion: {
            self.dismiss.callAsFunction()
        })
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    stretchingViewModel.setTrainerStretching {
                        stretchingViewModel.setUserStretching {
                            withAnimation {
                                self.isShowAlert = true
                            }
                        }
                    }
                } label: {
                    Text((stretchingViewModel.trainerList.filter({$0.Checked == true}).count > 0) ? "수정하기":"저장하기")
                        .underline()
                        .foregroundColor(.accentColor)
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

