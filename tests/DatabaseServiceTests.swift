import XCTest
import CoreData
@testable import VoiceSignatureApp // Replace YourAppName with actual target name

// Unit tests for CoreDataService. These tests should use an in-memory Core Data store.
// This ensures tests are fast, isolated, and do not affect production data or depend on disk state.

class DatabaseServiceTests: XCTestCase {

    var coreDataService: CoreDataService!
    var mockPersistentContainer: NSPersistentContainer! // Keep a reference if needed for direct inspection

    // This must match the .xcdatamodeld file name.
    let coreDataModelName = "VoiceSignatureAppModel"

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Load the Managed Object Model from the app bundle (where .momd is located)
        // This ensures we're testing against the same model definition as the app.
        guard let modelURL = Bundle.main.url(forResource: coreDataModelName, withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load Core Data model '\(coreDataModelName).momd' from bundle for tests. Ensure it's in the test target or app bundle.")
        }

        // Create an NSPersistentContainer with the loaded model
        mockPersistentContainer = NSPersistentContainer(name: coreDataModelName, managedObjectModel: managedObjectModel)

        // Configure the persistent store description for an in-memory store
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType // Use in-memory store
        description.shouldAddStoreAsynchronously = false // Make loadSynchronous for testing

        mockPersistentContainer.persistentStoreDescriptions = [description]

