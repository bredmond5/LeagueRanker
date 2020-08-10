//
//  AutocompleteCoordinator.swift
//  ScoreSender
//
//  Created by Brice Redmond on 8/1/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct AutocompleteCoordinator: UIViewRepresentable {
   class Coordinator: NSObject, UITextFieldDelegate {

      @Binding var text: String
      @Binding var nextResponder : Bool?
      @Binding var isResponder : Bool?


      init(text: Binding<String>,nextResponder : Binding<Bool?> , isResponder : Binding<Bool?>) {
        _text = text
        _isResponder = isResponder
        _nextResponder = nextResponder
      }

      func textFieldDidChangeSelection(_ textField: UITextField) {
        text = textField.text ?? ""
      }

      func textFieldDidBeginEditing(_ textField: UITextField) {
         DispatchQueue.main.async {
             self.isResponder = true
         }
      }

      func textFieldDidEndEditing(_ textField: UITextField) {
         DispatchQueue.main.async {
             self.isResponder = false
             if self.nextResponder != nil {
                 self.nextResponder = true
             }
         }
      }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
  }

  @Binding var text: String
  @Binding var nextResponder : Bool?
  @Binding var isResponder : Bool?

  var keyboard : UIKeyboardType

  func makeUIView(context: UIViewRepresentableContext<AutocompleteCoordinator>) -> UITextField {
     
    let textField = UITextField(frame: .zero)
//      textField.autocapitalizationType = .none
    
    textField.autocorrectionType = .no
    textField.keyboardType = keyboard
    textField.delegate = context.coordinator
    textField.tintColor = UIColor.gray
//    textField.boldTextColor = UIColor.black
//    textField.lightTextColor = UIColor.gray
    textField.autocapitalizationType = UITextAutocapitalizationType.none
    return textField
  }

  func makeCoordinator() -> AutocompleteCoordinator.Coordinator {
      return Coordinator(text: $text, nextResponder: $nextResponder, isResponder: $isResponder)
  }

  func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<AutocompleteCoordinator>) {
       uiView.text = text
       if isResponder ?? false {
           uiView.becomeFirstResponder()
       }
  }

}
