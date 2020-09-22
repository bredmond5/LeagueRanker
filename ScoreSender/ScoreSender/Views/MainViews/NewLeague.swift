//
//  NewLeague.swift
//  ScoreSender
//
//  Created by Brice Redmond on 5/13/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct NewLeague: View {
    @EnvironmentObject var session: FirebaseSession
    @Binding var isPresented: Bool
        
    @State var leagueName: String = ""
    
    @State var leagueImage: UIImage = UIImage()
    @State var isShowingImagePicker = false
    
    @State var showingAlert = false
    
    let width: CGFloat = 110
    
    @State var isPresentingModal: Bool = false
    
    @State var alertMessage = "" {
        didSet {
            self.showingAlert = true
        }
    }
    
    enum SheetType {
          case imagePick
          case imageCrop
          case share
   }
   
   @State var currentSheet: SheetType = .imagePick

   @State var imageIn: UIImage?
       

    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            Text("New League")
                .fontWeight(.heavy)
                .font(.system(size: 32))
                
            Divider()
            
            GetImage(initialImage: Constants.defaultLeaguePhoto, resizePercentage: 0.2, imageViewSize: 150, userChoseImage: { image in
                self.imageIn = image
            })
        
            Divider()
            
            VStack {
                TextField("League Name", text: $leagueName) {
                    UIApplication.shared.endEditing()
                }
                    .padding(.all, 12)
                    .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
            }
            
            
            Button(action: addButton) {
                SpanningLabel(color: .green, content: "Add")
            }.alert(isPresented: self.$showingAlert, content: {
                Alert(title: Text(self.alertMessage))
            }).sheet(isPresented: $isPresentingModal, content: {
                DisplayNameAndPhoto(username: self.session.session!.realName!, image: self.session.session!.image, isPresented: self.$isPresentingModal, title: self.leagueName, userFinished: { displayName, image, userFinished in
                    self.session.uploadLeague(leagueName: self.leagueName, leagueImage: self.leagueImage, creatorDisplayName: displayName, playerImage: image, completion: { error in
                        userFinished(error)
                        if error == nil {
                            self.isPresented = false
                        }
                    })
                })
            })
            
                        
            Button(action: cancelButton) {
                SpanningLabel(color: .red, content: "Cancel")
            
            }
            
            
//            NavigationLink(destination: DisplayNameAndPhoto(session: self._session, username: self.session.session!.realName!, image: self.session.session!.image, userFinished: { displayName, image, userFinished in
//                    self.session.uploadLeague(leagueName: self.leagueName, leagueImage: self.leagueImage, creatorDisplayName: displayName, playerImage: image, completion: { error in
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
    
    func addButton() {
        if self.leagueName != "" {
            if let error = session.checkLeagueNameAvailable(name: self.leagueName) {
                self.alertMessage = error.localizedDescription
                return
            }
            self.isPresentingModal = true
        }
    }
    
    func cancelButton() {
        self.isPresented = false
    }
}

