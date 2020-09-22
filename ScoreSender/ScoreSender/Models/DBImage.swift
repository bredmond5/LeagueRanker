//
//  DBImage.swift
//  
//
//  Created by Brice Redmond on 9/16/20.
//

import CoreData
import SwiftUI
import FirebaseDatabase
import FirebaseStorage

class DBImage: ObservableObject {
    
    @Published var image: UIImage
    
    let container: NSPersistentContainer
    
    let defaultImage: UIImage
    let dateRef: DatabaseReference?
    var storageRef: StorageReference?
    
    var refreshRequired: (() -> ())? = nil

    private var localImage: LocalImage?

    
    init(defaultImage: UIImage, dateRef: DatabaseReference? = nil, storagePath: String? = nil) {
        self.defaultImage = defaultImage
        self.dateRef = dateRef
        self.localImage = nil
        self.container = SceneDelegate.persistentContainer
        self.image = defaultImage
        
        guard dateRef != nil, let storagePath = storagePath else {
            storageRef = nil
            print("Not using databases for DBImage")
            return
        }
        
        var storagePathUsed = storagePath
        
        if storagePath.suffix(4) != ".jpg" {
            print("Storage path passed without .jpg, adding to end")
            storagePathUsed += ".jpg"
        }
        
        self.storageRef = Storage.storage().reference(withPath: storagePathUsed)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalImage")
        let predicate = NSPredicate(format: "id == %@", storagePath)
        request.predicate = predicate
        
        do {
            let fetch = try container.viewContext.fetch(request)
            if let localImage = fetch.first as? LocalImage {
                self.localImage = localImage
                self.image = UIImage(data: self.localImage!.data!)!
                
                // need to get imagre from firebase
            } else {
                print("could not find locally stored image, creating new one")
                self.localImage = LocalImage(context: container.viewContext)
                localImage?.data = defaultImage.pngData()
                localImage?.id = storagePathUsed
                getImageFromFirebase(newDate: 0, completion: { [weak self] error in
                    print("Initialized and got image")
                    self?.refreshRequired?()
                })
            }
            
        } catch let error as NSError{
            print("Error: \(error.localizedDescription)")
        }
        
        observe()
        //attach observers
    }
    
    func observe() {
        dateRef?.observe(.value) { [weak self] snapshot in
            if let self = self, let date = snapshot.value as? Int64, date > self.localImage?.imageChangeDate ?? 0 {
                self.getImageFromFirebase(newDate: date, completion: { error in
                    if let error = error {
                        print("Error: \(error.localizedDescription) DBImage will be default image")
                    }
                })
            }
        }
    }
               
   func getImageFromFirebase(newDate: Int64, completion: @escaping (Error?) -> ()) {
    guard let storageRef = self.storageRef else {
        return
    }
       storageRef.getData(maxSize: 1 * 1024 * 1024, completion: { [weak self] data, error in
       if let error = error {
            completion(error)
             return
        } else {
            if let self = self, let localImage = self.localImage {
                localImage.data = data
                self.image = UIImage(data: data!)!
                localImage.imageChangeDate = newDate
                self.saveContext()
                completion(nil)
            }
        }
     })
   }
    
    func getImageChangeDate() -> Int64 {
        return self.localImage?.imageChangeDate ?? 0
    }
    
    
    deinit {
//        if let localImage = self.localImage {
//            container.viewContext.delete(localImage)
//        }
        print("DBImage deinit called")
        
        dateRef?.removeAllObservers()
    }
    
    func handle(newImage: UIImage) {        
        localImage?.data = newImage.pngData()
        localImage?.imageChangeDate = Int64(Date().timeIntervalSince1970 * 1000)
        refreshRequired?()
        
        guard let storageRef = self.storageRef, let dateRef = self.dateRef else {
            print("cant upload images since storage ref and date ref are nil")
            return
        }
        
        StorageService.uploadImage(newImage, at: storageRef, completion: { [weak self] url in
            if url != nil {
                guard let self = self else {
                    return
                }
                if let imageChangeDate = self.localImage?.imageChangeDate {
                    print("setting date ref")
                    dateRef.setValue(imageChangeDate)
                    self.saveContext()

                } else {
                    print("no local image change date")
                }
                self.saveContext()
            } else {
                print("DBImage failure")
            }
        })
    }
    
    func delete() {
        assert(false)
    }
    
    func saveContext() {
        SceneDelegate.saveContext(context: self.container.viewContext)
    }
}
