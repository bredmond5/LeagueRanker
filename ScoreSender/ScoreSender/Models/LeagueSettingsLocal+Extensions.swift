////
////  LeagueSettingsLocal+Extensions.swift
////  ScoreSender
////
////  Created by Brice Redmond on 9/14/20.
////  Copyright © 2020 Brice Redmond. All rights reserved.
////
//
//import Foundation
//import FirebaseStorage
//import FirebaseDatabase
//
//extension LeagueSettingsLocal {
//    
//    enum LeagueSettingsLocalErrors: LocalizedError {
//      case ImageDownloadError
//    }
//    
//    func listen(to ref: DatabaseReference, completion: (Error?) -> ()) {
//        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in // could be observe
//            guard let strongSelf = self else {
//                print("Weakself in leagueSettingsLocal")
//                return
//            }
//            guard
//                let leagueSettingsDict = snapshot.value as? [String: AnyObject],
//                let name = leagueSettingsDict["name"] as? String,
//                let ownerUID = leagueSettingsDict["ownerUID"] as? String,
//                let numPlacements = leagueSettingsDict["numPlacements"] as? Int64,
//                let playersPerTeam = leagueSettingsDict["playersPerTeam"] as? Int64,
//                let imageChangeDate = leagueSettingsDict["imageChangeDate"] as? Int64
//                
//            else {
//                print("Failed in league settings snapshot initializer")
//                return
//            }
//            strongSelf.ownerUID = ownerUID
//            strongSelf.name = name
//            strongSelf.numPlacements = numPlacements
//            strongSelf.playersPerTeam = playersPerTeam
//            
//            if imageChangeDate > strongSelf.imageChangeDate {
//              strongSelf.getImageFromFirebase(newDate: imageChangeDate, completion: { error in
//                completion(error)
//              })
//            } else {
//              completion(nil)
//            }
//        })
//    }
//    
//    public var storageRef: StorageReference {
//        return Storage.storage().reference(withPath: "\(self.leagueLocal.id)/\(self.leagueLocal.id)")
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
//            completion(LeagueSettingsLocalErrors.ImageDownloadError)
//        }
//       })
//    }
//    
//    public func toAnyObject() -> Any {
//        return [
//            "name": name,
//            "ownerUID": ownerUID,
//            "numPlacements": numPlacements,
//            "playersPerTeam": playersPerTeam,
//            "imageChangeDate": imageChangeDate
//        ] as Any
//    }
//}
//
//extension LeagueSettingsLocal.LeagueSettingsLocalErrors {
//  public var errorDescription: String? {
//    switch self {
//    case .ImageDownloadError:
//        return NSLocalizedString("Failed to download league image", comment: "My error")
//        }
//    }
//}
