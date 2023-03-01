//
//  InputView.swift
//  pocketmoney_remake
//
//  Created by 大場　洋介 on 2022/02/01.
//

import CoreData
import SwiftUI

struct InputView: View {
    @State var inputMoney: String = ""
    @AppStorage("Sum") var sum: Int = 0

    @State var isOpenFavoriteMenuView: Bool = false

    @FetchRequest(
        entity: MoneyList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \MoneyList.timestamp, ascending: false)],
        predicate: nil,
        animation: .default
    )
    private var moneyLists: FetchedResults<MoneyList>

    @FetchRequest(
        entity: InputList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \InputList.number, ascending: true)],
        predicate: nil,
        animation: .default
    )
    private var inputLists: FetchedResults<InputList>

    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    HStack {
                        Text("全財産")
                            .font(.title)
                        Text(String.localizedStringWithFormat("%d", sum))
                            .font(.largeTitle)
                        Text("円")
                            .padding([.top])
                    }
                    .navigationBarTitle("入力", displayMode: .inline)
                    .navigationBarItems(leading: (
                        NavigationLink(destination: FavoriteMenuView()) {
                            Image(systemName: "gearshape.circle")
                                .imageScale(.large)
                        }
                    ))

                    HStack {
                        Text(inputMoney == "" ? "0" : String.localizedStringWithFormat("%d", Int(inputMoney)!))
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 1))
                            .padding([.leading])
                        Text("円")
                            .padding([.top, .trailing])
                    }
                    ForEach(0 ..< 3) { row in
                        HStack {
                            ForEach(0 ..< 3) { col in
                                Button(action: {
                                    let num: Int = row * 3 + col + 1
                                    numButton(num: num)
                                }) {
                                    Image(systemName: "\(row * 3 + col + 1).circle")
                                }
                                .buttonStyle(NumButtonStyle())
                            }
                        }
                    }

                    HStack {
                        Button(action: { inputMoney = "" })
                            { Image(systemName: "multiply.circle") }
                            .buttonStyle(NumButtonStyle())

                        Button(action: {
                            if inputMoney != "" {
                                numButton(num: 0)
                            }
                        }) { Image(systemName: "0.circle") }
                            .buttonStyle(NumButtonStyle())

                        Button(action: {
                            if inputMoney.count != 0 {
                                inputMoney.removeLast()
                            }
                        }) { Image(systemName: "arrow.backward.circle") }
                            .buttonStyle(NumButtonStyle())
                    }

                    HStack {
                        Button("収入", action: {
                            inputAndOutput(isPlus: true)
                        })
                        .buttonStyle(InputButtonStyle())

                        Button("支出", action: {
                            inputAndOutput(isPlus: false)
                        })
                        .buttonStyle(InputButtonStyle())
                    }

                    HStack {
                        ForEach(inputLists, id: \.number) { inputList in
                            if inputList.isOn, inputList.name != "", inputList.money != "" {
                                Button(action: {
                                    if inputList.isPlus == true {
                                        sum += Int(inputList.money!)!
                                        addArray(inputList.name!, inputList.money!, inputList.isPlus)
                                    } else {
                                        sum -= Int(inputList.money!)!
                                        addArray(inputList.name!, inputList.money!, inputList.isPlus)
                                    }
                                }, label: {
                                    Text(inputList.isPlus == true ? inputList.name! + "\n+" + inputList.money! : inputList.name! + "\n-" + inputList.money!)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                        .foregroundColor(inputList.isPlus ? Color.blue : Color.red)
                                })
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(inputList.isPlus ? Color.blue : Color.red, lineWidth: 1)
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
    }

    private func inputAndOutput(isPlus: Bool) {
        if inputMoney != "", inputMoney.count < 9 {
            sum = isPlus ? sum + Int(inputMoney)! : sum - Int(inputMoney)!
            addArray("", inputMoney, isPlus)
            inputMoney = ""
        }
    }

    private func numButton(num: Int) {
        if inputMoney.count < 9 {
            inputMoney += String(num)
        }
    }

    private func addArray(_ name: String, _ money: String, _ isPlus: Bool) {
        let newMoneyList = MoneyList(context: viewContext)
        newMoneyList.timestamp = Date()
        newMoneyList.name = name
        newMoneyList.money = money
        newMoneyList.isPlus = isPlus

        try? viewContext.save()
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView()
    }
}
