//
//  extensions.swift
//  PTon
//
//  Created by 이경민 on 2022/02/11.
//

import Foundation
import SwiftUI
import Combine
import Firebase
import Kingfisher

//Images
let logoImage = Image("defaultImage")

struct CircleImage:View{
    let url:String
    let size:CGSize
    
    var body: some View{
        KFImage(URL(string: url))
            .placeholder({
                logoImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height, alignment: .center)
            })
            .resizable()
            .frame(width: size.width, height: size.height, alignment: .center)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(Color.accentColor,lineWidth: 1.5)
            )
    }
}

//Colors
let backgroundColor = Color("Background")
let pink = Color("pink")
let sky = Color("skyblue")
let yello = Color("myyellow")

extension Bundle{
    func decode<T:Codable>(_ file:String)->T{
        //1. Locate json
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in Bundle.")
        }
        //2. Create property
        guard let data = try? Data(contentsOf: url) else{
            fatalError("Failed to Load \(file) from Bundle.")
        }
        //3. Create decoder
        let decoder = JSONDecoder()
        
        //4. deocoded data
        guard let loaded = try? decoder.decode(T.self, from: data) else{
            fatalError("Failed to decode \(file) from Bundle.")
        }
        //5. return data
        return loaded
    }
}

let wiseData:[String] = [
    "힘은 물리적인 능력에서 나오는 것이 아니고, 꺽을 수 없는 의지에서 나온다.",
    "트레이닝은 스트레스로부터 억눌린 에너지를 분출할 수 있게 한다.그러므로 운동이 몸을 건강하게 하듯이 정신역시 건강하게 한다.",
    "당신의 몸은 거의 모든 것을 버틸 수 있다. 당신의 정신력을 믿으면 된다.",
    "피트니스는 관계와 같다.당신이 치팅을 하면서 그게 효과가 있을거라고 바라면 안된다.,",
    "당신의 몸을 존중해라. 당신이 가진 유일한 것이다.,",
    "마지막 마무리는 끝내지 않은것보다 낫고,끝내지 않은 건 시작조차 하지 않는 것보다 낫다.",
    "미래를 예상하는 가장 좋은 방법은 직접 미래를 만드는 것이다.",
    "조용히, 열심히 하라. 그리고 성공을 시끄럽게 두면 된다.",
    "습관을 만드는데 21일이 걸리고, 라이프 스타일이 되는데까지 90일이 걸린다.",
    "완벽을 바라지 말고, 진전을 바라고 노력하라.",
    "노력과 성공의 차이는 매우 작은 비명소리(노력)이다.",
    "먹는거 귀찮아요.",
    "먹어봤자 다 아는 맛이다.",
    "세끼 다 먹으면 살쪄요.",
    "죽을만큼 운동하고 죽지않을 만큼 먹어요.",
    "인생은 살이 쪘을 떄와 안쪘을 때로 나뉜다.",
    "야식 3일을 먹으면 300일을 먹게 된다.",
    "날씬한 것보다 달콤한 것은 없다.",
    "나를 배부르게 하는 것들이 나를 파괴한다.",
    "뚱뚱한 여자는 굶어서라도 살을 빼야 한다.",
    "먹으면 바로 살이 찌는 체질이라 몸매 유지를 위해 늘 노력하고 있어요.",
    "다 벗고 거울앞에 섰을 때 본인 몸에 만족하세요?",
    "세상에 어떤 것도 제 마음대로 안 돼요. 제 의미로 바꿀 수 있는게 몸 밖에 없더라구요.",
    "당신의 몸은 당신의 라이프스타일을 반영한다.",
    "인생을 걸고 다이어트 하라.",
    "여자는 태어나는 것이 아니라 만들어지는 것",
    "여자는 살을 뺌으로서 1천만원 어치의 럭셔리 브랜드를 착용하고 3천만원 어치의 성형수술을 받은 것보다 더 큰 효과를 본다.",
    "하루에 3분 거울 앞에서 냉철한 자기관리의 시간을 가져라.",
    "세상의 변화된 시선과 대우를 꿈꿔라. 그 꿈을 현실로 만들어라.",
    "\'이 정도는 먹어도 될 것이다\'라는 합리화나 자신에게 관대하지 마라.",
    "세상에서 가장 안전한 성형은 다이어트다.",
    "맛있을수록 칼로리도 높아지는 것이다.",
    "인생은 살이 쪘을 때와 안 쪘을 때로 나뉜다.",
    "먹기 위해 사는 것이 아니다. 살기 위해 먹는다는 것을 인지하라.",
    "맛과 멋은 같이 갈 수 없다.",
    "몸매가 패션이고 몸이 스타일이다.",
    "돈 주고 살찌는 것보다 남기는 게 낫다.",
    "먹어라! 후회는 당신의 몫. 세상은 네가 돼지가 되든 말든 상관 안한다.",
    "살찌는 건 한 순간, 빼는 건 피눈물.",
    "지금도 먹고 있는가! 그것은 지방이다.",
    "뇌세포는 죽지만 비만세포는 죽지 않는다.",
    "짧게라도 걷는 것이 아예 안 걷는 것보다 낫다.",
    "죽을 만큼 운동하고 죽지 않을 만큼 먹었어요.",
    "다이어트란 체중감량이 아닌 사이즈의 축소이다.",
    "아침은 공주처럼, 점심은 시녀처럼, 저녁은 거지처럼 먹어라.",
    "배고플 때 자라, 거짓 배고픔은 갈증으로 채워줘라.",
    "실패는 일어설 수 있찌만, 포기는 일어설 수 없다.",
    "남들이 사랑하길 바라기 전에 나부터 스스로를 사랑하자.",
    "음식을 아깝다고 생각하기 전에 내 몸이 아깝다고 생각하고 소식하라.",
    "먹어서 살이 찌는게 아니라 많이 먹어서 살이 찌는 것이다.",
    "체중은 반드시 아는 만큼 빠진다.",
    "나를 배부르게 하는 것들이 나를 파괴한다.",
    "왜 영양가 없는 쓰레기 음식을 입에 넣는가, 당신의 배는 쓰레기통이 아니다. 당신이 먹는 것이 곧 당신이다.",
    "식이조절을 못하면 운동을 열심히 해봐야 소용없다.",
    "식이 70% 운동 30% 복근은 부엌에서 만들어진다.",
    "여우같이 되려면 돼지 같이 땀흘려라.",
    "땀은 지방이 흘리는 눈물이다.",
    "승자는 길을 찾고 패자는 핑계거리를 찾는다.",
    "비만의 괴로움이 운동의 괴로움보다 훨씬 크다.",
    "바라지만 말고 실천하라. 언제까지 바라기만 할 건가!",
    "힘들지 않다면 바뀌지 않는다.",
    "입의 즐거움은 잠깐이지만 엉덩이의 지방은 평생이다.",
    "한 번 사는 인생이다. 폼나게 살고 싶지 않은가?",
    "간단하다. 흔들리면 지방이다.-배우 아놀드슈워제네거",
    "다이어트는 변화이자 신선한 자극이다. 다이어트를 하려면 내가 먼저 변해야 한다.",
    "키 작은 여자는 힐을 신어서라도 키를 높여야 하며 뚱뚱한 여자는 굶어서라도 빼야 한다.",
    "살을 빼고 나니 패션이나 메이크업 등, 모든 부분에서 변화가 생겼어요.",
    "나는 나 자신에게 배고프지 않다는 최면을 건다. 그러면 마법처럼 식욕이 사라진다. 아니면 거울을 본다. 거울 속 내 몸을 보면 이건 절대 잃고 싶지 않다는 생각이 든다.",
    "저는 하얀 음식은 절대 먹지 않아요. 그건 독이니까요.",
    "평생 단 한번도 야식을 먹어 본 적이 없어요."]

