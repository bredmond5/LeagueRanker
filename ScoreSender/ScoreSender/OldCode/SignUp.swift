//
//  Signup.swift
//  ScoreSender
//
//  Created by Brice Redmond on 5/11/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

//import SwiftUI
//
//struct SignUp: View {
//    
//    @State private var email: String = ""
//    @State private var password: String = ""
//        
//    @EnvironmentObject var session: FirebaseSession
//    
//    var body: some View {
//        Group {
//            VStack (alignment: .leading, spacing: 16){
//                Divider().padding(.bottom, 20)
//                 HStack (spacing: 16) {
//                   Text("Email")
//                       .frame(width: 80, alignment: .leading)
//                   TextField("Email", text: $email)
//                       .padding(.all, 12)
//                       .overlay(
//                       RoundedRectangle(cornerRadius: 4)
//                           .strokeBorder(style: StrokeStyle(lineWidth: 1))
//                           .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
//               }
//               
//               HStack (spacing: 16) {
//                   Text("Password")
//                       .frame(width: 80, alignment: .leading)
//                   SecureField("Password", text: $password)
//                       .padding(.all, 12)
//                       .overlay(
//                       RoundedRectangle(cornerRadius: 4)
//                           .strokeBorder(style: StrokeStyle(lineWidth: 1))
//                           .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
//               }
//                
//                
//                Button(action: signUp) {
//                    SpanningLabel(color: .green, content: "Sign Up")
//                }
//                Spacer()
//            }
//        }
//        .padding(.all, 20)
//    }
//    
//    func signUp() {
//        if !email.isEmpty && !password.isEmpty{
//            session.signUpEmail(email: email, password: password) { (result, error) in
//                if error != nil {
//                    print(error ?? "")
//                }
//            }
//        }
//    }
//}

