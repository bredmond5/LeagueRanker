////
////  PlayerLocal+extensions.swift
////  ScoreSender
////
////  Created by Brice Redmond on 9/14/20.
////  Copyright © 2020 Brice Redmond. All rights reserved.
////
//
//import FirebaseStorage
//
//extension PlayerLocal {
//    enum PlayerLocalErrors: LocalizedError {
//      case ImageDownloadError(playerName: String)
//    }
//    
//    public var storageRef: StorageReference {
//        return Storage.storage().reference(withPath: "\(self.leagueLocal!.id)/\(self.id!)")
//    }
//    
//    func moreGames(than numRequired: Int64) -> Bool {
//        return self.wins + self.losses > numRequired
//    }
//    
//    func setValues(to playerDict: NSDictionary?, uid: String?, completion: @escaping (Error?) -> ()) {
//        guard let playerDict = playerDict,
//            let uid = uid,
//            let mu = playerDict["mu"] as? Double,
//            let sigma = playerDict["sigma"] as? Double,
//            let displayName =  playerDict["displayName"] as? String,
//            let realName = playerDict["realName"] as? String,
//            let phoneNumber = playerDict["phoneNumber"] as? String,
//            let imageChangeDate = playerDict["imageChangeDate"] as? Int64
//            
//            else {
//            print("failed in playerDict")
//            return
//        }
//        
//        self.id = uid
//        self.displayName = displayName
//        self.rank = 1
//        self.mean = mu
//        self.standardDeviation = sigma
//        self.realName = realName
//        self.phoneNumber = phoneNumber
//        
//        if imageChangeDate > self.imageChangeDate { // is date auto set to zero?
//          self.getImageFromFirebase(newDate: imageChangeDate, completion: { error in
//            completion(error)
//          })
//        } else {
//          completion(nil)
//        }
//        
//    }
//
//    func getImageFromFirebase(newDate: Int64, completion: @escaping (Error?) -> ()) {
//       storageRef.getData(maxSize: 1 * 1024 * 1024, completion: { [weak self] data, error in
//         if let error = error {
//            completion(error)
//            return
//          } else if let data = data {
//            self?.image = data
//            self?.imageChangeDate = newDate
//           completion(nil)
//         } else {
//            completion(PlayerLocalErrors.ImageDownloadError(playerName: (self?.displayName) ?? ""))
//        }
//       })
//    }
//}
//
//
//extension PlayerLocal.PlayerLocalErrors {
//  public var errorDescription: String? {
//    switch self {
//    case .ImageDownloadError(playerName: let playerName):
//        return NSLocalizedString("Error: \(playerName) failed to download image", comment: "My error")
//        }
//    }
//}
