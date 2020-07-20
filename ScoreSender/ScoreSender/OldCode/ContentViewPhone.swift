////
////  ContentViewPhone.swift
////  ScoreSender
////
////  Created by Brice Redmond on 6/5/20.
////  Copyright © 2020 Brice Redmond. All rights reserved.
////
//
//import SwiftUI
//
//struct ContentViewPhone: View {
//    @EnvironmentObject var session: FirebaseSessionPhone
//
//    @State var phoneNumber: String = ""
//    
//    var body: some View {
//        VStack (alignment: .leading, spacing: 16) {
//         Divider().padding(.bottom, 20)
//         HStack (spacing: 16) {
//             Text("Phone Number")
//                 .frame(width: 80, alignment: .leading)
//             TextField("", text: $phoneNumber)
//                 .padding(.all, 12)
//                 .overlay(
//                 RoundedRectangle(cornerRadius: 4)
//                     .strokeBorder(style: StrokeStyle(lineWidth: 1))
//                     .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
//         }
//         
//         
//         Button(action: self.login) {
//             SpanningLabel(color: Color.green, content: "Log In")
//         }
//        
//
//         NavigationLink(destination: SignUp().navigationBarTitle("Sign Up")) {
//             SpanningLabel(color: Color.blue, content: "Sign Up")
//         }
//
//         Spacer()
//        }
//        .onAppear(perform: getUser)
//        .onDisappear(perform: stop)
//        .navigationBarTitle(Text("Shithaus Die"))
//        .padding()
//    }
//    
//
//            
//    func getUser() {
//        session.listen()
//    }
//    
//    func stop() {
//        session.stopListening()
//    }
//}
