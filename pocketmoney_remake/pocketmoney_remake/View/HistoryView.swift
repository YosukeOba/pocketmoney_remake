//
//  HistoryView.swift
//  pocketmoney_remake
//
//  Created by 大場　洋介 on 2022/02/01.
//

import CoreData
import SwiftUI

struct HistoryView: View {
    @AppStorage("Sum") var sum: Int = 0

    @FetchRequest(
        entity: MoneyList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \MoneyList.timestamp, ascending: false)],
        predicate: nil,
        animation: .default
    )
    private var moneyLists: FetchedResults<MoneyList>

    @Environment(\.managedObjectContext) private var viewContext

    @State var moneyDatas: [MoneyData] = []

    @State var change: Bool = false

    let calendar = Calendar(identifier: .gregorian)

    let timeFormatter = DateFormatter()
    let sectionDateFormatter = DateFormatter()

    init() {
        timeFormatter.dateFormat = "HH:mm"
        sectionDateFormatter.locale = Locale(identifier: "ja_JP")
        sectionDateFormatter.dateFormat = "YYYY/M/d(EEE)"
    }

    var body: some View {
        ZStack {
            NavigationView {
                List {
                    ForEach(moneyDatas, id: \.date) { moneyData in
                        Section(header: Text(sectionDateFormatter.string(from: moneyData.date))) {
                            ForEach(moneyData.moneyInfos, id: \.date) { moneyInfo in
                                NavigationLink(destination: ModificationView(change: self.$change, date: moneyInfo.date, name: moneyInfo.name, money: moneyInfo.money, isPlus: moneyInfo.isPlus, num: moneyInfo.num), label: {
                                    HStack {
                                        // Text(String(moneyInfo.num))
                                        Text(timeFormatter.string(from: moneyInfo.date)).padding([.vertical])
                                        Text(moneyInfo.name != "" ? moneyInfo.name : moneyInfo.isPlus ? "+" + moneyInfo.money : "-" + moneyInfo.money)
                                        Text(moneyInfo.series != 1 ? "× " + String(moneyInfo.series) : "")
                                        Spacer()
                                        Text(moneyInfo.isPlus ? "+" + String.localizedStringWithFormat("%d", Int(moneyInfo.money)! * moneyInfo.series) : "-" + String.localizedStringWithFormat("%d", Int(moneyInfo.money)! * moneyInfo.series))
                                            .foregroundColor(moneyInfo.isPlus ? .blue : .red)
                                    }
                                    .contentShape(Rectangle())
                                })
                            }
                        }
                    }
                }.navigationBarTitle("履歴", displayMode: .inline)
            }
            .onAppear {
                reflesh()
            }
            .onChange(of: change, perform: { _ in
                reflesh()
                change = false
            })
        }
    }

    func reflesh() {
        var i = 0
        moneyDatas = []
        for moneyList in moneyLists {
            if moneyDatas.last?.dateDC != Calendar.current.dateComponents([.year, .month, .day], from: moneyList.timestamp!) {
                moneyDatas.append(MoneyData(moneyList.timestamp!, moneyList.name!, moneyList.money!, moneyList.isPlus, i))
                i += 1
            } else if moneyDatas.last?.moneyInfos.last?.name == moneyList.name,
                      moneyDatas.last?.moneyInfos.last?.money == moneyList.money,
                      moneyDatas.last?.moneyInfos.last?.isPlus == moneyList.isPlus
            {
                moneyDatas[moneyDatas.count - 1].moneyInfos[moneyDatas[moneyDatas.count - 1].moneyInfos.count - 1].seriesPlusOne()
                i += 1
            } else {
                moneyDatas[moneyDatas.count - 1].addArray(moneyList.timestamp!, moneyList.name!, moneyList.money!, moneyList.isPlus, i)
                i += 1
            }
        }
    }
}

struct ModificationView: View {
    @Binding var change: Bool
    @AppStorage("Sum") var sum: Int = 0

    @FetchRequest(
        entity: MoneyList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \MoneyList.timestamp, ascending: false)],
        predicate: nil,
        animation: .default
    )
    private var moneyLists: FetchedResults<MoneyList>

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State var showingDeleteAlert: Bool = false
    @State var showingReturnAlert: Bool = false

    @State var date: Date
    @State var name: String
    @State var money: String
    @State var isPlus: Bool
    @State var num: Int

    var body: some View {
        ZStack {
            Color.background
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    UIApplication.shared.closeKeyboard()
                }
            VStack {
                DatePicker(selection: $date) {
                    Text("日時")
                }
                .contentShape(Rectangle())
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primary, lineWidth: 1))
                .padding([.horizontal])
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
                Spacer()
                Button(action: {
                    self.showingDeleteAlert.toggle()
                }, label: {
                    Text("Delete").frame(maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationTitle("変更")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            if money != "" {
                                sync()
                                dismiss()
                            } else {
                                self.showingReturnAlert.toggle()
                                money = moneyLists[num].money!
                            }
                        }, label: {
                            Image(systemName: "arrow.backward")
                        }
                    ).tint(.orange)
                }
            }
            .alert("警告", isPresented: $showingDeleteAlert) {
                Button("削除", role: .destructive) {
                    deleteItem()
                    dismiss()
                }
            } message: {
                Text("項目を削除します")
            }
            .alert("警告", isPresented: $showingReturnAlert) {
                Button("了解") {}
            } message: {
                Text("金額が入力されていません")
            }
        }
    }

    private func deleteItem() {
        sum = moneyLists[num].isPlus ? sum - Int(moneyLists[num].money!)! : sum + Int(moneyLists[num].money!)!

        let temp = moneyLists[num]
        viewContext.delete(temp)
        try? viewContext.save()
        change = true
    }

    private func sync() {
        sum = moneyLists[num].isPlus ? sum - Int(moneyLists[num].money!)! : sum + Int(moneyLists[num].money!)!
        sum = isPlus ? sum + Int(money)! : sum - Int(money)!

        moneyLists[num].timestamp = date
        moneyLists[num].name = name
        moneyLists[num].money = money
        moneyLists[num].isPlus = isPlus
        try? viewContext.save()
        change = true
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
