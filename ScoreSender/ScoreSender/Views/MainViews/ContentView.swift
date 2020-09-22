//
//  ContentView.swift
//  ScoreSender
//
//  Created by Brice Redmond on 4/7/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//  Credit to Brian Voong

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var session: FirebaseSession
        
    var body: some View {
        NavigationView {
            Group {
                if session.session != nil {
                    LeaguesScrollerVertical(session: _session)
                    
                }else{
                    LoginView(session: _session)
                    .navigationBarTitle(Constants.appName)
                    .navigationBarItems(leading: Text(""), trailing: Text(""))
               }
            }
        }
        .padding()
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
            ContentView()
    }
}
