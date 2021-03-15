//
//  APIConstants.swift
//  YokeStockCheckerTonyB
//
//  Created by Tony Buckner on 3/6/21.
//

import Foundation
import UIKit
import SwiftUI

//MARK: - Constant values for the API we will be using (AlphaVantage.co).
struct APIConstants {
    
    //Example Query API call for basic stock info
    //https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=tesco&apikey=R02ON7I05C6ERH2Q
    
    //For more API documentation
    //https://www.alphavantage.co/documentation/
    
    //Start of URL
    static let APIScheme = "https"
    static let APIHost = "www.alphavantage.co"
    static let APIPath = "/query"
    
    
    struct Keys {
        
        //Search Endpoint (Normal Search) and required for all API calls. "Keywords" is the ticker symbol
        static let function = "function"
        static let keywords = "keywords"
        
        //Symbol is used for Quote Endpoint
        static let symbol = "symbol"
        
        //Time Intervals
        static let interval = "interval"
        
        //Output size (only for Daily requests)
        static let outputsize = "outputsize"
        
        //API Key
        static let apikey = "apikey"
        
    }
    
    struct Values {
        
        //All searches and requests will go by this ticker symbol
        static var keywords = "GME" // needs to be empty "" later for multiple calls
        
        //Ticker symbol search
        static let functionTicker = "SYMBOL_SEARCH"
        
        //Ticker price and change
        static let functionTickerDetail = "GLOBAL_QUOTE" //GLOBAL_QUOTE
        
        //Intraday
        static let functionIntraday = "TIME_SERIES_INTRADAY"
        static let intervalIntraday = "5min"
        
        //Daily
        static var functionDaily = "TIME_SERIES_DAILY"
        static var outputsizeDaily = "full"
                
        //For API Key
        static let apikey = "R02ON7I05C6ERH2Q"
    }
}
