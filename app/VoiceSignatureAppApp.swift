import SwiftUI

@main
struct VoiceSignatureAppApp: App {
    // Note on CoreDataService:
    // If CoreDataService.swift uses a lazy var for its persistentContainer
    // and is initialized directly within ContentView's init() (as per the current ContentView implementation),
    // the Core Data stack will be set up when ContentView is first created.
    //
    // For more complex apps, or if you need the Core Data context available to multiple scenes
    // or as an environment object, you might initialize CoreDataService here (e.g., as a @StateObject)
    // and pass its context to the ContentView via .environment(\.managedObjectContext, ...).
    //
    // Example (if CoreDataService was a shared instance or an ObservableObject):
    // @StateObject private var dataController = CoreDataService() // Assuming CoreDataService is an ObservableObject

    var body: some Scene {
        WindowGroup {
            ContentView()
            // If CoreDataService was set up to provide its context via a shared instance or ObservableObject:
            // For example, if you had a `PersistenceController` or similar:
            //     .environment(\.managedObjectContext, dataController.persistentContainer.viewContext)
            //
            // The current ContentView initializes its own MainViewModel, which in turn initializes
            // its own instance of CoreDataService. This is simple for this example but means
            // CoreDataService's lifecycle is tied to ContentView's ViewModel.
            // For the .xcdatamodeld to be found by CoreDataService when initialized this way,
            // ensure "VoiceSignatureAppModel.xcdatamodeld" is included in the app target's "Copy Bundle Resources".
        }
    }
}
