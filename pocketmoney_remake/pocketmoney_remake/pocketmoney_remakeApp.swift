//
//  pocketmoney_remakeApp.swift
//  pocketmoney_remake
//
//  Created by 大場　洋介 on 2022/02/01.
//

import SwiftUI

@main
struct pocketmoney_remakeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
