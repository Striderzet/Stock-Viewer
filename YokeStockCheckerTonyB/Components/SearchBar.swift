//
//  SearchBar.swift
//  YokeStockCheckerTonyB
//
//  Created by Tony Buckner on 3/6/21.
//

import Foundation
import SwiftUI
import UIKit

//MARK: - This search bar needed to be custom made because SwiftUI does not contain one like UIKit does. There have been some added features specifically for this app.

///Custom Search Bar made for SwiftUI.
struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    @Binding var disableList: Bool
    
    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String
        @Binding var disableList: Bool
        
        init(text: Binding<String>, disableList: Binding<Bool>) {
            _text = text
            _disableList = disableList
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            if text.isEmpty {
                stockDetailViewModel.searchResults.removeAll()
                disableList = false
            }
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, disableList: $disableList)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
