import SwiftUI

@main
struct SwiftGlobeAppClipApp: App {
    @StateObject private var coordinator = AppClipLaunchCoordinator()

    var body: some Scene {
        WindowGroup {
            AppClipContentView()
                .environmentObject(coordinator)
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            coordinator.handleIncomingUserActivity(activity)
        }
    }
}

final class AppClipLaunchCoordinator: ObservableObject {
    @Published var lastVisitedURL: URL?

    func handleIncomingUserActivity(_ userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return
        }

        DispatchQueue.main.async {
            self.lastVisitedURL = url
        }
    }
}
