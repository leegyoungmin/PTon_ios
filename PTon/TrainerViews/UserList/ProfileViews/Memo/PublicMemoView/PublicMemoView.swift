//
//  PublicMemoView.swift
//  PTon
//
//  Created by 이경민 on 2022/03/16.
//

import SwiftUI

struct PublicMemoView: View {
    let memo:Memo
    let columns: [GridItem] = Array(repeating:.init(.flexible()),count:3)
    var body: some View {
        VStack(alignment:.leading,spacing:5){
            HStack{
                Text(memo.title)
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
            }

            Text(memo.time)
            
            Text(memo.content)
                .padding(.top)
                .multilineTextAlignment(.leading)
            
            Text("식단")
                .font(.title2)
                .padding(.top)
            
            ForEach(["아침","점심","저녁"],id:\.self) { title in
                
                DisclosureGroup {
                    if title == "아침"{
                        ForEach(memo.firstMeal ?? [],id:\.self){ meal in
                            LazyHGrid(rows: columns, alignment: .center){
                                Text(meal)
                            }
                        }
                    }
                    if title == "점심"{
                        ForEach(memo.secondMeal ?? [],id:\.self){ meal in
                            Text(meal)
                        }
                    }
                    if title == "저녁"{
                        ForEach(memo.thirdMeal ?? [],id:\.self){ meal in
                            Text(meal)
                        }
                    }
                } label: {
                    Text(title)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct PublicMemoView_Previews: PreviewProvider {
    static var previews: some View {
        PublicMemoView(memo:
                        Memo(
                            uuid: UUID().uuidString,
                            title: "Example_1",
                            content: "없이 불러 애기 가슴속에 않은 부끄러운 오면 이네들은 지나고 까닭입니다. 위에도 못 이름과, 파란 프랑시스 하나에 이제 별 있습니다. 이름을 때 언덕 옥 동경과 불러 이름자 토끼, 별에도 있습니다. 사람들의 하나 나는 북간도에 내일 헤일 청춘이 있습니다. 이웃 내 그리고 자랑처럼 봄이 시와 오는 별 봅니다. 덮어 애기 오는 다하지 위에 사랑과 까닭이요, 많은 까닭입니다. 다 풀이 써 별이 같이 된 아름다운 했던 까닭입니다. 멀리 잠, 애기 내린 까닭이요, 라이너 있습니다. 노루, 이름을 풀이 때 계십니다. 하나의 벌써 아스라히 둘 같이 것은 어머니, 계절이 가을 봅니다. 애기 노새, 걱정도 버리었습니다.",
                            time: convertString(content: Date(), dateFormat: "yyyy.MM.dd HH:mm"),
                            isPrivate: false,
                            firstMeal: ["식사1","식사1","식사1","식사1","식사1","식사1","식사1","식사1","식사1","식사1","식사1","식사1"],
                            secondMeal: ["식사2"],
                            thirdMeal: nil)
        )
    }
}
