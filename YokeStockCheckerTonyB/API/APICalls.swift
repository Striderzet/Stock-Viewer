//
//  APICalls.swift
//  YokeStockCheckerTonyB
//
//  Created by Tony Buckner on 3/6/21.
//

import Foundation
import UIKit
import SwiftUI
import CoreData

///Call types for API's with ticker symbol reference.
enum APICallType {
    case tickerName
    case tickerPriceDetail
    case tickerIntraday
    case tickerDailyExtended
    case plainSearch
}

struct APICalls {
    
    static var shared = APICalls()
    
    //MARK: - Search for Ticker Names and Full Company Names
    
    //MARK: Private Methods
    
    ///Method for parameter setup for multiple API call types. Good for cascading calls. Calls will aways start with the "oneDay" chart interval and get the rest on its own.
    private func apiCallParameters(_ queryString: String, _ callType: APICallType) -> [String:AnyObject]{
        
        //Set API key initially
        var methodParameters = [APIConstants.Keys.apikey: APIConstants.Values.apikey] as [String:AnyObject]
        
        //Set remaining parameter according to call type.
        switch callType {
        case .plainSearch:
            methodParameters[APIConstants.Keys.function] = APIConstants.Values.functionTicker as AnyObject
            methodParameters[APIConstants.Keys.keywords] = queryString as AnyObject
        case .tickerName:
            methodParameters[APIConstants.Keys.function] = APIConstants.Values.functionTicker as AnyObject
            methodParameters[APIConstants.Keys.keywords] = queryString as AnyObject
        case .tickerPriceDetail:
            methodParameters[APIConstants.Keys.function] = APIConstants.Values.functionTickerDetail as AnyObject
            methodParameters[APIConstants.Keys.symbol] = queryString as AnyObject
        case .tickerIntraday:
            methodParameters[APIConstants.Keys.function] = APIConstants.Values.functionIntraday as AnyObject
            methodParameters[APIConstants.Keys.interval] = APIConstants.Values.intervalIntraday as AnyObject
            methodParameters[APIConstants.Keys.symbol] = queryString as AnyObject
        case .tickerDailyExtended:
            methodParameters[APIConstants.Keys.function] = APIConstants.Values.functionDaily as AnyObject
            methodParameters[APIConstants.Keys.outputsize] = APIConstants.Values.outputsizeDaily as AnyObject
            methodParameters[APIConstants.Keys.symbol] = queryString as AnyObject
        }
        
        return methodParameters
        
    }
    
