//
//  JoinLeague.swift
//  ScoreSender
//
//  Created by Brice Redmond on 5/14/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI
import FirebaseDatabase

struct JoinLeague: View {
    @Binding var isPresented: Bool
    var user: User

    var didAddLeague: (String, String, String, String, UIImage) -> ()
    @State var leagueName: String = ""
    @State var creatorPhone: String = ""
    
    let myAlerts = MyAlerts()
    
    @State var isPresentingModal = false
    @State var displayNameAndPhoto: DisplayNameAndPhoto?
    @State var username = ""
    @State var image = UIImage()
        
    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            Text("Join League")
                .fontWeight(.heavy)
                .font(.system(size: 32))
                .padding(.all, 10)
            Divider().padding(.bottom, 10)
            
            TextField("Creator Phone Number", text: $creatorPhone)
                    .keyboardType(.numberPad)
                   .padding(.all, 12)
                   .overlay(
                   RoundedRectangle(cornerRadius: 4)
                       .strokeBorder(style: StrokeStyle(lineWidth: 1))
                       .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
                
            
            TextField("League Name", text: $leagueName)
            .padding(.all, 12)
            .overlay(
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(style: StrokeStyle(lineWidth: 1))
                .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
            
            Button(action: self.joinLeague) {
                SpanningLabel(color: .green, content: "Add")
            }.sheet(isPresented: $isPresentingModal, content: {
                self.displayNameAndPhoto!.navigationBarTitle(self.leagueName)
            })
            
            Button(action: cancelButton) {
                SpanningLabel(color: .red, content: "Cancel")
            }
            
            Spacer()

        }.padding(.all, 30)
    }
    
    func cancelButton() {
        self.isPresented = false
    }
    
    func joinLeague() {
        if self.leagueName == "" || self.creatorPhone == "" {
            self.myAlerts.showMessagePrompt(title: "Error", message: "Both the phone number and the league name must be filled", callback: {})
            return
        }
        
        let phoneNumber = "+1" + self.creatorPhone
        
        if phoneNumber == self.user.phoneNumber {
            myAlerts.showMessagePrompt(title: "Error", message: "You entered your own phone number", callback: {})
            return
        }
        
        let creatorRef = Database.database().reference(withPath: "\(phoneNumber)")
        creatorRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                self.myAlerts.showMessagePrompt(title: "Error", message: "\(phoneNumber) is not a user's phone number", callback: {})
                return
            }else{
                let ownedLeaguesRef = creatorRef.child("ownedLeagues")
                ownedLeaguesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    let optional = snapshot.value as? NSDictionary
                    guard let value = optional else {
                        self.myAlerts.showMessagePrompt(title: "Error", message: "Could not find \(phoneNumber)'s data", callback: {})
                        return
                    }
                    var foundLeague = false
                    for each in value {
                        if let localName = each.value as? String {
                            if localName == self.leagueName {
                                foundLeague = true
                                self.getDisplayNameAndPhoto(leagueID: each.key as! String, creatorPhoneNumber: phoneNumber)
                            }
                        }
                    }
                    if !foundLeague {
                        self.myAlerts.showMessagePrompt(title: "Error", message: "\(phoneNumber) does not own a league called \(self.leagueName)", callback: {})
                    }
                })
            }
        })
    }
    
    func getDisplayNameAndPhoto(leagueID: String, creatorPhoneNumber: String) {
        let leagueRef = Database.database().reference(withPath: leagueID)
        leagueRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                self.myAlerts.showMessagePrompt(title: "Error", message: "Could not find league", callback: {})
                return
            }else{
                if let value = snapshot.value as? NSDictionary {
                    if let players = value["players"] as? NSDictionary {
                        if players[self.user.phoneNumber!] != nil {
                            self.myAlerts.showMessagePrompt(title: "Error", message: "You are already a part of this league", callback: {})
                            return
                        } else {
                            // all error checking is finished, hand over to displayNameAndPhoto
                            var usedUsernames: [String] = []
                            if let league = League(snapshot: snapshot, id: snapshot.key) {
                                for player in league.returnPlayers() {
                                    usedUsernames.append(player.displayName)
                                }
                    
                                self.username = self.user.displayName!
                                self.image = self.user.image
                                self.displayNameAndPhoto = DisplayNameAndPhoto(username: self.$username, image: self.$image, isPresented: self.$isPresentingModal, usedUsernames: usedUsernames, callback: { userDidCancel in
                                    if userDidCancel {
                                        self.cancelButton()
                                    }else{
                                        
                                        self.didAddLeague(leagueID, self.leagueName, self.username, creatorPhoneNumber, self.image)
                                        self.isPresented = false
                                    }
                                })
                                self.isPresentingModal = true
                            }
                        }
                    }
                }
            }
        })
    }
}
