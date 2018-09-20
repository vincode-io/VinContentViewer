//Copyright © 2018 Vincode, Inc. All rights reserved.

import Cocoa
import WebKit
import VinContent

class ViewController: NSViewController {

    private var webView: WKWebView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let preferences = WKPreferences()
        preferences.minimumFontSize = 12.0
        preferences.javaScriptCanOpenWindowsAutomatically = false
        preferences.javaEnabled = false
        preferences.javaScriptEnabled = true
        preferences.plugInsEnabled = false
        preferences.setValue(true, forKey: "developerExtrasEnabled")

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.topAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        let url = URL(string: "https://9to5mac.com/2018/09/20/apple-miniseries-defending-jacob/")
//        let url = URL(string: "https://blog.chromium.org/2018/02/chrome-65-beta-css-paint-api-and.html")
//        let url = URL(string: "https://developer.apple.com/documentation/uikit/view_controllers/preserving_your_app_s_ui_across_launches?language=swift")
        let contentArticle = try! ContentExtractor.extractArticle(from: url!)
        let html = renderHTML(withBody: contentArticle.wrappedContent!)
        webView!.loadHTMLString(html, baseURL: nil)

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func renderHTML(withBody body: String) -> String {
        
        var s = "<!DOCTYPE html><html><head>\n\n"

        let path = Bundle.main.path(forResource: "styleSheet", ofType: "css")!
        let css = try! NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
        s += "<style>\n\(css)\n</style>"

        s += "\n\n</head><body id='bodyId' onload='startup()' class=dark>\n\n"
        s += body
        s += "\n\n</body></html>"
        
        return s
        
    }
}

