//
//  GameForm.swift
//  ScoreSender
//
//  Created by Brice Redmond on 5/11/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI
import Combine
import FirebaseDatabase


struct GameForm: View {
    @EnvironmentObject var session: FirebaseSession
        
    @State private var keyboardHeight: CGFloat = 0
    
    @ObservedObject var curLeague: League
    
    @State var showingAlert = false
    
    @State var errorTitle = ""
    @State var errorMessage = ""
    @State var shouldDismiss = false
        
//    @ObservedObject var textFieldsController = TextFieldsController(numResponders: 6)
        
    
    var datasource: [String: String] {
        return curLeague.datasourceForAutocomplete()
    }
    
    func makeAutoCompleteTextField(text: Binding<String>, placeholder: String, isResponder: Binding<Bool?>, nextResponder: Binding<Bool?>) -> AutoCompleteTextFieldSwiftUI {
        
        return AutoCompleteTextFieldSwiftUI(text: text, placeholder: placeholder, datasource: datasource, isResponder: isResponder, nextResponder: nextResponder)
    }
    
    let inputter: String
    
    var completion: (Bool) -> ()
    
    @State var p1: String = ""
    @State var p2: String = ""
    @State var p3: String = ""
    @State var p4: String = ""
    @State var score1: String = ""
    @State var score2: String = ""
    
    @State var firstResponder: Bool? = true
    @State var secondResponder: Bool? = false
    @State var thirdResponder: Bool? = false
    @State var fourthResponder: Bool? = false
    @State var fifthResponder: Bool? = false
    @State var sixthResponder: Bool? = false
    
    var width: CGFloat = 80
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        ScrollView(.vertical) {
        VStack (alignment: .leading, spacing: 16) {
            
            HStack (spacing: 16) {
                Text("Player 1")
                    .frame(width: width, alignment: .leading)
                makeAutoCompleteTextField(text: self.$p1, placeholder: "username", isResponder: self.$firstResponder, nextResponder: self.$secondResponder)
                .padding(.all, 12)
               .overlay(
               RoundedRectangle(cornerRadius: 4)
                   .strokeBorder(style: StrokeStyle(lineWidth: 1))
                   .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))

            }
            HStack (spacing: 16) {
                Text("Player 2")
                    .frame(width: width, alignment: .leading)
                makeAutoCompleteTextField(text: self.$p2, placeholder: "username", isResponder: self.$secondResponder, nextResponder: self.$thirdResponder)
                .padding(.all, 12)
                .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1))
                    .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
            }
            
            HStack(spacing: 16) {
                Text("Score")
                    .frame(width: width, alignment: .leading)
                CustomTextField(text: $score1,
                                nextResponder: self.$fourthResponder,
                                isResponder: self.$thirdResponder,
                                keyboard: .numbersAndPunctuation,
                                placeholder: "Score 1")
                .frame(alignment: .center)
                .padding(.all, 12)
                .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1))
                    .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
        
                Text("-")
                    .frame(width: 25, alignment: .center)
                
                CustomTextField(text: $score2,
                                nextResponder: self.$fifthResponder,
                                isResponder: self.$fourthResponder,
                                keyboard: .numbersAndPunctuation,
                                placeholder: "Score 2")
                .frame(alignment: .center)
                .padding(.all, 12)
                .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1))
                    .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
            }
            
            HStack (spacing: 16) {
                Text("Player 3")
                    .frame(width: width, alignment: .leading)
                makeAutoCompleteTextField(text: self.$p3, placeholder: "username", isResponder: self.$fifthResponder, nextResponder: self.$sixthResponder)
                .padding(.all, 12)
                .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1))
                    .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))

            }
           
           HStack (spacing: 16) {
               Text("Player 4")
                   .frame(width: width, alignment: .leading)
            makeAutoCompleteTextField(text: self.$p4, placeholder: "username", isResponder: self.$sixthResponder, nextResponder: .constant(nil))
            .padding(.all, 12)
            .overlay(
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(style: StrokeStyle(lineWidth: 1))
                .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))

           }
            
            Button(action: self.addGame, label: {
                HStack {
                    Spacer()
                    Text("Add")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                    
                    Spacer()
                }
            })
            .background(Color.green)
            .cornerRadius(4)
            
            Button(action: {
                self.finished(didUploadGame: false)
            }, label: {
                HStack {
                    Spacer()
                    Text("Cancel")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                    
                    Spacer()
                }
            })
            .background(Color.red)
            .cornerRadius(4)
            
            Spacer()
            
        }.padding(.all, 20)
            .padding(.bottom, keyboardHeight)
            .onReceive(Publishers.keyboardHeight, perform: {self.keyboardHeight = $0})
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(self.errorTitle), message: Text(self.errorMessage), dismissButton: .default(Text("Ok")) {
                    if self.shouldDismiss { // this is for if there was an error uploading the game but it still potentially uploaded
                        self.finished(didUploadGame: true)
                    }
                })
            }
        }
    }
    
    func addGame() {
                    
             // pull rankings from online in case someone has entered a game
             // even though not getting images or games this still takes a lot of data
        self.session.uploadGame(curLeague: self.curLeague, players: [self.p1, self.p2, self.p3, self.p4], scores: [score1, score2], inputter: self.inputter, completion: { error in
            
             if let error = error {
                self.errorTitle = error.localizedDescription
                self.shouldDismiss = false
                self.showingAlert = true
             } else {
                self.finished(didUploadGame: true)
            }
         })
    }
    
    func finished(didUploadGame: Bool) {
        self.mode.wrappedValue.dismiss()
        completion(didUploadGame)
    }
}

extension Binding where Value: MutableCollection, Value.Index == Int {
    func element(_ idx: Int) -> Binding<Value.Element> {
        return Binding<Value.Element>(
            get: {
                return self.wrappedValue[idx]
        }, set: { (value: Value.Element) -> () in
            self.wrappedValue[idx] = value
        })
    }
}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}

extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}

//class TextFieldsController: ObservableObject {
//    @Published var isResponders = [BoolStruct]()
//
//    init(numResponders: Int) {
//        isResponders.append(BoolStruct(id: 0, isResponder: true))
//        for i in 1..<numResponders {
//            isResponders.append(BoolStruct(id: i, isResponder: false))
//        }
//    }
//}
//
//struct BoolStruct: Identifiable {
//    var id: Int
//    var isResponder: Bool
//}

