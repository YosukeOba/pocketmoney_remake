//
//  FirstView.swift
//  pocketmoney_remake
//
//  Created by 大場　洋介 on 2022/02/01.
//

import FirebaseAuth
import FirebaseCore
import SwiftUI

struct FirstView: View {
    @AppStorage("isFirstView") var isFirstView: Bool = true
    @AppStorage("Sum") var sum: Int = 0
    @State var firstSum: String = ""
    @State var uidText = "uid"

    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        ZStack {
            Color.background
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    UIApplication.shared.closeKeyboard()
                }
            VStack {
                Button {
                    guard let uid = Auth.auth().currentUser?.uid else {
                        return uidText = "ログインしてないよ"
                    }
                    uidText = uid
                } label: {
                    Text("test button")
                }
                Text(uidText)
                Text("全財産の登録を行いましょう！")
                HStack {
                    TextField("全財産を入力", text: $firstSum)
                        .keyboardType(.numberPad)
                        .font(.largeTitle)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 1)
                        )
                        .padding()
                    Text("円")
                }
                Button(action: {
                    if firstSum != "" {
                        sum = Int(firstSum)!
                        inputListFirstSet()
                        isFirstView = false
                    }
                }, label: {
                    Text("登録")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding()
                })
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .padding()
            }
        }
    }

    private func inputListFirstSet() {
        for index in 0 ..< 3 {
            let newInputList = InputList(context: viewContext)
            newInputList.number = Int16(index)
            newInputList.name = ""
            newInputList.isOn = false
            newInputList.money = ""
            newInputList.isPlus = false

            try? viewContext.save()
        }
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView()
    }
}
