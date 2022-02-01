//
//  InputView.swift
//  pocketmoney_remake
//
//  Created by 大場　洋介 on 2022/02/01.
//

import SwiftUI
import CoreData

struct InputView: View {
    
    @State var inputMoney: String = ""
    @AppStorage("Sum") var sum:Int = 0
    
    @State var isOpenFavoriteMenuView: Bool = false
    
    @FetchRequest(
        entity: InputList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \InputList.number, ascending: true)],
        predicate: nil,
        animation: .default)
    private var inputLists: FetchedResults<InputList>
    
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        ZStack{
            NavigationView{
                VStack{
                    HStack{
                        Text("全財産")
                            .font(.title)
                        Text(String.localizedStringWithFormat("%d",sum))
                            .font(.largeTitle)
                        Text("円")
                            .padding([.top])
                    }
                    .navigationBarTitle("入力", displayMode: .inline)
                    .navigationBarItems(leading: (
                        Button(action: {
                            self.isOpenFavoriteMenuView.toggle()
                        }, label: {
                            Image(systemName: "gearshape.circle")
                                .imageScale(.large)
                        })
                            .contentShape(Rectangle())))
                    .sheet(isPresented: $isOpenFavoriteMenuView){
                        FavoriteMenuView()
                    }
                    
                    HStack{
                        Text(inputMoney=="" ? "0" : String.localizedStringWithFormat("%d",Int(inputMoney)!))
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.green, lineWidth: 1))
                            .padding([.leading])
                        Text("円")
                            .padding([.top, .trailing])
                    }
                    ForEach(0..<3){ y in
                        HStack{
                            ForEach(0..<3){ x in
                                Button(action: {
                                    let num: Int = y*3+x+1
                                    numButton(num: num)
                                }, label: {
                                    Image(systemName: "\(y * 3 + x + 1).circle")
                                        .buttonStyle(numButtonStyle())
                                })
                                    
                            }
                        }
                    }
                    
                    HStack{
                        Button(action: {
                            inputMoney = ""
                        }){Image(systemName: "multiply.circle")}
                        .buttonStyle(numButtonStyle())
                        
                        Button(action: {
                            if(inputMoney != ""){
                                numButton(num: 0)
                            }
                        }){Image(systemName: "0.circle")}
                        .buttonStyle(numButtonStyle())
                        
                        Button(action: {
                            if(inputMoney.count != 0){
                                inputMoney.removeLast()
                            }
                        }){Image(systemName: "arrow.backward.circle")}
                        .buttonStyle(numButtonStyle())
                    }
                    
                    HStack{
                        Button("収入", action: {
                            inputAndOutput(isPlus: true)
                        })
                            .buttonStyle(InputButtonStyle())
                        
                        Button("支出", action: {
                            inputAndOutput(isPlus: false)
                        })
                            .buttonStyle(InputButtonStyle())
                    }
                }
            }
        }
    }
    
    private func inputAndOutput(isPlus: Bool){
        if(inputMoney != "" && inputMoney.count < 9){
            sum = isPlus ? sum + Int(inputMoney)! : sum - Int(inputMoney)!
            
            //MoneyListの構造を考えて，ここから書いていこうね
            //addArray(name: "", money: Int(inputMoney)!, isPlus: 0)
            inputMoney = ""
        }
    }
    
    private func numButton(num: Int){
        if(inputMoney.count < 9){
            inputMoney += String(num)
        }
    }
    
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView()
    }
}
