import SwiftUI

@main
struct FirefoxAppClipApp: App {
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

    func fallbackURL() -> URL? {
        guard let lastVisitedURL else {
            return URL(string: "firefox://")
        }

        var components = URLComponents()
        components.scheme = "firefox"
        components.host = "open-url"
        components.queryItems = [
            URLQueryItem(name: "url", value: lastVisitedURL.absoluteString)
        ]

        return components.url
    }
}
