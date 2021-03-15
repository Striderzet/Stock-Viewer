//
//  YokeStockCheckerTonyBApp.swift
//  YokeStockCheckerTonyB
//
//  Created by Tony Buckner on 3/6/21.
//

import SwiftUI

@main
struct YokeStockCheckerTonyBApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            
            HomeTabbedView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            
        }
    }
}
