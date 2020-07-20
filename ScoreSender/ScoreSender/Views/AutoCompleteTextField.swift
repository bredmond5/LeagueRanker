import UIKit
import SwiftUI
 
 struct AutoCompleteTextFieldSwiftUI: UIViewRepresentable, AutoCompleteTextFieldDelegate {
    @EnvironmentObject var session: FirebaseSession
    @Binding var text: String
    let playerNumber: Int
    typealias UIViewType = UITextField
    
    var textfield: AutoCompleteTextField = {
        let textfield = AutoCompleteTextField()
        textfield.tintColor = UIColor.gray
        textfield.boldTextColor = UIColor.black
        textfield.lightTextColor = UIColor.gray
        return textfield
    }()
        
    mutating func provideDatasource() {
        let players = session.curLeague.returnPlayers()
        var datasource: [String] = []
        for player in players {
            datasource.append(player.displayName)
        }
        textfield.datasource = datasource
    }
    
    mutating func returned(with selection: String) {
        self.text = selection
    }
    
    mutating func textFieldCleared() {
        self.text = ""
    }
    
    func makeUIView(context: Context) -> UITextField {
        let tf = textfield
        tf.autocompleteDelegate = self
//        tf.placeholder = "Player \(playerNumber)"
        tf.placeholder = "Username"
        return tf
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
    }

 }

 protocol AutoCompleteTextFieldDelegate {
     mutating func provideDatasource()
     mutating func returned(with selection: String)
     mutating func textFieldCleared()
 }

 final class AutoCompleteTextField: UITextField, UIViewRepresentable {
    func makeUIView(context: Context) -> UITextField {
        return self
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
    }
    
    typealias UIViewType = UITextField
    
     var datasource: [String]?
     
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
         
         let allOptions = datasource.filter({ $0.hasPrefix(self.currInput) })
         let exactMatch = allOptions.filter() { $0 == self.currInput }
         let fullName = exactMatch.count > 0 ? exactMatch.first! : allOptions.first ?? self.currInput
         if let range = fullName.range(of: self.currInput) {
            let nsRange = NSRange(String(fullName.suffix(from: range.upperBound)))
             let attribute = NSMutableAttributedString.init(string: fullName as String)
            attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: self.boldTextColor, range: nsRange ?? NSRange())
             textField.attributedText = attribute
         }
    }
     
     private func updateCursorPosition(in textField: UITextField) {
         if let newPosition = textField.position(from: textField.beginningOfDocument, offset: self.currInput.count) {
             textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
         }
     }
     
     func textFieldDidEndEditing(_ textField: UITextField) {
         resignFirstResponder()
         if !isReturned {
             textField.text = ""
             self.currInput = ""
         } else {
             textField.textColor = boldTextColor
         }
     }
     
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         self.autocompleteDelegate?.returned(with: textField.text!)
         self.isReturned = true
         self.endEditing(true)
         return true
     }
 }

 extension String {
//     func nsRange(from range: Range<Index>) -> NSRange {
//         return NSRange(range, in: self)
//     }
 }
