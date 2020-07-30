//
//  File.swift
//  ScoreSender
//
//  Created by Brice Redmond on 7/1/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

class MyAlerts {
    public func showMessagePrompt(title: String, message: String, callback: @escaping () -> Void) {
        showAlert(alert: MyAlerts.getShowMessagePrompt(title: title, message: message, callback: callback))
    }
    
    public static func getShowMessagePrompt(title: String, message: String, callback: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            callback()
        })
        
        return alert
    }
    
    public func showCancelOkMessage(title: String, message: String, callback: @escaping (Bool) -> Void) {
        
        showAlert(alert: MyAlerts.getCancelOkMessage(title: title, message: message, callback: callback))
    }
    
    public static func getCancelOkMessage(title: String, message: String, callback: @escaping (Bool) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .destructive) { _ in
            callback(true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in
            callback(false)
        })
        
        return alert
        
    }
    
    public func showTextInputPromptNoCancel(placeholder: String, title: String, message: String, keyboardType: UIKeyboardType, callback: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
        alert.addTextField() { textField in
            textField.placeholder = placeholder
            textField.text = ""
            textField.keyboardType = keyboardType
        }
        
        let action = UIAlertAction(title: "Enter", style: .default) { _ in
            let firstTextField = alert.textFields![0] as UITextField
            let text = firstTextField.text
            callback(text!)
        }
        
        action.isEnabled = (alert.textFields![0] as UITextField).text! == ""
        
        alert.addAction(action)
        
        showAlert(alert: alert)
    }
           
    public func showTextInputPrompt(placeholder: String, title: String, message: String, callback: @escaping (Bool, String) -> Void) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                   
           alert.addTextField() { textField in
               textField.placeholder = placeholder
               textField.text = ""
               textField.keyboardType = .numberPad
           }
           
           alert.addAction(UIAlertAction(title: "Enter", style: .default) { _ in
               let firstTextField = alert.textFields![0] as UITextField
               let text = firstTextField.text
               callback(true, text!)
           })
           
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
               callback(false, "")
           })
           showAlert(alert: alert)
       }
       

      func showAlert(alert: UIAlertController) {
          if let controller = topMostViewController() {
              controller.present(alert, animated: true)
          }
      }

      private func keyWindow() -> UIWindow? {
          return UIApplication.shared.connectedScenes
          .filter {$0.activationState == .foregroundActive}
          .compactMap {$0 as? UIWindowScene}
          .first?.windows.filter {$0.isKeyWindow}.first
      }

      private func topMostViewController() -> UIViewController? {
          guard let rootController = keyWindow()?.rootViewController else {
              return nil
          }
          return topMostViewController(for: rootController)
      }

      private func topMostViewController(for controller: UIViewController) -> UIViewController {
          if let presentedController = controller.presentedViewController {
              return topMostViewController(for: presentedController)
          } else if let navigationController = controller as? UINavigationController {
              guard let topController = navigationController.topViewController else {
                  return navigationController
              }
              return topMostViewController(for: topController)
          } else if let tabController = controller as? UITabBarController {
              guard let topController = tabController.selectedViewController else {
                  return tabController
              }
              return topMostViewController(for: topController)
          }
          return controller
      }
}
