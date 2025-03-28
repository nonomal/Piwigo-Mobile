//
//  UserProvider.swift
//  piwigoKit
//
//  Created by Eddy Lelièvre-Berna on 28/08/2022.
//  Copyright © 2022 Piwigo.org. All rights reserved.
//

import CoreData

public enum pwgUserStatus: String, CaseIterable {
    case guest, generic, normal, admin, webmaster
}

public class UserProvider: NSObject {
    
    // MARK: - Singleton
    public static let shared = UserProvider()
    
    
    // MARK: - Core Data Object Contexts
    private lazy var mainContext: NSManagedObjectContext = {
        return DataController.shared.mainContext
    }()
    
    private lazy var bckgContext: NSManagedObjectContext = {
        return DataController.shared.newTaskContext()
    }()
    
    
    // MARK: - Core Data Providers
    private lazy var serverProvider: ServerProvider = {
        let provider : ServerProvider = ServerProvider.shared
        return provider
    }()
    
    
    // MARK: - Get/Create User Account Object
    /**
     Returns a User Account instance
     - Will create a Server object if it does not already exist.
     - Will create a User Account object if it does not already exist.
     */
    public func getUserAccount(inContext taskContext: NSManagedObjectContext,
                               atPath path: String = NetworkVars.shared.serverPath,
                               withUsername username: String = NetworkVars.shared.username,
                               afterUpdate doUpdate: Bool = false) -> User? {
        // Initialisation
        var currentUser: User?
        
        // Perform the fetch
        taskContext.performAndWait {
            // Create a fetch request for the User entity
            let fetchRequest = User.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(User.username), ascending: true,
                                                             selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            
            // Look for a user account of the server at path
            var andPredicates = [NSPredicate]()
            andPredicates.append(NSPredicate(format: "server.path == %@", NetworkVars.shared.serverPath))
            andPredicates.append(NSPredicate(format: "username == %@", username))
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: andPredicates)
            fetchRequest.fetchLimit = 1

            // Create a fetched results controller and set its fetch request, context, and delegate.
            let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                        managedObjectContext: taskContext,
                                                        sectionNameKeyPath: nil, cacheName: nil)
            // Perform the fetch.
            do {
                try controller.performFetch()
            } catch {
                debugPrint("••> getUserAccount() unresolved error: \(error)")
                return
            }
            
            // Did we find a User instance?
            if let cachedUser: User = (controller.fetchedObjects ?? []).first {
                if doUpdate {
                    let now = Date.timeIntervalSinceReferenceDate
                    cachedUser.lastUsed = now
                    cachedUser.server?.lastUsed = now
                    cachedUser.status = NetworkVars.shared.userStatus.rawValue
                }
                currentUser = cachedUser
            } else {
                // Get the Server managed object on the current queue context.
                // Create a User managed object on the current queue context.
                guard let server = serverProvider.getServer(inContext: taskContext, atPath: path),
                      let user = NSEntityDescription.insertNewObject(forEntityName: "User",
                                                                     into: taskContext) as? User else {
                    debugPrint(UserError.creationError.localizedDescription)
                    return
                }
                
                // Populate the User's properties using the data.
                do {
                    try user.update(username: username, ofServer: server)
                    currentUser = user
                }
                catch {
                    debugPrint(error.localizedDescription)
                    taskContext.delete(user)
                }
            }
            
            // Save all insertions from the context to the store.
            taskContext.saveIfNeeded()
            if Thread.isMainThread == false {
                DispatchQueue.main.async {
                    self.mainContext.saveIfNeeded()
                }
            }
        }
        
        return currentUser
    }
    
    /**
     Returns all User Account instances of a server
     */
//    public func getUserAccounts(inContext taskContext: NSManagedObjectContext,
//                                atPath path: String = NetworkVars.shared.serverPath) -> Set<User> {
//        var users = Set<User>()
//        
//        // Perform the fetch
//        taskContext.performAndWait {
//            // Create a fetch request for the User entity
//            let fetchRequest = User.fetchRequest()
//            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(User.username), ascending: true,
//                                                             selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
//            
//            // Look for all user accounts of the server at path
//            fetchRequest.predicate = NSPredicate(format: "server.path == %@", NetworkVars.shared.serverPath)
//
//            // Create a fetched results controller and set its fetch request, context, and delegate.
//            let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
//                                                        managedObjectContext: taskContext,
//                                                        sectionNameKeyPath: nil, cacheName: nil)
//            // Perform the fetch.
//            do {
//                try controller.performFetch()
//            } catch {
//                fatalError("Unresolved error \(error)")
//            }
//            
//            // Return user instances
//            users = Set(controller.fetchedObjects ?? [])
//        }
//        
//        return users
//    }
}
