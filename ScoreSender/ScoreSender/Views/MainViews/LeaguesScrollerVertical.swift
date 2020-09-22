//
//  LeaguesScrollerVertical.swift
//  ScoreSender
//
//  Created by Brice Redmond on 7/30/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI
import FirebaseDatabase

struct LeaguesScrollerVertical: View {
    
    @EnvironmentObject var session: FirebaseSession
    
    @State var leagueTest: League?
    @State var playerTest: PlayerForm?
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 74){
            Button(action: {
                if self.leagueTest != nil {
                    self.leagueTest = nil
                } else {
                    self.leagueTest = League(id: UUID(uuidString: "69C23B7D-90A2-44A5-865B-5E20648758DE")!)
                }
            }) {
                Text("set up league")
            }
            Button(action: {
                if self.playerTest != nil {
                    self.playerTest = nil
                } else {
                    self.playerTest = PlayerForm(ref: Database.database().reference(withPath: "leagues/69C23B7D-90A2-44A5-865B-5E20648758DE/players/objects/+16505557777"), leagueID: "69C23B7D-90A2-44A5-865B-5E20648758DE")
                }
            }) {
                Text("set up player")
            }
            List(self.session.leagues) { league in
                NavigationLink(destination: CurLeague(curLeague: league))
                {
//                    LeagueRow(leagueSettings: league.leagueSettings)
                    Text(league.name)
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
