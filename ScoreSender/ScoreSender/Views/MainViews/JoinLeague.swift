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
    @EnvironmentObject var session: FirebaseSession
    @Binding var isPresented: Bool

    @State var leagueName: String = ""
    @State var creatorPhone: String = ""
        
    @State var isPresentingModal: Bool = false
    @State var leagueID: String?
    
    @State var showingAlert = false
    @State var alertMessage = "" {
        didSet {
            self.showingAlert = true
        }
    }
        
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
            
            Button(action: addButton) {
                SpanningLabel(color: .green, content: "Add")
            }.alert(isPresented: self.$showingAlert, content: {
                Alert(title: Text(self.alertMessage))
            })
            
            Button(action: self.addButton) {
                SpanningLabel(color: .green, content: "Add")
            }.alert(isPresented: self.$showingAlert, content: {
                Alert(title: Text(self.alertMessage))
            })
            
            Button(action: cancelButton) {
                SpanningLabel(color: .red, content: "Cancel")
            }
            
            Button(action: addButton) {
                SpanningLabel(color: .green, content: "Add")
            }.alert(isPresented: self.$showingAlert, content: {
                Alert(title: Text(self.alertMessage))
            }).sheet(isPresented: $isPresentingModal, content: {
                DisplayNameAndPhoto(username: self.session.session!.realName!, image: self.session.session!.dbImage.image, isPresented: self.$isPresentingModal, title: self.leagueName, userFinished: { displayName, image, userFinished in
                    self.session.joinLeague(leagueID: self.leagueID!, displayName: displayName, image: image, completion: {error in
                        userFinished(error)
                        if error == nil {
                            self.isPresented = false
                        }
                    })
                })
            })
            
//            NavigationLink(destination: DisplayNameAndPhoto(username: self.session.session!.realName!, image: self.session.session!.image, userFinished: { displayName, image, userFinished in
//                self.session.joinLeague(league: self.league!, displayName: displayName, image: image, completion: {error in
//                        userFinished(error)
//                        if error == nil {
//                            self.isPresented = false
//                        }
//                    })
//                }
//            ), isActive: $isPresentingModal) {
//                Text("")
//            }
            
            Spacer()

        }.padding(.all, 30)
    }
    
    func cancelButton() {
        self.isPresented = false
    }
    
    func addButton() {
        if self.leagueName == "" || self.creatorPhone == "" {
            self.alertMessage = "Both the phone number and the league name must be filled"
            return
        }
        
        let phoneNumber = "+1" + self.creatorPhone
        
        if phoneNumber == self.session.session!.phoneNumber {
            self.alertMessage = "You entered your own phone number"
            return
        }
        
        session.findLeague(leagueName: self.leagueName, phoneNumber: phoneNumber, completion: { error, id, rejoinRequired in
            if let error = error {
                self.alertMessage = error.localizedDescription
                return
            }
            
            guard let id = id else {
                self.alertMessage = "Error finding league"
                return
            }
            
            if rejoinRequired {
                self.session.rejoinLeague(leagueID: id, completion: { error in
                    if let error = error {
                        self.alertMessage = error.localizedDescription
                    }
                })
            } else {
                self.leagueID = id
                self.isPresentingModal = true
                
            }
        })
    }
    
    func getDisplayNameAndPhoto(league: League, creatorPhoneNumber: String) {

        
//        self.displayNameAndPhoto = DisplayNameAndPhoto(session: self._session, username: self.session.session!.realName!, image: self.session.session!.image, isPresented: self.$isPresentingModal, userFinished: { displayName, image, userFinished in
//            self.session.joinLeague(league: league, displayName: displayName, image: image, completion: {error in
//                userFinished(error)
//            })
//        }, completion: {
//            self.isPresented = false
//        })
    }
}
