//
//  LeaguesScrollerVertical.swift
//  ScoreSender
//
//  Created by Brice Redmond on 7/30/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct LeaguesScrollerVertical: View {
    
    @EnvironmentObject var session: FirebaseSession
    
//    @State var showingAlert = false
    
    
    var body: some View {
        VStack (alignment: .leading, spacing: 74){
            List(self.session.leagues) { league in
                NavigationLink(destination: CurLeague(curLeague: league, didUploadLeague: { league, game, newRatings in
                    self.session.uploadGame(curLeague: league, game: game, newRatings: newRatings)
                }).navigationBarTitle(league.name))
                {
                    LeagueRow(league: league)
                }
            } 
        }
        .navigationBarTitle("My Leagues")
        .navigationBarItems(leading: NavigationLink(destination: SettingsFormOverall().navigationBarTitle("Settings")) {
            Image(systemName: "text.justify")
            .resizable()
            .frame(width: 20, height: 20)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .foregroundColor(.blue)
//                Text("Settings")
//                .fontWeight(.bold)
//                .foregroundColor(.white)
//                .padding(.vertical, 8)
//                .padding(.horizontal, 12)
//                .background(Color.gray)
//                .cornerRadius(4)
        },trailing: AddLeague())
        .onAppear(perform: getDisplayName)
        
    }
    
    func getDisplayName() {
        if self.session.session!.displayName == nil || self.session.session!.displayName == ""{
            MyAlerts().showTextInputPromptNoCancel(placeholder: "John", title: "Success!", message: "Enter your real first name", keyboardType: UIKeyboardType.default, callback: { displayName in
                if(displayName == "") {
                    self.getDisplayName()
                }else{
                    self.session.changeUser(displayName: displayName, image: nil)
                }
            })
        }
    }
    
}

struct LeaguesScrollerVertical_Previews: PreviewProvider {
    static var previews: some View {
        LeaguesScrollerVertical()
    }
}
