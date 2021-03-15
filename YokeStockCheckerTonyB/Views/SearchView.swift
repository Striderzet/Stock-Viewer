//
//  SearchView.swift
//  YokeStockCheckerTonyB
//
//  Created by Tony Buckner on 3/6/21.
//

import SwiftUI

//MARK: - Search view that will return closest matches to your search query.

struct SearchView: View {
    
    @State private var searchBarText: String = ""
    @State private var searchAction: Bool = false
    @State private var ticker: String = ""
    @State private var goTo: Bool = false
    
    ///Checks if method ran in "onAppear" runs only once. Apple knows this is a glitch in SwiftUI.
    @State private var onAppearFlag: Bool = false
    
    //Binding for alert when service is down
    @State private var triggerAlert: Bool = false
    
    //Progress View Flag
    @State private var progressFlag: Bool = false
    
    var body: some View {
        
        ZStack{
            
            NavigationView {
                
                List {
                    
                    HStack {
                        
                        SearchBar(text: $searchBarText, disableList: $searchAction)
                        
                        Button(action: {
                            setHaptic(strength: .soft)
                            
                            //This going to call the api and populate the search text, then we will get results on the bottom
                            APICalls.shared.callWebAPI(searchBarText, .plainSearch) { good, error  in
                                if good {
                                    searchAction = true
                                } else {
                                    //trigger alert
                                    triggerAlert.toggle()
                                }
                            }
                        }, label: {
                            Text("Go")
                        }).disabled(searchBarText.isEmpty)
                        
                        Spacer()
                    }
                    
                    //These will get populated after API is ran and results received.
                    if searchAction && !searchBarText.isEmpty{
                        
                        ForEach(stockDetailViewModel.searchResults.sorted(by: >), id: \.key) { key, value in
                            Button(action: {
                                setHaptic(strength: .soft)
                                progressFlag.toggle()
                                
                                APICalls.shared.completeAPICall(key) { good in
                                    if good {
                                        progressFlag.toggle()
                                        goTo.toggle()
                                    } else {
                                        //trigger alert
                                        triggerAlert.toggle()
                                    }
                                }
                                
                            }, label: {
                                VStack(alignment: .leading) {
                                    Text(key).fontWeight(.heavy)
                                    Text(value).fontWeight(.light)
                                }
                               
                            })
                        }
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
                .alert(isPresented: $triggerAlert, content: {
                    Alert(title: Text("Uh Oh!"), message: Text("Info could not be pulled. You may need to wait and try again."), dismissButton: Alert.Button.default(Text("OK"), action: {progressFlag.toggle()}))
                })
                
                
                .navigationTitle("Search")
                
                
            }
            
            //Show loading screen
            if progressFlag {
                LoadingView()
            }
            
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
