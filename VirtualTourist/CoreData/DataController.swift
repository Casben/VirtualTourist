//
//  DataController.swift
//  VirtualTourist
//
//  Created by Herbert Dodge on 7/25/20.
//  Copyright © 2020 Herbert Dodge. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer:NSPersistentContainer
 
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    let backgroundContext:NSManagedObjectContext!

    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }

            self.configureContexts()
            completion?()
        }
    }
    
    static let shared = DataController(modelName: "VirtualTourist")
}

