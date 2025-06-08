import Foundation
import CoreData

/// Errors that can occur during database operations.
enum DatabaseServicingError: Error {
    /// Failed to save a signature to the database. Contains the underlying `Error`.
    case saveFailed(Error)
    /// Failed to fetch signatures from the database. Contains the underlying `Error`.
    case fetchFailed(Error)
    /// Failed to delete a signature from the database. Contains the underlying `Error`.
    case deleteFailed(Error)
    /// Failed to serialize or deserialize data (e.g., MFCC features). Contains a description.
    case serializationError(String)
    /// The Core Data model (e.g., specific entity) was not found. Contains a description.
    case modelNotFound(String)
    /// An unknown or unspecified database error occurred.
    case unknown
}

/// Defines the interface for a database service that handles storage of `VoiceSignatureModel` objects.
protocol DatabaseServicing {
    /// Saves a voice signature model to the persistent store.
    /// - Parameters:
    ///   - model: The `VoiceSignatureModel` to save.
    ///   - completion: A closure called upon completion, returning a `Result` which is either `Void` on success or a `DatabaseServicingError` on failure.
    func saveSignature(model: VoiceSignatureModel, completion: @escaping (Result<Void, DatabaseServicingError>) -> Void)

    /// Fetches all stored voice signature models.
    /// - Parameter completion: A closure called upon completion, returning a `Result` with either an array of `VoiceSignatureModel` objects or a `DatabaseServicingError`.
    func fetchSignatures(completion: @escaping (Result<[VoiceSignatureModel], DatabaseServicingError>) -> Void)

    /// Deletes a specific voice signature model identified by its ID.
    /// - Parameters:
    ///   - id: The `UUID` of the signature to delete.
    ///   - completion: A closure called upon completion, returning a `Result` which is either `Void` on success or a `DatabaseServicingError` on failure.
    func deleteSignature(id: UUID, completion: @escaping (Result<Void, DatabaseServicingError>) -> Void)
}

/// An implementation of `DatabaseServicing` using Core Data.
/// This service manages the Core Data stack (persistent container, context) and handles
/// CRUD (Create, Read, Update, Delete) operations for voice signatures.
class CoreDataService: DatabaseServicing {

    // MARK: - Core Data Stack

    // !!! IMPORTANT !!!
    // The developer using this code MUST create a Core Data Model file named "VoiceSignatureAppModel.xcdatamodeld"
    // in their Xcode project and ensure it's included in the application target.
    // This model file should contain an ENTITY named "VoiceSignatureEntity" with the following attributes:
    // - id: UUID (Set type to "UUID" in the Data Model Inspector)
    // - timestamp: Date (Set type to "Date")
    // - mfccData: Binary Data (Set type to "Binary Data")
    // - originalFilePath: String (Set type to "String", mark as Optional)
    //
    // After creating the .xcdatamodeld file, Xcode can auto-generate NSManagedObject subclasses.
    // While this service currently uses KVC (setValue/value(forKey:)), using generated subclasses
    // (e.g., VoiceSignatureEntity.swift) is generally safer and more Swifty.

    private let modelName: String = "VoiceSignatureAppModel"
    private let entityName: String = "VoiceSignatureEntity"

    private lazy var persistentContainer: NSPersistentContainer = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            // This is a critical error. The model file is missing from the app bundle.
            // This can happen if the .xcdatamodeld file is not created, not named correctly,
            // or not included in the target's "Copy Bundle Resources" build phase.
            print("CRITICAL ERROR: Core Data model file '\(self.modelName).momd' not found in bundle.")
            // In a real app, you might want to log this and perhaps alert the user or fail gracefully.
            // For now, we'll proceed to fatalError as the app cannot function without its data model.
            fatalError("Unable to load Core Data model: \(self.modelName).momd. Ensure it's created and added to the target.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            // This means the .momd file was found, but it's corrupted or not a valid Core Data model.
            fatalError("Unable to initialize NSManagedObjectModel from URL: \(modelURL)")
        }

        let container = NSPersistentContainer(name: self.modelName, managedObjectModel: managedObjectModel)