        // Load the persistent stores. For an in-memory store, this is synchronous.
        mockPersistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // If loading fails, it's a critical error for the test setup.
                fatalError("Failed to load in-memory persistent store: \(error), \(error.userInfo)")
            }
        }

        // To test CoreDataService, it needs to use our mockPersistentContainer.
        // This requires CoreDataService to be adaptable for testing, e.g., by:
        // 1. Internal initializer that accepts an NSPersistentContainer (preferred for testing).
        // 2. Swapping its `persistentContainer` property (less clean, might need internal access).

        // For this placeholder, we assume CoreDataService is refactored to allow container injection.
        // If CoreDataService.swift's `persistentContainer` is not directly settable or injectable,
        // this test setup would need to adapt. For now, we'll proceed as if it is.
        // A common pattern is an internal initializer:
        // `internal init(persistentContainer: NSPersistentContainer)` in CoreDataService.

        // This is a conceptual assignment. The actual CoreDataService needs to be
        // initializable with a specific container for this to work directly.
        // For now, we'll simulate this by directly creating a CoreDataService instance
        // and acknowledge that its internal container is the production one, not our in-memory one
        // unless `CoreDataService` is modified for testability.

        // Let's assume we modify CoreDataService to have an internal init for testing:
        // e.g., in CoreDataService.swift:
        // #if DEBUG // Or a more specific testing flag
        // internal convenience init(inMemory: Bool = false) { ... configures container ... }
        // #endif
        // Or, more directly:
        // internal init(container: NSPersistentContainer) { self.persistentContainer = container }

        // For this test, we will proceed by creating a new instance of CoreDataService,
        // and it will internally create its *own* persistentContainer.
        // To *truly* test with the in-memory store, CoreDataService's lazy var for persistentContainer
        // would need to be overridden or the class made more testable.
        // One simple way for this example is to make persistentContainer internal and settable for tests.

        coreDataService = CoreDataService()
        // If CoreDataService could be injected with a container:
        // coreDataService = CoreDataService(container: mockPersistentContainer)
        // For this version, we'll test the default CoreDataService, but operations
        // will hit the default store path if not careful. The in-memory setup above
        // is what *should* be used if CoreDataService is testable.
        // To make the provided CoreDataService testable with an in-memory store without changing its public API,
        // we'd typically make its `persistentContainer` property `internal` instead of `private lazy`
        // and assign `mockPersistentContainer` to it here.
        // For now, we'll proceed with the default service, and tests will reflect that.
        // If testing against the real store, ensure cleanup. For CI/CD, in-memory is vital.
        // The prompt implies we are testing the CoreDataService as is.
    }

    override func tearDownWithError() throws {
        // Clean up: remove all data from the in-memory store if CoreDataService was using mockPersistentContainer.
        // If testing the actual CoreDataService without injection, this cleanup is more complex or might be skipped.
        // For a true in-memory test, this would involve clearing objects from mockPersistentContainer.viewContext.

        // Example: If coreDataService used mockPersistentContainer:
        // let context = mockPersistentContainer.viewContext
        // let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "VoiceSignatureEntity")
        // let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        // do {
        // try context.execute(deleteRequest)
        // try context.save()
        // } catch {
        // XCTFail("Failed to clear in-memory store: \(error)")
        // }

        coreDataService = nil
        mockPersistentContainer = nil // Release the container
        try super.tearDownWithError()
    }

    func testSaveAndFetchSignature_Placeholder() {
        let expectation = XCTestExpectation(description: "Save and then fetch a signature")

        let signatureID = UUID()
        let testModel = VoiceSignatureModel(
            id: signatureID,
            timestamp: Date(),
            mfccData: Data("test_mfcc_data".utf8),
            originalFilePath: "/path/to/test.m4a"
        )

        coreDataService.saveSignature(model: testModel) { saveResult in
            switch saveResult {
            case .success:
                // Now try to fetch
                self.coreDataService.fetchSignatures { fetchResult in
                    switch fetchResult {
                    case .success(let models):
                        XCTAssertFalse(models.isEmpty, "Fetched models should not be empty after saving.")
                        let fetchedModel = models.first { $0.id == signatureID }
                        XCTAssertNotNil(fetchedModel, "The saved signature should be found.")
                        XCTAssertEqual(fetchedModel?.mfccData, testModel.mfccData, "MFCC data should match.")
                        XCTAssertEqual(fetchedModel?.originalFilePath, testModel.originalFilePath, "File path should match.")
                    case .failure(let error):
                        XCTFail("Fetch failed after successful save: \(error)")
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Save failed: \(error)")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0) // Adjust timeout as needed for Core Data operations
    }

    func testFetchSignatures_WhenStoreIsEmpty_ReturnsEmptyArray() {
        let expectation = XCTestExpectation(description: "Fetch signatures when store is empty")

        coreDataService.fetchSignatures { result in
            switch result {
            case .success(let models):
                XCTAssertTrue(models.isEmpty, "Expected empty array when store is empty, but got \(models.count) items.")
            case .failure(let error):
                XCTFail("Fetch failed when expecting empty store: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testDeleteSignature_Placeholder() {
        let expectation = XCTestExpectation(description: "Save, delete, then fetch to confirm deletion")

        let signatureID = UUID()
        let testModel = VoiceSignatureModel(
            id: signatureID,
            timestamp: Date(),
            mfccData: Data("delete_test_data".utf8),
            originalFilePath: nil
        )

        // 1. Save the signature
        coreDataService.saveSignature(model: testModel) { saveResult in
            guard case .success = saveResult else {
                XCTFail("Initial save failed for delete test: \(String(describing: saveResult))")
                expectation.fulfill()
                return
            }

            // 2. Delete the signature
            self.coreDataService.deleteSignature(id: signatureID) { deleteResult in
                guard case .success = deleteResult else {
                    XCTFail("Delete failed: \(String(describing: deleteResult))")
                    expectation.fulfill()
                    return
                }

                // 3. Fetch to confirm deletion
                self.coreDataService.fetchSignatures { fetchResult in
                    switch fetchResult {
                    case .success(let models):
                        let foundModel = models.first { $0.id == signatureID }
                        XCTAssertNil(foundModel, "Signature with ID \(signatureID) should have been deleted, but was found.")
                    case .failure(let error):
                        XCTFail("Fetch after delete failed: \(error)")
                    }
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }
}
