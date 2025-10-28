import SwiftUI
import WebKit

struct AppClipWebView: UIViewRepresentable {
    @Binding var requestedURL: URL?
    @Binding var currentURL: URL?
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var isLoading: Bool
    @Binding var navigationCommand: AppClipWebView.Command?

    enum Command: Equatable {
        case goBack
        case goForward
        case reload
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.suppressesIncrementalRendering = false

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        context.coordinator.webView = webView

        if let initialURL = requestedURL {
            webView.load(URLRequest(url: initialURL))
            DispatchQueue.main.async {
                self.requestedURL = nil
            }
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.webView = webView

        if let command = navigationCommand {
            switch command {
            case .goBack:
                if webView.canGoBack { webView.goBack() }
            case .goForward:
                if webView.canGoForward { webView.goForward() }
            case .reload:
                webView.reload()
            }

            DispatchQueue.main.async {
                self.navigationCommand = nil
            }
        }

        if let targetURL = requestedURL {
            if webView.url != targetURL {
                let request = URLRequest(url: targetURL)
                webView.load(request)
            }

            DispatchQueue.main.async {
                self.requestedURL = nil
            }
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: AppClipWebView
        weak var webView: WKWebView?

        init(parent: AppClipWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            updateState(for: webView)
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            updateState(for: webView)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            updateState(for: webView)
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            parent.isLoading = false
            webView.reload()
            updateState(for: webView)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            updateState(for: webView)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            updateState(for: webView)
        }

        private func updateState(for webView: WKWebView) {
            parent.currentURL = webView.url
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
        }
    }
}
