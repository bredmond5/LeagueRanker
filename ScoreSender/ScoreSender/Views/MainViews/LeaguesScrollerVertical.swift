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
                NavigationLink(destination: CurLeague(curLeague: league))
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
        },trailing: AddLeague(session: _session))
        .onAppear(perform: getDisplayName)
        
    }
    
    func getDisplayName() {
        if self.session.session != nil && (self.session.session!.realName == nil || self.session.session!.realName == "") {
            MyAlerts().showTextInputPromptNoCancel(placeholder: "John", title: "Success!", message: "Enter your real first name, must be less than \(Constants.maxCharacterDisplayName)", keyboardType: UIKeyboardType.default, callback: { realName in
                if realName == "" || realName.count > Constants.maxCharacterDisplayName {
                    self.getDisplayName()
                }else{
                    self.session.changeUser(realName: realName, image: nil)
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
