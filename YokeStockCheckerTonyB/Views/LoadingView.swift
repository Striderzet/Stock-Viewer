//
//  LoadingView.swift
//  YokeStockCheckerTonyB
//
//  Created by Tony Buckner on 3/9/21.
//

//MARK: Loading view for start of app and API calls

import SwiftUI

struct LoadingView: View {
    
    var body: some View {
        
        ZStack() {
            Color(.systemBackground)
                .ignoresSafeArea()
                .opacity(0.8)
                    
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                .scaleEffect(6.0)
            
            Text("Loading. May take up to 5 mins due to API Call restrictions.")
                .position(x: 200, y: 500)
                
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
