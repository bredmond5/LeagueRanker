//
//  TextFieldAlert.swift
//  ScoreSender
//
//  Created by Brice Redmond on 8/1/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct TextFieldAlert<Presenting>: View where Presenting: View {

    @Binding var isShowing: Bool?
    @Binding var text: String
    let presenting: Presenting
    let title: String
    let message: String
    let placeholder: String
    @State var isResponder: Bool? = true


    var body: some View {
        GeometryReader { (deviceSize: GeometryProxy) in
            ZStack {
                self.presenting
                    .disabled(self.isShowing!)
                VStack {
                    Text(self.title)
                    Text(self.message)
                    CustomTextField(text: self.$text, nextResponder: .constant(nil), isResponder: self.$isShowing, keyboard: .default, placeholder: self.placeholder)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .id(self.isShowing)
                    Divider()
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.isShowing!.toggle()
                            }
                        }) {
                            Text("Dismiss")
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .frame(
                    width: deviceSize.size.width*0.7,
                    height: deviceSize.size.height*0.7
                )
                .shadow(radius: 1)
                    .opacity(self.isShowing! ? 1 : 0)
            }
        }
    }

}

prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}

extension View {

    func textFieldAlert(isShowing: Binding<Bool?>,
                        text: Binding<String>,
                        title: String, message: String, placeholder: String = "") -> some View {
        TextFieldAlert(isShowing: isShowing,
                       text: text,
                       presenting: self,
                       title: title,
                       message: message,
                       placeholder: placeholder
        )
    }

}
