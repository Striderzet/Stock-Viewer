//
//  HomeTabbedView.swift
//  YokeStockCheckerTonyB
//
//  Created by Tony Buckner on 3/6/21.
//

import SwiftUI
import CoreData

//MARK: Default tabbed view for this app

struct HomeTabbedView: View {
    
    var body: some View {
        
        TabView {
            
            //Home Tab
            HomeView()
                .tabItem {
                    Image(systemName: "homekit")
                    Text("Home")
                }.tag(0)
            
            
            //Search Tab
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }.tag(1)
            
        }
    }
}

struct HomeTabbedView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabbedView()
    }
}
