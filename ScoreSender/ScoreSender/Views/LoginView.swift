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
import Combine

struct LoginView: View {
    
    //MARK: Properties
    @State var phoneNumber: String = ""
//    @State var phoneNumbe2: String = ""

    @State var buttonDisabled = false
    @State var firstTime = true
    @State var keyboardHeight: CGFloat = 0
    
    @State private var activeSheet: ActiveSheet = .first {
        didSet {
            if activeSheet == .first {
                self.isShowingAlert = false
            }
        }
    }
    
    @State var error: Error? {
        didSet {
            self.activeSheet = .third
        }
    }
    
    @State var isFirstResponder: Bool? = false
//    @State var nextResponder: Bool? = false

    
    @State var isShowingAlert = false
    @EnvironmentObject var session: FirebaseSession
    
    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            Divider().padding(.bottom, 20)
//            Spacer()
            HStack (spacing: 16) {
                Text("Phone Number")
                    .frame(width: 80, alignment: .leading)
                CustomTextField(text: $phoneNumber,
                                nextResponder: .constant(nil),
                                isResponder: $isFirstResponder,
                                keyboard: .numberPad,
                                placeholder: "6505551234")
                    
                    .padding(12)
                    .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
                        .frame(height: 30)
                
//                TextField("6505551234", text: $phoneNumber)
//                    .padding(.all, 12)
//                    .overlay(
//                    RoundedRectangle(cornerRadius: 4)
//                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
//                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
//                    .keyboardType(.numberPad)
                if(buttonDisabled) {
                    ActivityIndicator()
                    .frame(width: 40, height: 40)
                }
            }
            
//            CustomTextField(text: $phoneNumbe2,
//            nextResponder: .constant(nil),
//            isResponder: $nextResponder,
//            keyboard: .default,
//            placeholder: "6505551234")
            Button(action: {
                self.isShowingAlert = true
                self.activeSheet = .second
            }) {
                SpanningLabel(color: Color.green, content: "Log In")
            }.disabled(buttonDisabled)
                .padding(.top, 12)
            Spacer()
         
        }
            .alert(isPresented: $isShowingAlert) {
                if activeSheet == .first {
                    return Alert(title: Text("Enter Phone Number"), message: Text("\(Constants.appName) uses your phone number to log in and name to identify players"), dismissButton: .default(Text("Ok")) {
                        self.isFirstResponder = true
                        })
                } else if activeSheet == .second {
                    return Alert(title: Text("Standard Message Rates May Apply"), message: Text("This will send a text message to your phone"), primaryButton: .default(Text("Go"), action: self.logIn), secondaryButton: .destructive(Text("Cancel")) { self.buttonDisabled = false })
                }else{
                    return Alert(title: Text("Error"), message: Text(error?.localizedDescription ?? "Try Again"), dismissButton: .default(Text("Ok")) { self.error = nil })
                }
            }
        .padding(.all, 20)
        .padding(.bottom, keyboardHeight + 30)
        .onReceive(Publishers.keyboardHeight, perform: {self.keyboardHeight = $0})
        .onAppear(perform: {
            if self.firstTime {
                self.isShowingAlert = true
                self.firstTime = false
            }
        })
        
    }

    //MARK: Functions
    func logIn() {
        self.buttonDisabled = true
        let finalPhone = "+1" + phoneNumber
        self.session.login(withPhoneNumber: finalPhone, resignRequired: { error in
            self.error = error
            self.isShowingAlert = true
            self.buttonDisabled = false
        })
    }
}
//
//struct TextFieldAlert<Presenting>: View where Presenting: View {
//
//    @Binding var isShowing: Bool
//    @Binding var text: String
//    let presenting: Presenting
//    let title: String
//
//    var body: some View {
//        GeometryReader { (deviceSize: GeometryProxy) in
//            ZStack {
//                self.presenting
//                    .disabled(self.isShowing)
//                VStack {
//                    Text(self.title)
//                    TextField("", text: self.$text)
//                    Divider()
//                    HStack {
//                        Button(action: {
//                            withAnimation {
//                                self.isShowing.toggle()
//                            }
//                        }) {
//                            Text("Dismiss")
//                        }
//                    }
//                }
//                .padding()
//                .background(Color.white)
//                .frame(
//                    width: deviceSize.size.width*0.7,
//                    height: deviceSize.size.height*0.7
//                )
//                .shadow(radius: 1)
//                .opacity(self.isShowing ? 1 : 0)
//            }
//        }
//    }
//
//}
