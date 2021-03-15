//
//  StockDetailView.swift
//  YokeStockCheckerTonyB
//
//  Created by Tony Buckner on 3/6/21.
//

import SwiftUI
import RHLinePlot
import Foundation
import UIKit
import Combine

//MARK: - View for full stock detail view with slidable price checking and 6 time interval choices.

struct StockDetailView: View {
    
    //Population Items
    var ticker: String
    var fullName: String
    var price: String
    var priceChange: String
    var percentageChange: String
    var chartValues: [ChartIntervals: [CGFloat]]
    var chartSegments: [ChartIntervals: [Int]]
    
    @State private var setInterval: ChartIntervals = ChartIntervals.oneDay
    
    //Button Labels and Flags
    @State private var buttonId = ["1D", "1W", "1M", "3M", "1Y", "5Y"]
    @State private var buttonOn = [true, false, false, false, false, false]
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .leading) {
                
                //Selected stock labels and info
                Text(fullName)
                    .frame(height: 5)
                    .font(.system(size: 30))
                    .padding()
                Text(price)
                    .frame(height: 5)
                    .font(.system(size: 25))
                    .padding()
                Text("$\(priceChange) (\(percentageChange)%)").foregroundColor(percentageChangeColor(percentageChange))
                    .frame(height: 1)
                    .padding()
                
                //Detailed Interactive Chart
                RHInteractiveLinePlot(
                    values: chartValues[setInterval] ?? [1.0,2.0,3.0,4.0,3.0,2.0,1.0,2.0,3.0,4.0],
                    occupyingRelativeWidth: 0.8,
                    showGlowingIndicator: true,
                    lineSegmentStartingIndices: chartSegments[setInterval] ?? [0,4,8],
                    didSelectValueAtIndex: { index in
                      // Do sth useful with index...
                        
                },
                    customLatestValueIndicator: {
                      // Custom indicator...
                },
                    valueStickLabel: { value in
                      // Label above the value stick...
                        Text(floatConvertToDollar(value))
                        //Text("$\(value)")
                })
                    .frame(height: 400, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .padding()
                    
                
                //Chart Detail Toggle Buttons
                HStack {
                    
                    Spacer()
                    
                    //ForEach(buttonId, id: \.self) { item in
                    ForEach(0..<buttonId.count) { item in
                        
                        Button(action: {
                            setHaptic(strength: .soft)
                            
                            toggleButtonOn(flag: item)
                            
                        }, label: {
                            Text(buttonId[item])
                        })
                        .frame(width: 50)
                        .background(buttonOnColor(isON: buttonOn[item]))
                        .foregroundColor(textOnColor(isON: buttonOn[item]))
                        .cornerRadius(5.0)
                    }
                    Spacer()
                }
            }
            
                .navigationTitle(ticker)
            
        }
        
    }
    
    //MARK: - Methods that must exist here
        
    //shut all the other buttons off visually
    func toggleButtonOn(flag: Int) {
        for i in 0..<buttonOn.count {
            if i != flag {
                buttonOn[i] = false
            } else {
                buttonOn[i] = true
                changeGraph(i, $setInterval)
            }
        }
    }
    
    //change the graph live
    func changeGraph(_ num: Int, _ setInter: Binding<ChartIntervals> ) {
        switch num {
        case 0:
            setInter.wrappedValue = ChartIntervals.oneDay
        case 1:
            setInter.wrappedValue = ChartIntervals.oneWeek
        case 2:
            setInter.wrappedValue = ChartIntervals.oneMonth
        case 3:
            setInter.wrappedValue = ChartIntervals.threeMonths
        case 4:
            setInter.wrappedValue = ChartIntervals.oneYear
        case 5:
            setInter.wrappedValue = ChartIntervals.fiveYears
        default:
            break
        }
    }
    
}

struct StockDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let valueBank: [ChartIntervals: [CGFloat]] =
            [ChartIntervals.oneDay: [1.0,2.0,3.0,4.0,3.0,2.0,1.0,2.0,3.0,4.0],
            ChartIntervals.oneWeek: [CGFloat](),
            ChartIntervals.oneMonth: [CGFloat](),
            ChartIntervals.threeMonths: [CGFloat](),
            ChartIntervals.oneYear: [CGFloat](),
            ChartIntervals.fiveYears: [CGFloat]()]
        
        let segmentBank: [ChartIntervals: [Int]] =
            [ChartIntervals.oneDay: [0,4,8],
            ChartIntervals.oneWeek: [Int](),
            ChartIntervals.oneMonth: [Int](),
            ChartIntervals.threeMonths: [Int](),
            ChartIntervals.oneYear: [Int](),
            ChartIntervals.fiveYears: [Int]()]
     
        StockDetailView(ticker: "GME", fullName: "Game Stop", price: "$52.65", priceChange: "$2", percentageChange: "2%", chartValues: valueBank, chartSegments: segmentBank)
    }
}

