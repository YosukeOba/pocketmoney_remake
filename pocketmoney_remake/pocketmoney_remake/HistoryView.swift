//
//  HistoryView.swift
//  pocketmoney_remake
//
//  Created by 大場　洋介 on 2022/02/01.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    
    @AppStorage("Sum") var sum:Int = 0
    
    @FetchRequest(
        entity: MoneyList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \MoneyList.timestamp, ascending: false)],
        predicate: nil,
        animation: .default)
    private var moneyLists: FetchedResults<MoneyList>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var moneyDatas:[MoneyData] = []
    
    @State var change:Bool = false
    
    let calendar = Calendar(identifier: .gregorian)
    
    let timeFormatter = DateFormatter()
    let sectionDateFormatter = DateFormatter()
    
    init(){
        timeFormatter.dateFormat = "HH:mm"
        sectionDateFormatter.locale = Locale(identifier: "ja_JP")
        sectionDateFormatter.dateFormat = "YYYY/M/d(EEE)"
    }
    
    var body: some View {
        ZStack{
            NavigationView{
                List{
                    ForEach(moneyDatas, id:\.date) { moneyData in
                        Section(header: Text(sectionDateFormatter.string(from: moneyData.date))){
                            ForEach(moneyData.moneyInfos, id:\.date) { moneyInfo in
                                NavigationLink(destination: ModificationView(change: self.$change, date: moneyInfo.date, name: moneyInfo.name, money: moneyInfo.money, isPlus: moneyInfo.isPlus, num: moneyInfo.num), label: {
                                    HStack{
                                        //Text(String(moneyInfo.num))
                                        Text(timeFormatter.string(from: moneyInfo.date)).padding([.vertical])
                                        Text(moneyInfo.name != "" ? moneyInfo.name : moneyInfo.isPlus ? "+" + moneyInfo.money : "-" + moneyInfo.money)
                                        Text(moneyInfo.series != 1 ? "× " + String(moneyInfo.series) : "")
                                        Spacer()
                                        Text(moneyInfo.isPlus ? "+"+String.localizedStringWithFormat("%d", Int(moneyInfo.money)! * moneyInfo.series) : "-"+String.localizedStringWithFormat("%d", Int(moneyInfo.money)! * moneyInfo.series))
                                            .foregroundColor(moneyInfo.isPlus ? .blue : .red)
                                    }
                                    .contentShape(Rectangle())
                                })
                            }
                        }
                    }
                }.navigationBarTitle("履歴", displayMode: .inline)
            }
            .onAppear(){
                reflesh()
            }
            .onChange(of: change, perform: {_ in
                reflesh()
                change = false
            })
        }
    }
    
    func deleteItems(_ num:Int){
        withAnimation{
            let temp = moneyLists[num]
            viewContext.delete(temp)
            try? viewContext.save()
            reflesh()
        }
    }
    
    func reflesh(){
        var i:Int = 0
        moneyDatas = []
        for moneyList in moneyLists {
            if moneyDatas.last?.dateDC != Calendar.current.dateComponents([.year, .month, .day], from: moneyList.timestamp!) {
                moneyDatas.append(MoneyData(moneyList.timestamp!, moneyList.name!, moneyList.money!, moneyList.isPlus, i))
                i += 1
            } else if moneyDatas.last?.moneyInfos.last?.name == moneyList.name &&
                        moneyDatas.last?.moneyInfos.last?.money == moneyList.money &&
                        moneyDatas.last?.moneyInfos.last?.isPlus == moneyList.isPlus{
                moneyDatas[moneyDatas.count-1].moneyInfos[moneyDatas[moneyDatas.count-1].moneyInfos.count-1].seriesPlusOne()
                i += 1
            } else {
                moneyDatas[moneyDatas.count-1].addArray(moneyList.timestamp!, moneyList.name!, moneyList.money!, moneyList.isPlus, i)
                i += 1
            }
        }
    }
}

struct ModificationView: View{
    @Binding var change:Bool
    @AppStorage("Sum") var sum:Int = 0
    
    @FetchRequest(
        entity: MoneyList.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \MoneyList.timestamp, ascending: false)],
        predicate: nil,
        animation: .default)
    private var moneyLists: FetchedResults<MoneyList>
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State var date:Date
    @State var name:String
    @State var money:String
    @State var isPlus:Bool
    @State var num:Int
    
    var body: some View{
        VStack{
            DatePicker(selection: $date){
                Text("日時")
            }
            TextField("名称を入力", text:$name)
            HStack{
                TextField("金額を入力", text:$money)
                    .keyboardType(.numberPad)
                Text("円")
            }
            HStack{
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
        }
        .navigationTitle("変更")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: {
                        sync()
                        dismiss()
                    }, label: {
                        Image(systemName: "arrow.backward")
                    }
                ).tint(.orange)
            }
        }
//        .onChange(of: date, perform: {_ in
//            sync()
//        })
    }
    
    private func sync(){
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
