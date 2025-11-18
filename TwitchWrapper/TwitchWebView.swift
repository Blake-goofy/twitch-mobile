//
//  TwitchWebView.swift
//  TwitchWrapper
//
//  WebKit wrapper that loads Twitch mobile site and removes "Open App" upsell.
//

import SwiftUI
import WebKit

struct TwitchWebView: UIViewRepresentable {
    
    // JavaScript to remove the Twitch "Open App" upsell
    // This script removes upsell elements by finding:
    // 1. Links with tracking parameters for "open in app"
    // 2. Buttons/elements with "open app" text
    // 3. Uses MutationObserver to handle dynamically added elements
    private let removeUpsellJS = """
    (function() {
        // Function to remove upsell elements
        function removeUpsellElements() {
            // Remove links with Twitch app upsell tracking parameters
            document.querySelectorAll('a[href*="tt_medium=mweb&tt_content=top_nav_open_in_app"]').forEach(function(element) {
                // Find the closest container (header, nav, div, section)
                let container = element.closest('header, nav, div, section');
                if (container) {
                    container.remove();
                } else {
                    element.remove();
                }
            });
            
            // Remove elements with "open app" text (case-insensitive)
            let selectors = 'button, a, div, span';
            document.querySelectorAll(selectors).forEach(function(element) {
                let text = element.innerText || element.textContent || '';
                if (text.toLowerCase().includes('open app')) {
                    // Find the closest container
                    let container = element.closest('header, nav, div, section');
                    if (container) {
                        container.remove();
                    } else {
                        element.remove();
                    }
                }
            });
        }
        
        // Run immediately on page load
        removeUpsellElements();
        
        // Set up MutationObserver to handle dynamically added content
        // This watches for changes to the DOM and re-runs the removal
        let observer = new MutationObserver(function(mutations) {
            removeUpsellElements();
        });
        
        // Observe the entire document for changes
        observer.observe(document.documentElement, {
            childList: true,
            subtree: true
        });
    })();
    """
    
    func makeUIView(context: Context) -> WKWebView {
        // Configure WebView with user content controller for JavaScript injection
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // Add the JavaScript user script to remove upsell elements
        // Injected at document end to ensure DOM is ready
        let userScript = WKUserScript(
            source: removeUpsellJS,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        userContentController.addUserScript(userScript)
        configuration.userContentController = userContentController
        
        // Allow JavaScript execution
        configuration.preferences.javaScriptEnabled = true
        
        // Create the WebView with configuration
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // Set navigation delegate to block upsell URLs
        webView.navigationDelegate = context.coordinator
        
        // Load the Twitch following directory
        if let url = URL(string: "https://m.twitch.tv/directory/following") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed for this static implementation
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // Coordinator to handle navigation events and block upsell URLs
    class Coordinator: NSObject, WKNavigationDelegate {
        
        // Block navigation to Twitch "Open App" upsell URL
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            let urlString = navigationAction.request.url?.absoluteString ?? ""
            
            // Block the Twitch "Open App" / upsell navigation
            // Check if URL contains the tracking parameters for app upsell
            if urlString.contains("tt_medium=mweb&tt_content=top_nav_open_in_app") {
                // Cancel this navigation to prevent opening external app
                decisionHandler(.cancel)
                return
            }
            
            // Allow all other navigation
            decisionHandler(.allow)
        }
    }
}
