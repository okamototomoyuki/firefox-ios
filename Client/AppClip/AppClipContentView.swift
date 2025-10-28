import SwiftUI

struct AppClipContentView: View {
    @EnvironmentObject private var coordinator: AppClipLaunchCoordinator
    @State private var requestedURL: URL?
    @State private var currentURL: URL?
    @State private var addressBarText: String = ""
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var isLoading = false
    @State private var navigationCommand: AppClipWebView.Command?
    @State private var showInvalidURLAlert = false

    private let homePageURL = URL(string: "https://swiftglobe-browser.example.com")!

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SwiftGlobe Browser")
                    .font(.title2)
                    .bold()
                Text("軽量でプライバシーを重視したブラウザ体験を今すぐお試しください。")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    TextField("検索またはウェブアドレスを入力", text: $addressBarText, onCommit: openAddressBarInput)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    Button(action: reloadCurrentPage) {
                        Image(systemName: "arrow.clockwise")
                            .imageScale(.medium)
                    }
                    .disabled(currentURL == nil)
                    .buttonStyle(.borderless)
                }

                HStack(spacing: 16) {
                    Button(action: goBack) {
                        Image(systemName: "chevron.backward")
                            .imageScale(.large)
                    }
                    .disabled(!canGoBack)

                    Button(action: goForward) {
                        Image(systemName: "chevron.forward")
                            .imageScale(.large)
                    }
                    .disabled(!canGoForward)

                    Spacer()

                    if let url = currentURL {
                        Link("Safari で開く", destination: url)
                    }
                }
            }
            .padding(.horizontal)

            AppClipWebView(
                requestedURL: $requestedURL,
                currentURL: $currentURL,
                canGoBack: $canGoBack,
                canGoForward: $canGoForward,
                isLoading: $isLoading,
                navigationCommand: $navigationCommand
            )
            .edgesIgnoringSafeArea(.bottom)

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
            .padding(.vertical, 8)
            .padding(.horizontal)
        }
        .onAppear {
            loadInitialPage()
        }
        .onChange(of: coordinator.lastVisitedURL) { newValue in
            guard let url = newValue else { return }
            load(url)
        }
        .onChange(of: currentURL) { newURL in
            guard let newURL else { return }
            addressBarText = newURL.absoluteString
        }
        .alert("ページを開けません", isPresented: $showInvalidURLAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("入力したアドレスを確認してください。")
        }
    }

    private func loadInitialPage() {
        let initialURL = coordinator.lastVisitedURL ?? homePageURL
        addressBarText = initialURL.absoluteString
        load(initialURL)
    }

    private func openAddressBarInput() {
        guard let url = normalizedURL(from: addressBarText) else {
            showInvalidURLAlert = true
            return
        }
        load(url)
    }

    private func load(_ url: URL) {
        requestedURL = url
    }

    private func goBack() {
        navigationCommand = .goBack
    }

    private func goForward() {
        navigationCommand = .goForward
    }

    private func reloadCurrentPage() {
        navigationCommand = .reload
    }

    private func normalizedURL(from input: String) -> URL? {
        var trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if !trimmed.contains("://") {
            trimmed = "https://" + trimmed
        }

        return URL(string: trimmed)
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
