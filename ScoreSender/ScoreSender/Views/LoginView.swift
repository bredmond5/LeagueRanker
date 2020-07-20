//
//  LoginView.swift
//  ScoreSender
//
//  Created by Brice Redmond on 5/11/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI
import UIKit
import FirebaseAuth


struct LoginView: View {
    
    //MARK: Properties
    @State var phoneNumber: String = "650555"
    
    @State var isShowingMsgAlert = false
    @State var buttonDisabled = false
        
    @EnvironmentObject var session: FirebaseSession
    
    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            Divider().padding(.bottom, 20)
            HStack (spacing: 16) {
                Text("Phone Number")
                    .frame(width: 80, alignment: .leading)
                TextField("6505551432", text: $phoneNumber)
                    .padding(.all, 12)
                    .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
                    .keyboardType(.numberPad)
            }
            
//            HStack (spacing: 16) {
//                Text("Password")
//                    .frame(width: 80, alignment: .leading)
//                SecureField("Password", text: $password)
//                    .padding(.all, 12)
//                    .overlay(
//                    RoundedRectangle(cornerRadius: 4)
//                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
//                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
//            }
            
            
            Button(action: {
                self.isShowingMsgAlert = true
            }) {
                SpanningLabel(color: Color.green, content: "Log In")
            }.disabled(buttonDisabled)
           

//            NavigationLink(destination: SignUp().navigationBarTitle("Sign Up")) {
//                SpanningLabel(color: Color.blue, content: "Sign Up")
//            }

            Spacer()
         
            }.alert(isPresented: $isShowingMsgAlert) {
                Alert(title: Text("Standard Message Rates May Apply"), message: Text("This will send a text message to your phone"), primaryButton: .default(Text("Go"), action: self.logIn), secondaryButton: .destructive(Text("Cancel")) {
                    
                })
            }
        
        .padding(.all, 20)
        
        
    }

    //MARK: Functions
    func logIn() {
        buttonDisabled = true
        let finalPhone = "+1" + phoneNumber
        self.buttonDisabled = false
        self.session.login(withPhoneNumber: finalPhone)
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