    ///Method returns a URL for use in the API call from constructed parameters according to API call type.
    private func apiCallParametersToURL(_ parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = APIConstants.APIScheme
        components.host = APIConstants.APIHost
        components.path = APIConstants.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: value as? String)
            components.queryItems?.append(queryItem)
        }
        
        if let componentURL = components.url {
            return componentURL
        } else {
            return components.url!
        }
    }
    
    //MARK: Public Methods
    
    ///Calls WebAPI according to API call type and returns the data accordingly.
    func callWebAPI(_ ticker: String, _ callType: APICallType, loaded: @escaping(_ good: Bool, _ errorCode: String) -> Void ){ //_ parameters: [String: AnyObject],
        
        let session = URLSession.shared
        
        var request = URLRequest(url: apiCallParametersToURL(apiCallParameters(ticker, callType))) //APIConstants.Values.keywords
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func displayError(_ error: String) {
                print(error)
            }
            
            //Normal error code parameters.
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                loaded(false, "net")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                loaded(false, "net")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard data != nil else {
                displayError("No data was returned by the request!")
                loaded(false, "nil")
                return
            }
            //End normal error code parameters.
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(String(describing: data))'")
                loaded(false, "info")
                return
            }
            
            switch callType {
            case .plainSearch:
                //Keep from nil errors
                guard let _ = parsedResult["bestMatches"] else {
                    loaded(false, "Results returned empty.")
                    return
                }
                
                //Needed keys:
                //"1. symbol" = ticker symbol
                //"2. name" = full company name

                let tickerData = parsedResult["bestMatches"] as! [[String: AnyObject]]
                
                for element in tickerData {
                    stockDetailViewModel.searchResults[element["1. symbol"] as! String] = (element["2. name"] as! String)
                }
              
            case .tickerName:
                //Keep from nil errors
                guard let _ = parsedResult["bestMatches"] else {
                    loaded(false, "Results returned empty.")
                    return
                }
                
                //Needed keys:
                //"1. symbol" = ticker symbol
                //"2. name" = full company name

                let tickerData = parsedResult["bestMatches"] as! [[String: AnyObject]]
               
                //Save to view model (Core Data)
                stockDetailViewModel.tickerSymbol = ticker //tickerData[0]["1. symbol"]  as! String
                stockDetailViewModel.companyName = tickerData[0]["2. name"]  as! String
            
            case .tickerPriceDetail:
                //Keep from nil errors
                guard let _ = parsedResult["Global Quote"] else {
                    loaded(false, "Results returned empty.")
                    return
                }
                
                //Needed keys:
                //"05. price" = current price
                //"09. change" = price change (pos or neg)
                //"10. change percent" = percent change (pos or neg)
            
                let tickerData = parsedResult["Global Quote"] as! [String: AnyObject]
                
                //Save to view model (Core Data)
                var setPrice = tickerData["05. price"]  as! String
                setPrice.removeLast(2)
                stockDetailViewModel.currentPrice = "$\(setPrice)"
                
                setPrice = tickerData["09. change"] as! String
                setPrice.removeLast(2)
                stockDetailViewModel.priceChange = setPrice
                stockDetailViewModel.percentageChange = tickerData["10. change percent"] as! String
                                
            case .tickerIntraday:
                //Keep from nil errors
                guard let _ = parsedResult["Time Series (5min)"] else {
                    loaded(false, "Results returned empty.")
                    return
                }
                //Needed keys:
                //Intervals
                //"1. open" = current price at that interval
               
                //get initial intervals
                let intervals = parsedResult["Time Series (5min)"] as! [String: [String: AnyObject]]
                
                //need to sorted before loaded because they are in an unsorted hash table dictionary
                let sortedIntervals = Array(intervals.keys).sorted(by: <)
                var intervalsToBeSaved = [CGFloat]()
                
                var segmentTracker = 0
                var segments = [Int]()
                
                //keeps keys sorted for loading
                for interval in sortedIntervals {
                    
                    if let nFloatInterval = intervals[interval] {
                        let newFloatInterval = (nFloatInterval["1. open"] as! NSString).floatValue
                        intervalsToBeSaved.append(CGFloat(newFloatInterval))
                    }
               
                    //This creates the graph segments for the interactive graph
                    if segmentTracker == 0 {
                        segments.append(segmentTracker)
                    }
                    segmentTracker += 1
                    if segmentTracker % 2 == 0 && segmentTracker < sortedIntervals.count-2 {
                        segments.append(segmentTracker)
                    }
                    
                }

                stockDetailViewModel.historicalPriceChartInfo[.oneDay] = intervalsToBeSaved
                stockDetailViewModel.chartSegments[.oneDay] = segments
            
            case .tickerDailyExtended:
                //Keep from nil errors
                guard let _ = parsedResult["Time Series (Daily)"] else {
                    loaded(false, "Results returned empty.")
                    return
                }
                
                //Needed keys:
                //Intervals
                //"1. open" = current price at that interval
               
                //get initial intervals
                let intervals = parsedResult["Time Series (Daily)"] as! [String: [String: AnyObject]]
                
                //need to sorted before loaded because they are in an unsorted hash table dictionary
                let sortedIntervals = Array(intervals.keys).sorted(by: >)
                var intervalsToBeSaved = [CGFloat]()
                
                var segmentTracker = 0
                var segments = [Int]()
                
                //keeps keys sorted for loading
                for interval in sortedIntervals {
                    
                    if let nFloatInterval = intervals[interval] {
                        let newFloatInterval = (nFloatInterval["1. open"] as! NSString).floatValue
                        intervalsToBeSaved.append(CGFloat(newFloatInterval))
                    }
                    
                    //This creates the graph segments for the interactive graph
                    if segmentTracker == 0 {
                        segments.append(segmentTracker)
                    }
                    segmentTracker += 1
                    if segmentTracker % 2 == 0 && segmentTracker < intervalsToBeSaved.count-2 {
                        segments.append(segmentTracker)
                    }
                    
                    //for 1 week
                    if intervalsToBeSaved.count == 8 {
                        stockDetailViewModel.historicalPriceChartInfo[.oneWeek] = intervalsToBeSaved
                        stockDetailViewModel.chartSegments[.oneWeek] = segments
                    }
                    
                    //for 1 month
                    if intervalsToBeSaved.count == 32 {
                        stockDetailViewModel.historicalPriceChartInfo[.oneMonth] = intervalsToBeSaved
                        stockDetailViewModel.chartSegments[.oneMonth] = segments
                    }
                    
                    //for 3 months
                    if intervalsToBeSaved.count == 90 {
                        stockDetailViewModel.historicalPriceChartInfo[.threeMonths] = intervalsToBeSaved
                        stockDetailViewModel.chartSegments[.threeMonths] = segments
                    }
                    
                    //for 1 year
                    if intervalsToBeSaved.count == 366 {
                        stockDetailViewModel.historicalPriceChartInfo[.oneYear] = intervalsToBeSaved
                        stockDetailViewModel.chartSegments[.oneYear] = segments
                    }
                    
                    //for 5 years
                    if intervalsToBeSaved.count == 1830 {
                        stockDetailViewModel.historicalPriceChartInfo[.fiveYears] = intervalsToBeSaved
                        stockDetailViewModel.chartSegments[.fiveYears] = segments
                        
                        break
                    }
                    
                }
                
            }
            loaded(true, "GOOD")
        }
        task.resume()
    }
    
    //MARK: - Main API call that will get full data for a certain stock.
    
    ///Calls WebAPI for all needed data in cascaded fashion. Will return complete once all data has been filled.
    func completeAPICall(_ ticker: String, _ allGood: @escaping(_ good: Bool) -> Void) {
        callWebAPI(ticker, .tickerName) { good, error in
            if good {
                callWebAPI(ticker, .tickerPriceDetail) { good, error in
                    if good {
                        callWebAPI(ticker, .tickerIntraday) { good, error in
                            if good {
                                callWebAPI(ticker, .tickerDailyExtended) { good, error in
                                    if good {
                                        allGood(true)
                                    } else {
                                        allGood(false)
                                    }
                                }
                            } else {allGood(false)}
                        }
                    } else {allGood(false)}
                }
            } else {allGood(false)}
        }
    }
    
}


