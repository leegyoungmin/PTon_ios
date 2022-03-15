//
//  ExerciseRecordView.swift
//  PTon
//
//  Created by 이경민 on 2022/02/13.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct RecordingExerciseView: View {
    @Environment(\.presentationMode) var presentationmode
    @StateObject var recordingViewModel:RecordingExerciseViewModel
    @State var offset = CGSize.zero
    var body: some View {
        
        //제스처 생성
        let dragGesture = DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded {
                if $0.translation.width > -30{
                    withAnimation {
                        offset = .zero
                        self.presentationmode.wrappedValue.dismiss()
                    }
                }else{
                    offset = .zero
                }
            }
        
        VStack{
            DatePicker(selection: $recordingViewModel.selectedDay, displayedComponents: .date) {
                Text("날짜 지정")
            }
            .environment(\.locale, Locale(identifier: "ko_KR"))
            
            Divider()
            
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(recordingViewModel.ExerciseList,id:\.self) { exercise in
                    ExerciseRecordCell(viewmodel: self.recordingViewModel, exercise: exercise)
                }
            }
            
            VStack{
                TextField("운동 이름", text: $recordingViewModel.inputExercise)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: UIScreen.main.bounds.size.width*0.9)
                HStack{
                    TextField("무게", text: $recordingViewModel.inputWeight)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("횟수", text: $recordingViewModel.inputNumber)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("세트", text: $recordingViewModel.inputSet)
                        .textFieldStyle(.roundedBorder)
                }
                .frame(width: UIScreen.main.bounds.size.width*0.9)
                
                Button {
                    print("Tapped Save Button")
                    recordingViewModel.setData()
                } label: {
                    Text("저장 하기")
                        .padding(5)
                        .padding(.vertical,5)
                        .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .center)
                        .background(.gray.opacity(0.2))
                        .cornerRadius(5)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("운동 기록하기")
                    .font(.title2)
                    .fontWeight(.heavy)
            }
        }
        .onTapGesture(count: 1) {
            UIApplication.shared.endEditing()
        }
        .gesture(dragGesture)
    }
}

struct ExerciseRecordCell:View{
    @StateObject var viewmodel:RecordingExerciseViewModel
    var exercise:RecordingExercise
    var body: some View{
        
        VStack {
            HStack{
                VStack(alignment:.leading){
                    
                    if exercise.exerciseName != nil{
                        Text(exercise.exerciseName!)
                            .font(.title2)
                    }
                    
                    HStack{
                        
                        if exercise.weight != nil{
                            Text("\(exercise.weight!)kg")
                        }
                        
                        if exercise.number != nil{
                            Text("\(exercise.number!)회")
                        }
                        
                        if exercise.set != nil{
                            Text("\(exercise.set!)세트")
                        }
                        
                    }
                    .font(.body)

                }
                
                Spacer()
                
                Button {
                    if exercise.uuid != nil{
                        viewmodel.removeData(exercise.uuid!)
                    }
                    print("Tapped Delete Button")
                } label: {
                    Text("삭제")
                }
                .buttonStyle(.bordered)
            }
            Divider()
        }
        
    }
}


struct ExerciseRecordView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            RecordingExerciseView(recordingViewModel: RecordingExerciseViewModel(trainerid: "example", userid: "example"))
            ExerciseRecordCell(viewmodel: RecordingExerciseViewModel(trainerid: "example", userid: "example"), exercise: RecordingExercise(uuid: UUID().uuidString, exerciseName: "푸시업", number: "20", set: "10", weight: "11"))
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
