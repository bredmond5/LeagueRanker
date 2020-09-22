//
//  LeagueSettings.swift
//  ScoreSender
//
//  Created by Brice Redmond on 9/3/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import FirebaseDatabase
import FirebaseStorage
import SwiftUI

class LeagueSettings: ObservableObject {
    
    let ref: DatabaseReference
    @EnvironmentObject var session: FirebaseSession
    
    @Published var name: String = "League"
    @Published var numPlacements: Int = 15
    @Published var playersPerTeam: Int = 2
    @Published var dbImage: DBImage
    @Published var creatorUID: String = ""
    @Published var refresher: Bool = false
    @Published var changeDate: Int = 0
    
    var firstRead = true
    var firstCompletion: (() -> ())?
    let leagueID: String
    var needsSorting: (() -> ())?
        
    // init for download from firebase
    init(ref: DatabaseReference, leagueImageStoragePath: String, leagueID: String) {
        self.leagueID = leagueID
        self.ref = ref
        self.dbImage = DBImage(defaultImage: Constants.defaultLeaguePhoto, dateRef: ref.child("icDate"), storagePath: leagueImageStoragePath)
        self.dbImage.refreshRequired = { [weak self] in
            self?.refresher = false
        }
        attachObserver()
    }
    
    func attachObserver() {
        // Don't read in imageChangeDate since that is handled by DBImage
        ref.child("settings").observe(.value) { [ weak self] snapshot in
            guard
                let strongSelf = self,
                let value = snapshot.value as? [String: AnyObject],
                let nPlacements = value["nPlacements"] as? Int,
                let playersPerTeam = value["ppTeam"] as? Int,
                let name = value["name"] as? String,
                let creatorUID = value["creatorUID"] as? String,
                let changeDate = value["changeDate"] as? Int
                else {
                    return
            }
            strongSelf.numPlacements = nPlacements
            strongSelf.playersPerTeam = playersPerTeam
            strongSelf.name = name
            strongSelf.creatorUID = creatorUID
            strongSelf.changeDate = changeDate
            
            if strongSelf.firstRead {
                strongSelf.firstRead = false
                strongSelf.firstCompletion?()
            }
            
            strongSelf.needsSorting?()
        }
    }
    
    func changeLeagueImage(newImage: UIImage, completion: @escaping (Bool) -> ()) {
        dbImage.handle(newImage: newImage)
    }
    
    deinit {
        print("league settings deinit called")

        ref.child("settings").removeAllObservers()
    }
    
    func getUpdateChangeDateDictionary() -> [AnyHashable : Any] {
        return ["settings/settings/changeDate" : Int64(Date().timeIntervalSince1970 * 1000)]
    }
}

