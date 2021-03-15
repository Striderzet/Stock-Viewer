//
//  DataHandler.swift
//  YokeStockCheckerTonyB
//
//  Created by Tony Buckner on 3/8/21.
//

import Foundation
import CoreData
import SwiftUI
import UIKit

//MARK: - Store pulled info from complete API pull for ticker symbol.

///This function will store incoming stock info that was just pulled from the API.
func storeCurrentStockInfo(_ ticker: String, _ viewContext: NSManagedObjectContext, saved: @escaping(_ loaded: Bool) -> Void) {
    
    let newStock = StockAttributes(context: viewContext)
    
    APICalls.shared.completeAPICall(ticker) { good in
        if good {
            
            newStock.tickerSymbol = stockDetailViewModel.tickerSymbol
            newStock.companyName = stockDetailViewModel.companyName
            
            newStock.currentPrice = stockDetailViewModel.currentPrice
            
            newStock.priceChange = stockDetailViewModel.priceChange
            newStock.percentageChange = stockDetailViewModel.percentageChange
            
            newStock.chartDataIntraday = unwrapBypassForCGFloatArray(stockDetailViewModel.historicalPriceChartInfo[.oneDay]).compactMap{Float($0)}
            newStock.chartSegmentsIntraday = stockDetailViewModel.chartSegments[.oneDay]
            
            stockDetailViewModel.historicalPriceChartInfo[.oneWeek]?.reverse()
            newStock.chartDataOneWeek = unwrapBypassForCGFloatArray(stockDetailViewModel.historicalPriceChartInfo[.oneWeek]).compactMap{Float($0)}
            newStock.chartSegmentsOneWeek = stockDetailViewModel.chartSegments[.oneWeek]
          
            stockDetailViewModel.historicalPriceChartInfo[.oneMonth]?.reverse()
            newStock.chartDataOneMonth = unwrapBypassForCGFloatArray(stockDetailViewModel.historicalPriceChartInfo[.oneMonth]).compactMap{Float($0)}
            newStock.chartSegmentsOneMonth = stockDetailViewModel.chartSegments[.oneMonth]
            
            stockDetailViewModel.historicalPriceChartInfo[.threeMonths]?.reverse()
            newStock.chartDataThreeMonths = unwrapBypassForCGFloatArray(stockDetailViewModel.historicalPriceChartInfo[.threeMonths]).compactMap{Float($0)}
            newStock.chartSegmentsThreeMonths = stockDetailViewModel.chartSegments[.threeMonths]
            
            stockDetailViewModel.historicalPriceChartInfo[.oneYear]?.reverse()
            newStock.chartDataOneYear = unwrapBypassForCGFloatArray(stockDetailViewModel.historicalPriceChartInfo[.oneYear]).compactMap{Float($0)}
            newStock.chartSegmentsOneYear = stockDetailViewModel.chartSegments[.oneYear]
            
            stockDetailViewModel.historicalPriceChartInfo[.fiveYears]?.reverse()
            newStock.chartDataFiveYears = unwrapBypassForCGFloatArray(stockDetailViewModel.historicalPriceChartInfo[.fiveYears]).compactMap{Float($0)}
            newStock.chartSegmentsFiveYears = stockDetailViewModel.chartSegments[.fiveYears]
            
            do {
                try viewContext.save()
                saved(true)
            } catch {
                print(error.localizedDescription)
                saved(false)
            }
        }
    }
}

//MARK: - Method to load Core Data data to Home View