        // Configuration for the persistent store (e.g., SQLite file)
        // The default location is in the Application Support directory.
        // For testing, an in-memory store can be configured (see test setup).

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // This is a serious error during persistent store loading.
                // Common reasons:
                // * Disk full or permissions issues in the app's data directory.
                // * Data model migration issues if the model has changed.
                // * Data corruption.
                print("Unresolved error loading persistent store: \(error), \(error.userInfo)")
                // In a production app, you should handle this gracefully.
                // Options include:
                // - Attempting to delete and recreate the store (data loss).
                // - Alerting the user that data cannot be saved/loaded.
                // - Reporting the error to a crash reporting service.
                // For this placeholder, we'll log and let it potentially fail later if the context is used.
                // Depending on app requirements, fatalError might be too abrupt.
            } else {
                print("Persistent store loaded successfully at: \(storeDescription.url?.path ?? "Unknown URL")")
            }
        }
        // Ensure that operations on the viewContext are performed on the correct queue.
        // Merging policies can be important if using background contexts.
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    // Convenience accessor for the main queue context.
    private var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - DatabaseServicing Implementation

    func saveSignature(model: VoiceSignatureModel, completion: @escaping (Result<Void, DatabaseServicingError>) -> Void) {
        viewContext.perform { // Perform on the context's queue
            guard let entityDescription = NSEntityDescription.entity(forEntityName: self.entityName, in: self.viewContext) else {
                completion(.failure(.modelNotFound("Entity '\(self.entityName)' not found. Check .xcdatamodeld.")))
                return
            }
            let signatureEntity = NSManagedObject(entity: entityDescription, insertInto: self.viewContext)

            signatureEntity.setValue(model.id, forKey: "id")
            signatureEntity.setValue(model.timestamp, forKey: "timestamp")
            signatureEntity.setValue(model.mfccData, forKey: "mfccData")
            if let filePath = model.originalFilePath {
                signatureEntity.setValue(filePath, forKey: "originalFilePath")
            } else {
                // Explicitly set to nil if the model's value is nil and the attribute is optional
                signatureEntity.setValue(nil, forKey: "originalFilePath")
            }

            do {
                if self.viewContext.hasChanges {
                    try self.viewContext.save()
                    completion(.success(()))
                } else {
                    // No changes, perhaps an update to an identical object?
                    // Or save called without actual modifications.
                    print("CoreDataService: No changes to save for signature ID \(model.id).")
                    completion(.success(())) // Still a success as the desired state is achieved.
                }
            } catch {
                self.viewContext.rollback() // Rollback on error to leave context clean
                completion(.failure(.saveFailed(error)))
            }
        }
    }

    func fetchSignatures(completion: @escaping (Result<[VoiceSignatureModel], DatabaseServicingError>) -> Void) {
        viewContext.perform { // Perform on the context's queue
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.entityName)

            // Optional: Add sort descriptors for consistent ordering
            let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]

            do {
                let results = try self.viewContext.fetch(fetchRequest)
                let models = results.compactMap { entity -> VoiceSignatureModel? in
                    guard let id = entity.value(forKey: "id") as? UUID,
                          let timestamp = entity.value(forKey: "timestamp") as? Date,
                          let mfccData = entity.value(forKey: "mfccData") as? Data else {
                        print("CoreDataService: Found entity with missing required attributes. Skipping.")
                        return nil // Skip if essential data is missing
                    }
                    let originalFilePath = entity.value(forKey: "originalFilePath") as? String
                    return VoiceSignatureModel(id: id, timestamp: timestamp, mfccData: mfccData, originalFilePath: originalFilePath)
                }
                completion(.success(models))
            } catch {
                completion(.failure(.fetchFailed(error)))
            }
        }
    }

    // Optional: deleteSignature implementation
    func deleteSignature(id: UUID, completion: @escaping (Result<Void, DatabaseServicingError>) -> Void) {
        viewContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.entityName)
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            fetchRequest.fetchLimit = 1 // Expecting only one or zero results for a UUID

            do {
                let results = try self.viewContext.fetch(fetchRequest)
                guard let objectToDelete = results.first else {
                    // No object found with that ID, consider it a success or a specific error.
                    // For idempotency, often treated as success.
                    print("CoreDataService: No signature found with ID \(id) to delete.")
                    completion(.success(()))
                    return
                }

                self.viewContext.delete(objectToDelete)

                if self.viewContext.hasChanges {
                    try self.viewContext.save()
                }
                completion(.success(()))

            } catch {
                self.viewContext.rollback()
                completion(.failure(.deleteFailed(error)))
            }
        }
    }
}
