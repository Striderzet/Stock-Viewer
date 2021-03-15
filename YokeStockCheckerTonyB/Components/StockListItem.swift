//
//  StockListItem.swift
//  YokeStockCheckerTonyB
//
//  Created by Tony Buckner on 3/6/21.
//

import SwiftUI
import RHLinePlot

//MARK: - Detailed list item for Home View

struct StockListItem: View {
    
    var tickerSymbol: String
    var companyName: String
    var currentPrice: String
    var percentChangeColor: Color
    
    var chartValues: [CGFloat]
    var chartSegments: [Int]
    
    var body: some View {
        
        HStack {
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text(tickerSymbol)
                    //.font(.headline)
                    .font(.system(size: 20.0))
                Text(companyName)
                    //.font(.subheadline)
                    .font(.system(size: 12.0))
                    .truncationMode(.tail)
                    .foregroundColor(.gray)
                    
            }
            
            Spacer()
            
            RHLinePlot(
                values: chartValues,
                occupyingRelativeWidth: 0.8,
                showGlowingIndicator: true,
                lineSegmentStartingIndices: chartSegments,
                activeSegment: 2,
                customLatestValueIndicator: {
                  // Return a custom glowing indicator if you want
                }
            )
            .frame(width: 150, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            Spacer()
            
            Text("\(currentPrice)")
                .frame(width: 85, height: 45, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .background(percentChangeColor)
                .foregroundColor(.white)
                .cornerRadius(10.0)
            
            Spacer()

        }
        
    }
    
}

struct StockListItem_Previews: PreviewProvider {
    static var previews: some View {
        let values: [CGFloat] = [1.0,2.0,3.0,4.0,3.0,2.0,1.0,2.0,3.0,4.0]
        let segments = [0,4,8]
        StockListItem(tickerSymbol: "VIAC", companyName: "Viacom CBS", currentPrice: "$56.89", percentChangeColor: .green, chartValues: values, chartSegments: segments)
    }
}
