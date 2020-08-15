// credit Tim Beals autocomplete text field

import UIKit
import SwiftUI
 
struct AutoCompleteTextFieldSwiftUI: UIViewRepresentable, AutoCompleteTextFieldDelegate {
    @Binding var text: String
    let placeholder: String
    typealias UIViewType = UITextField
    var datasource: [String: String]
    
    @Binding var isResponder : Bool?
    @Binding var nextResponder : Bool?
        
    var textfield: AutoCompleteTextField = {
        let textfield = AutoCompleteTextField()
        textfield.tintColor = UIColor.gray
        textfield.boldTextColor = UIColor.black
        textfield.lightTextColor = UIColor.gray
        textfield.autocapitalizationType = UITextAutocapitalizationType.none
        return textfield
    }()
        
    func provideDatasource() {
        textfield.datasource = datasource
    }
    
     func returned(with selection: String) {
        self.text = selection

        DispatchQueue.main.async {
            self.isResponder = false
            if self.nextResponder != nil {
                self.nextResponder = true
            }
        }
    }
   
    func textfieldDoneEditing(with selection: String) {
        self.text = selection
        self.isResponder = false
    }
        

    
    func textFieldCleared() {
        self.text = ""
    }
    
    func makeUIView(context: Context) -> UITextField {
        let tf = textfield
        tf.autocompleteDelegate = self
        tf.text = text
//        tf.placeholder = "Player \(playerNumber)"
        tf.placeholder = placeholder
        return tf
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if isResponder ?? false {
            uiView.becomeFirstResponder()
        }
    }

 }

 protocol AutoCompleteTextFieldDelegate {
    func provideDatasource()
    func returned(with selection: String)
    func textFieldCleared()
    func textfieldDoneEditing(with selection: String)
 }

 final class AutoCompleteTextField: UITextField, UIViewRepresentable {
    func makeUIView(context: Context) -> UITextField {
        return self
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
    }
    
    typealias UIViewType = UITextField
    
    var datasource: [String: String]?
     
    var autocompleteDelegate: AutoCompleteTextFieldDelegate?
     
     var lightTextColor: UIColor = UIColor.gray {
         didSet {
             self.textColor = lightTextColor
         }
     }
         
     var boldTextColor: UIColor = UIColor.black
     
     private var currInput: String = ""
     private var isReturned: Bool = false
     
    override init(frame: CGRect) {
        super.init(frame: frame)
         
        self.textColor = lightTextColor
        self.delegate = self
     }
     
     required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
 }

 extension AutoCompleteTextField: UITextFieldDelegate {
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text
     }

     func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
         self.autocompleteDelegate?.provideDatasource()
         self.currInput = ""
         self.isReturned = false
         return true
     }
     
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         updateText(string, in: textField)
         
         testBackspace(string, in: textField)

         findDatasourceMatch(for: textField)

         updateCursorPosition(in: textField)

         return false
     }
     
     private func updateText(_ string: String, in textField: UITextField) {
         textField.textColor = self.lightTextColor
        self.currInput += string
         textField.text = self.currInput
     }
     
     private func testBackspace(_ string: String, in textField: UITextField) {
         let char = string.cString(using: String.Encoding.utf8)
         let isBackSpace: Int = Int(strcmp(char, "\u{8}"))
         if isBackSpace == -8 {
             self.currInput = String(self.currInput.dropLast())
             if self.currInput == "" {
                 textField.text = ""
                 autocompleteDelegate?.textFieldCleared()
             }
         }
     }
     
     private func findDatasourceMatch(for textField: UITextField) {
         guard let datasource = self.datasource else {
            print("no datasource")
            return
            
        }
                 
        let allOptionsUnCased = datasource.keys.filter({ $0.lowercased().hasPrefix(self.currInput.lowercased()) })
        let allOptionsCased = datasource.keys.filter({ $0.hasPrefix(self.currInput) })
        let exactMatch = allOptionsCased.filter() { $0 == self.currInput }
        
        let allOptions = allOptionsCased.count > 0 ? allOptionsCased : allOptionsUnCased
        
        let fullName = exactMatch.count > 0 ? exactMatch.first! : allOptions.first ?? self.currInput
        if let val = datasource[fullName] {
            if let range = fullName.range(of: self.currInput) {
                let nsRange = NSRange(String(val.suffix(from: range.lowerBound)))
                 let attribute = NSMutableAttributedString.init(string: val as String)
                 attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: self.boldTextColor, range: nsRange ?? NSRange())
                 textField.attributedText = attribute
            }else if let range = fullName.lowercased().range(of: self.currInput.lowercased()) {
                let nsRange = NSRange(String(val.suffix(from: range.lowerBound)))
                 let attribute = NSMutableAttributedString.init(string: val as String)
                 attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: self.boldTextColor, range: nsRange ?? NSRange())
                 textField.attributedText = attribute
            }
        } else {
            textField.textColor = .red
        }
    }
     
     private func updateCursorPosition(in textField: UITextField) {
         if let newPosition = textField.position(from: textField.beginningOfDocument, offset: self.currInput.count) {
             textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
         }
     }
     
     func textFieldDidEndEditing(_ textField: UITextField) {
         if !isReturned {
            self.autocompleteDelegate?.textfieldDoneEditing(with: textField.text!)
        }
//             textField.text = ""
//             self.currInput = ""
//         } else {
//         }
        if textField.textColor != .red {
            textField.textColor = boldTextColor
        }
//        self.autocompleteDelegate?.returned(with: textField.text!)

     }
     
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.autocompleteDelegate?.returned(with: textField.text!)
        self.isReturned = true

        self.endEditing(true)
        
//        if let nextField = textField.superview?.superview?.viewWithTag(textField.tag + 1) as? UITextField {
//            print("making next field")
//            nextField.becomeFirstResponder()
//        } else {
//            textField.resignFirstResponder()
//        }
        
        return true
     }
 }
