import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        WebView()
            .ignoresSafeArea()
    }
}

struct WebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        // Enable bounce for pull-to-refresh
        webView.scrollView.bounces = true
        webView.scrollView.alwaysBounceVertical = true
        
        // Add pull-to-refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handlePullToRefresh), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
        context.coordinator.refreshControl = refreshControl
        context.coordinator.webView = webView
        
        // Load bundled web content - allow access to entire www folder for assets
        if let indexURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "www") {
            let wwwURL = indexURL.deletingLastPathComponent().deletingLastPathComponent()
            webView.loadFileURL(indexURL, allowingReadAccessTo: wwwURL)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var refreshControl: UIRefreshControl?
        weak var webView: WKWebView?
        
        @objc func handlePullToRefresh() {
            webView?.reload()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            refreshControl?.endRefreshing()
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            refreshControl?.endRefreshing()
        }
    }
}
