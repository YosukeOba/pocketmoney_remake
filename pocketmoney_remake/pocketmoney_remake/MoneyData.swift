//
//  MoneyData.swift
//  pocketmoney_remake
//
//  Created by 大場　洋介 on 2022/02/02.
//

import SwiftUI

struct MoneyData{
    let calendar = Calendar(identifier: .gregorian)
    
    let id = UUID()
    var date:Date
    let dateDC:DateComponents
    var moneyInfos:[MoneyInfo] = []
    
    init(_ date:Date, _ name:String, _ money:String, _ isPlus:Bool, _ num:Int){
        self.date = date
        self.dateDC = Calendar.current.dateComponents([.year, .month, .day], from: self.date)
        self.moneyInfos.append(MoneyInfo(self.date, name, money, isPlus, num))
    }
    
    mutating func addArray(_ date:Date, _ name:String, _ money:String, _ isPlus:Bool, _ num:Int){
        self.moneyInfos.append(MoneyInfo(date, name, money, isPlus, num))
    }
}


struct MoneyInfo{
    var id = UUID()
    var date:Date
    var name:String
    var money:String
    var isPlus:Bool
    var series:Int = 1
    let num:Int
    
    init(_ date:Date, _ name:String, _ money:String, _ isPlus:Bool, _ num:Int){
        self.date = date
        self.name = name
        self.money = money
        self.isPlus = isPlus
        self.num = num
    }
    
    mutating func seriesPlusOne(){
        self.series += 1
    }
}