///Save all the loaded Core Data data to the global singleton , to get loaded to the home stock list.
func loadFromCoreData(item: StockAttributes) {
    
    stockDetailViewModel.tickerSymbol = unwrapBypassForString(item.tickerSymbol)
    stockDetailViewModel.companyName = unwrapBypassForString(item.companyName)

    stockDetailViewModel.currentPrice = unwrapBypassForString(item.currentPrice)
    
    stockDetailViewModel.priceChange = unwrapBypassForString(item.priceChange)
    stockDetailViewModel.percentageChange = unwrapBypassForString(item.percentageChange)
    
    stockDetailViewModel.historicalPriceChartInfo[.oneDay] = unwrapBypassForFloatArray(item.chartDataIntraday).compactMap{CGFloat($0)}
    stockDetailViewModel.chartSegments[.oneDay] = unwrapBypassForIntArray(item.chartSegmentsIntraday)
    
    stockDetailViewModel.historicalPriceChartInfo[.oneWeek] = unwrapBypassForFloatArray(item.chartDataOneWeek).compactMap{CGFloat($0)}
    stockDetailViewModel.chartSegments[.oneWeek] = unwrapBypassForIntArray(item.chartSegmentsOneWeek)
  
    stockDetailViewModel.historicalPriceChartInfo[.oneMonth] = unwrapBypassForFloatArray(item.chartDataOneMonth).compactMap{CGFloat($0)}
    stockDetailViewModel.chartSegments[.oneMonth] = unwrapBypassForIntArray(item.chartSegmentsOneMonth)
    
    stockDetailViewModel.historicalPriceChartInfo[.threeMonths] = unwrapBypassForFloatArray(item.chartDataThreeMonths).compactMap{CGFloat($0)}
    stockDetailViewModel.chartSegments[.threeMonths] = unwrapBypassForIntArray(item.chartSegmentsThreeMonths)
    
    stockDetailViewModel.historicalPriceChartInfo[.oneYear] = unwrapBypassForFloatArray(item.chartDataOneYear).compactMap{CGFloat($0)}
    stockDetailViewModel.chartSegments[.oneYear] = unwrapBypassForIntArray(item.chartSegmentsOneYear)
    
    stockDetailViewModel.historicalPriceChartInfo[.fiveYears] = unwrapBypassForFloatArray(item.chartDataFiveYears).compactMap{CGFloat($0)}
    stockDetailViewModel.chartSegments[.fiveYears] = unwrapBypassForIntArray(item.chartSegmentsFiveYears)
    
}

//MARK: - Method to check Core Data before loading again apart from first launch

///Set load timer for first load at the first start of this app.
var loadTimer: Timer?

///Kill the timer.
func stopLoadTimer() {
    loadTimer?.invalidate()
}

///Check Core Data before loading data from API calls
func startLoadWithCoreDataCheck(stocks: FetchedResults<StockAttributes>, viewContext: NSManagedObjectContext, complete: @escaping(_ done: Bool) -> Void) {

    var stocksToLoad = initialStockList
    
    if stocks.isEmpty {
        var i = 0
        
        //load first one right away
        storeCurrentStockInfo(stocksToLoad[i], viewContext) { loaded in }
        i+=1
        
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            storeCurrentStockInfo(stocksToLoad[i], viewContext) { loaded in }
            
            i+=1
            if i >= stocksToLoad.count {
                complete(true)
                timer.invalidate()
            }
        }
    } else {
        
        for i in 0..<initialStockList.count {
            
            //search through the core data to make sure we don't reload data we have
            for stock in stocks {
                if stock.tickerSymbol == initialStockList[i] {
                    if let index = stocksToLoad.firstIndex(of: initialStockList[i]) {
                        stocksToLoad.remove(at: index)
                    }
                }
            }
        }
        
        if stocksToLoad.isEmpty {
            complete(true)
        } else {
            var i = 0
            
            //load first one right away
            storeCurrentStockInfo(stocksToLoad[i], viewContext) { loaded in }
            i+=1
            
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
                storeCurrentStockInfo(stocksToLoad[i], viewContext) { loaded in }
                
                i+=1
                if i >= stocksToLoad.count {
                    complete(true)
                    timer.invalidate()
                }
            }
        }
    }
}

//MARK: - Method to handle force unwrap data transfers to minimize memory usage to prevent crashes.

///Force unwrap prevention handler for string types.
func unwrapBypassForString(_ object: String?) -> String {
    if let unwrapped = object {
        return unwrapped
    } else {
        return object!
    }
}

///Force unwrap prevention handler for [Int} types.
func unwrapBypassForIntArray(_ object: [Int]?) -> [Int] {
    if let unwrapped = object {
        return unwrapped
    } else {
        return object!
    }
}

///Force unwrap prevention handler for [Float] types.
func unwrapBypassForFloatArray(_ object: [Float]?) -> [Float] {
    if let unwrapped = object {
        return unwrapped
    } else {
        return object!
    }
}

///Force unwrap prevention handler for [CGFloat] types.
func unwrapBypassForCGFloatArray(_ object: [CGFloat]?) -> [CGFloat] {
    if let unwrapped = object {
        return unwrapped
    } else {
        return object!
    }
}