//날짜 차이 구하기
func convertInteval(firstDate:Date,second:Date)->Int{
    let currentCal = Calendar.current
    
    return currentCal.dateComponents([.day], from: second, to: firstDate).day!
}

//String -> Date
func convertdate(content:String,format:String)->Date{
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.date(from: content) ?? Date()
}

//Date -> String
func convertString(content:Date,dateFormat:String)->String{
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: content)
}

func kcalString(content:Double)->String{
    return String(format: "%.1f", content)
}

//프로필 아이콘 모델
struct icon:Hashable{
    var iconName:String
    var iconImageName:String
}
//프로필 아이템 함수
func geticons()->[icon]{
    return [
        icon(iconName: "채팅하기", iconImageName: "message.fill"),
        icon(iconName: "일지확인", iconImageName: "bookmark.fill"),
        icon(iconName: "스트레칭", iconImageName: "figure.walk"),
        icon(iconName: "설문조사", iconImageName: "list.bullet.circle"),
        icon(iconName: "메모하기", iconImageName: "doc.on.doc.fill"),
        icon(iconName: "운동요청", iconImageName: "flag.fill")
    ]
}

//스트레칭 모델
struct Stretching:Codable,Hashable{
    let title:String
    let explain:String
    let videoID:String
}

//설문조사 질문 모델
struct Question:Codable,Hashable{
    let question:String
    let answer1:String
    let answer2:String
}
extension String{
    var bool:Bool{
        if self.lowercased() == "false"{
            return false
        }else if self.lowercased() == "true"{
            return true
        }else{
            return false
        }
    }
}


