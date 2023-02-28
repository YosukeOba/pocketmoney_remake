//
//  FavoriteMenuView.swift
//  pocketmoney_remake
//
//  Created by 大場　洋介 on 2022/02/01.
//

import SwiftUI

struct FavoriteMenuView: View {
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
            VStack {
                VStack {
                    Form {
                        ForEach(inputLists) { inputList in
                            Section(header: Text("お気に入り" + String(inputList.number + 1))) {
                                FavoriteMenuRowView(inputList: inputList, number: Int(inputList.number), isOn: inputList.isOn, name: inputList.name!, money: inputList.money!, isPlus: inputList.isPlus)
                            }
                        }
                    }
                }
                Spacer()
                NavigationLink(destination: SubscribeView(), label: {
                    HStack {
                        Text("サブスク").frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                })
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .foregroundColor(Color.primary)
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .onTapGesture(perform: {
                UIApplication.shared.closeKeyboard()
            })
        }
    }
}

struct FavoriteMenuRowView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var inputList: InputList

    @State var number: Int
    @State var isOn: Bool
    @State var name: String
    @State var money: String
    @State var isPlus: Bool

    var body: some View {
        VStack {
            if isOn {
                HStack {
                    TextField("名称を入力", text: $name)
                    Toggle(isOn: $isOn) {}.toggleStyle(SwitchToggleStyle())
                }
                HStack {
                    TextField("金額を入力", text: $money)
                        .keyboardType(.numberPad)
                    Text("円")
                }
                HStack {
                    Text("収入")
                        .foregroundColor(.blue)
                    Image(systemName: isPlus ? "checkmark.square" : "square")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Spacer()
                    Text("支出")
                        .foregroundColor(.red)
                    Image(systemName: isPlus ? "square" : "checkmark.square")
                        .resizable()
                        .frame(width: 20, height: 20)
                }.onTapGesture {
                    isPlus.toggle()
                }
            } else {
                Toggle(isOn: $isOn) {
                    Text(name == "" ? "お気に入り" + String(number + 1) : name)
                }.toggleStyle(SwitchToggleStyle())
            }
        }
        .onChange(of: isOn, perform: { _ in
            sync()
        })
        .onChange(of: name, perform: { _ in
            sync()
        })
        .onChange(of: money, perform: { _ in
            sync()
        })
        .onChange(of: isPlus, perform: { _ in
            sync()
        })
    }

    private func sync() {
        inputList.number = Int16(number)
        inputList.isOn = isOn
        inputList.name = name
        inputList.money = money
        inputList.isPlus = isPlus
        try? viewContext.save()
    }
}

struct FavoriteMenuView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteMenuView()
    }
}
