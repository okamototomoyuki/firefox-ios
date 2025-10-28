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

            Text("SwiftGlobe App Clip")
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
                    Text("続きは SwiftGlobe で")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLaunchingFullApp)

            VStack(spacing: 4) {
                Text("SwiftGlobe Browser は Mozilla Firefox をフォークしたオープンソースのブラウザです。")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                Text("MPL 2.0 のライセンスに基づいて無料で提供し、ソースコードは GitHub で公開しています。")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                if let projectURL = projectURL {
                    Link("ソースコードとライセンスを確認", destination: projectURL)
                        .font(.footnote)
                }
            }

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
            return "直前に開いたページを SwiftGlobe で引き続き表示できます。\n\n" + lastURL.absoluteString
        }
        return "SwiftGlobe Browser の軽量版です。フル機能を利用するにはアプリを開いてください。"
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
                    self.launchError = "SwiftGlobe アプリを開けませんでした。"
                }
            }
        }
    }

    private var projectURL: URL? {
        URL(string: "https://github.com/your-org/swiftglobe-browser")
    }
}

struct AppClipContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppClipContentView()
            .environmentObject(AppClipLaunchCoordinator())
    }
}
