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
                                HStack{
                                    Text(timeFormatter.string(from: moneyInfo.date))
                                    Spacer()
                                    Text(moneyInfo.name != "" ? moneyInfo.name : moneyInfo.isPlus ? "+" + String(moneyInfo.money) : "-" + String(moneyInfo.money))
                                    Text(moneyInfo.series != 1 ? "× " + String(moneyInfo.series) : "")
                                    Spacer()
                                    Text(moneyInfo.isPlus ? "+"+String.localizedStringWithFormat("%d", moneyInfo.money * moneyInfo.series) : "-"+String.localizedStringWithFormat("%d", moneyInfo.money * moneyInfo.series))
                                        .foregroundColor(moneyInfo.isPlus ? .blue : .red)
                                }
                                .contentShape(Rectangle())
                            }
                        }
                    }
                }.navigationBarTitle("履歴", displayMode: .inline)
            }
            .onAppear(){
                reflesh()
            }
        }
    }
    
    func reflesh(){
        moneyDatas = []
        for moneyList in moneyLists {
            if moneyDatas.last?.dateDC != Calendar.current.dateComponents([.year, .month, .day], from: moneyList.timestamp!) {
                moneyDatas.append(MoneyData(moneyList.timestamp!, moneyList.name!, Int(moneyList.money), moneyList.isPlus))
            } else if moneyDatas.last?.moneyInfos.last?.name == moneyList.name &&
                        moneyDatas.last?.moneyInfos.last?.money == Int(moneyList.money) &&
                        moneyDatas.last?.moneyInfos.last?.isPlus == moneyList.isPlus{
                moneyDatas[moneyDatas.count-1].moneyInfos[moneyDatas[moneyDatas.count-1].moneyInfos.count-1].seriesPlusOne()
            } else {
                moneyDatas[moneyDatas.count-1].addArray(moneyList.timestamp!, moneyList.name!, Int(moneyList.money), moneyList.isPlus)
            }
        }
    }
    
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
