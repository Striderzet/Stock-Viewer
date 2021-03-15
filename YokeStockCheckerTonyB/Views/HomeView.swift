//
//  HomeView.swift
//  YokeStockCheckerTonyB
//
//  Created by Tony Buckner on 3/6/21.
//

import SwiftUI
import CoreData

struct HomeView: View {
    //Fetch core data in this view
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StockAttributes.creationDate, ascending: true)],
        animation: .default)
    
    var stocks: FetchedResults<StockAttributes>
    
    @State private var goTo: Bool = false
  
    //Progress View Flag
    @State private var progressFlag: Bool = true
    
    ///Checks if method ran in "onAppear" runs only once. Apple knows this is a glitch in SwiftUI.
    @State private var onAppearFlag: Bool = false
    
    var body: some View {
        
        ZStack {
            
            NavigationView {
                            
                List {
                    
                    ForEach(stocks) { item in
                        
                        Button(action: {
                            setHaptic(strength: .soft)
                            
                            //save all data locally to be passed
                            loadFromCoreData(item: item)
                            goTo.toggle()
                    
                        }, label: {
                            StockListItem(tickerSymbol: item.tickerSymbol ?? "",
                                          companyName: item.companyName ?? "",
                                          currentPrice: item.currentPrice ?? "", percentChangeColor: percentageChangeColor(item.percentageChange ?? "1.00"),
                                          chartValues: item.chartDataIntraday?.compactMap{CGFloat($0)} ?? [1.0,2.0,3.0,4.0,3.0,2.0,1.0,2.0,3.0,4.0],
                                          chartSegments: item.chartSegmentsIntraday ?? [0,4,8])
                        })
                    }
                }
                .sheet(isPresented: $goTo, content: {
                    StockDetailView(ticker: stockDetailViewModel.tickerSymbol,
                                    fullName: stockDetailViewModel.companyName,
                                    price: stockDetailViewModel.currentPrice,
                                    priceChange: stockDetailViewModel.priceChange,
                                    percentageChange: stockDetailViewModel.percentageChange,
                                    chartValues: stockDetailViewModel.historicalPriceChartInfo,
                                    chartSegments: stockDetailViewModel.chartSegments)
                })
                
               
               
                .navigationTitle("Stocks")
                .onAppear(perform: {
                    
                    if !onAppearFlag {
                        
                        //will load from API when app is first loaded
                        startLoadWithCoreDataCheck(stocks: stocks, viewContext: viewContext) { done in
                            if done {
                                progressFlag = false
                            }
                        }
                        onAppearFlag.toggle()
                    }
                })
                
    
            }
            
            //Show loading screen
            if progressFlag {
                LoadingView()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
