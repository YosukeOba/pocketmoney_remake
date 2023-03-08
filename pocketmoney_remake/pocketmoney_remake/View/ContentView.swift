//
//  ContentView.swift
//  pocketmoney_remake
//
//  Created by 大場　洋介 on 2022/02/01.
//

import CoreData
import FirebaseAuth
import SwiftUI

struct ContentView: View {
    @AppStorage("isFirstView") var isFirstView: Bool = true

    var body: some View {
        if Auth.auth().currentUser == nil {
            LoginView()
        } else if isFirstView {
            FirstView()
        } else {
            ZStack {
                TabView {
                    InputView()
                        .tabItem {
                            VStack {
                                Image(systemName: "wallet.pass")
                                Text("入力")
                            }
                        }
                        .tag(1)
                    HistoryView()
                        .tabItem {
                            VStack {
                                Image(systemName: "clock")
                                Text("履歴")
                            }
                        }
                        .tag(2)
                }
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
    #if os(macOS)
        static let background = Color(NSColor.windowBackgroundColor)
        static let secondaryBackground = Color(NSColor.underPageBackgroundColor)
        static let tertiaryBackground = Color(NSColor.controlBackgroundColor)
    #else
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    #endif
}
