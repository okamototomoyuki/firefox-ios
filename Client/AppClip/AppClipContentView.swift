import SwiftUI

struct AppClipContentView: View {
    @EnvironmentObject private var coordinator: AppClipLaunchCoordinator
    @Environment(\.openURL) private var openURL
    @State private var isLaunchingFullApp = false
    @State private var launchError: String?

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "globe")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .foregroundColor(.accentColor)

            Text("Firefox App Clip")
                .font(.title)
                .bold()

            Text(descriptionText)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: openFullApp) {
                if isLaunchingFullApp {
                    ProgressView()
                } else {
                    Text("続きは Firefox で")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLaunchingFullApp)

            if let launchError {
                Text(launchError)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
        .onChange(of: coordinator.lastVisitedURL) { _ in
            launchError = nil
        }
    }

    private var descriptionText: String {
        if let lastURL = coordinator.lastVisitedURL {
            return "直前に開いたページを Firefox で引き続き表示できます。\n\n" + lastURL.absoluteString
        }
        return "Firefox の軽量版です。フル機能を利用するにはアプリを開いてください。"
    }

    private func openFullApp() {
        guard !isLaunchingFullApp else { return }
        isLaunchingFullApp = true
        launchError = nil

        guard let destination = coordinator.fallbackURL() else {
            launchError = "アプリを開くためのリンクを作成できませんでした。"
            isLaunchingFullApp = false
            return
        }

        openURL(destination) { accepted in
            DispatchQueue.main.async {
                self.isLaunchingFullApp = false
                if !accepted {
                    self.launchError = "Firefox アプリを開けませんでした。"
                }
            }
        }
    }
}

struct AppClipContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppClipContentView()
            .environmentObject(AppClipLaunchCoordinator())
    }
}