extension View{
    func placeholder<Content:View>(
        when shouldShow:Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: ()->Content
    ) -> some View{
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1:0)
            self
        }
    }
}

extension Bool{
    init<T:BinaryInteger>(_ integer:T){
        if integer == 0{
            self.init(false)
        }else if integer == 1{
            self.init(true)
        }else{
            self.init(false)
        }
    }
    
    var intValue:Int{
        return self ? 1:0
    }
}

extension mealType{
    init?(key:String) {
        switch key{
        case "breakfirst":
            self.init(rawValue: 0)
        case "launch":
            self.init(rawValue: 1)
        case "snack":
            self.init(rawValue: 2)
        case "dinner":
            self.init(rawValue: 3)
        default:
            return nil
        }
    }
}

// Custom Context Menu
struct CustomContextMenu<Content:View,Preview:View>:View{
    var content:Content
    var preview:Preview
    var menu:UIMenu
    var onEnded: ()->()
    
    init(
        @ViewBuilder content:@escaping()->Content,
        @ViewBuilder preview:@escaping()->Preview,
        actions:@escaping()->UIMenu,
        onEnded:@escaping()->()
    ){
        self.content = content()
        self.preview = preview()
        self.menu = actions()
        self.onEnded = onEnded
    }
    
    var body: some View{
        ZStack{
            content
                .hidden()
                .overlay(
                    ContextMenuHelper(content: content, preview: preview, actions: menu, onEnded: onEnded)
                )
        }
    }
}

struct ContextMenuHelper<Content:View,Preview:View>:UIViewRepresentable{
    var content:Content
    var preview:Preview
    var actions:UIMenu
    var onEnded:()->()
    
    init(content:Content,preview:Preview,actions:UIMenu,onEnded:@escaping()->()){
        self.content = content
        self.preview = preview
        self.actions = actions
        self.onEnded = onEnded
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let hostView = UIHostingController(rootView: content)
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            hostView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            hostView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            hostView.view.heightAnchor.constraint(equalTo: view.heightAnchor),
        ]
        
        view.addSubview(hostView.view)
        view.addConstraints(constraints)
        
        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        view.addInteraction(interaction)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    class Coordinator:NSObject,UIContextMenuInteractionDelegate{
        var parent:ContextMenuHelper
        
        init(parent:ContextMenuHelper){
            self.parent = parent
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: {
                let previewController = UIHostingController(rootView: self.parent.preview)
                previewController.view.backgroundColor = .clear
                return previewController
            }, actionProvider: { items in
                return self.parent.actions
            })
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
            animator.addCompletion {
                self.parent.onEnded()
            }
        }
    }
}

extension Encodable{
    var toDictionary:[String:Any]?{
        guard let object = try? JSONEncoder().encode(self) else{return nil}
        guard let dictionary = try? JSONSerialization.jsonObject(with: object,options: []) as? [String:Any] else{return nil}
        return dictionary
    }
}

func convertPercent(_ rate:Double) -> String{
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    return formatter.string(for: rate) ?? formatter.string(from: NSNumber(value: 0))!
}


//MARK: - PREVIEWS
struct Extensions_previews:PreviewProvider{
    static var previews: some View{
        CircleImage(url: "https://flif.info/example-images/fish.png", size: CGSize(width: 100, height: 100))
            .previewLayout(.sizeThatFits)
    }
}
