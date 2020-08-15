//
//  SearchBar.swift
//  ScoreSender
//
//  Created by Brice Redmond on 7/1/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

//import SwiftUI
//
//struct SearchBar: UIViewRepresentable {
//    
//    @Binding var text: String
//    
//    
//    class Coordinator: NSObject, UISearchBarDelegate {
//        @Binding var text: String
//        
//        init(text: Binding<String>) {
//            _text = text
//        }
//        
//        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//            text = searchText
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(text: $text)
//    }
//    
//    func makeUIView(context: Context) -> some UIView {
//        let searchBar = UISearchBar(frame: .zero)
//        searchBar.delegate = context.coordinator
//        return searchBar
//    }
//    
//    func updateUIView(_ uiView: UISearchBar, context: Context) {
//        uiView.text = text
//    }
//}
