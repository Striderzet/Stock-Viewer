//
//  StockDetailViewModel.swift
//  YokeStockCheckerTonyB
//
//  Created by Tony Buckner on 3/6/21.
//

import Foundation
import SwiftUI

//MARK: - This view model is a mirror for the core data model that helps pass data along through methods where core data cannot reach.

//Starting list for app at home screen
let initialStockList = ["TSLA", "BCRX", "CRSR", "AAPL", "ELY", "GME"]

//Shared instance will be populated and indexed by ticker symbol string
var stockDetailViewModel = StockDetailViewModel()

struct StockDetailViewModel {
    
    var tickerSymbol = ""
    var companyName = ""
    var currentPrice = ""
    var priceChange = ""
    var percentageChange = ""
        
    var chartSegments = [ChartIntervals.oneDay: [Int](),
                         ChartIntervals.oneWeek: [Int](),
                         ChartIntervals.oneMonth: [Int](),
                         ChartIntervals.threeMonths: [Int](),
                         ChartIntervals.oneYear: [Int](),
                         ChartIntervals.fiveYears: [Int]()]
    
    var historicalPriceChartInfo = [ChartIntervals.oneDay: [CGFloat](),
                                    ChartIntervals.oneWeek: [CGFloat](),
                                    ChartIntervals.oneMonth: [CGFloat](),
                                    ChartIntervals.threeMonths: [CGFloat](),
                                    ChartIntervals.oneYear: [CGFloat](),
                                    ChartIntervals.fiveYears: [CGFloat]()]
    
    ///This will only be used for recent search results.
    var searchResults = [String(): String()]
}
