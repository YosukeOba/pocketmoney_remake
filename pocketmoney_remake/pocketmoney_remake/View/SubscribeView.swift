//
//  SubscribeView.swift
//  pocketmoney_remake
//
//  Created by 大場　洋介 on 2022/02/10.
//

import SwiftUI

struct SubscribeView: View {
    @FetchRequest(
        entity: SubscribeList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscribeList.addDate, ascending: false)],
        predicate: nil,
        animation: .default
    )
    private var subscribeLists: FetchedResults<SubscribeList>

    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            List {
                ForEach(subscribeLists) { subscribeList in
                    NavigationLink(destination: AddSuscribeView(addDate: subscribeList.addDate!, name: subscribeList.name!, money: subscribeList.money!, isPlus: subscribeList.isPlus, frequency: Int(subscribeList.frequency), payDate: Int(subscribeList.payDate)), label: {
                        HStack {
                            Text(subscribeList.name!)
                            Text(subscribeList.money!)
                            Spacer()
                        }
                    })
                }
            }
            .toolbar {
                ToolbarItem {
                    NavigationLink(destination: AddSuscribeView(), label: {
                        Label("Add Item", systemImage: "plus")
                    })
                }
            }
        }
    }
}

struct AddSuscribeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State var addDate = Date()
    @State var name = ""
    @State var money = ""
    @State var isPlus = true
    @State var frequency = 0
    @State var payDate = 0

    var body: some View {
        ZStack {
            Color.background
                .edgesIgnoringSafeArea(.all)
                .onTapGesture(perform: {
                    UIApplication.shared.closeKeyboard()
                })
            VStack {
                TextField("名称を入力", text: $name)
                    .padding()
                    .contentShape(Rectangle())
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.primary, lineWidth: 1))
                    .padding([.horizontal])
                HStack {
                    TextField("金額を入力", text: $money)
                        .keyboardType(.numberPad)
                        .padding()
                        .contentShape(Rectangle())
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.primary, lineWidth: 1))
                        .padding([.leading])
                    Text("円")
                        .padding([.top, .trailing])
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
                }
                .padding()
                .contentShape(Rectangle())
                .padding([.horizontal])
                .onTapGesture {
                    isPlus.toggle()
                }
            }
        }
    }
}

struct SubscribeView_Previews: PreviewProvider {
    static var previews: some View {
        SubscribeView()
    }
}
