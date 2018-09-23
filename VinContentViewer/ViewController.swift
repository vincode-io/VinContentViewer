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
        
        guard let documentDirectory = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            return
        }
        
        
//        let url = URL(string: "https://kottke.org/18/09/the-fish-copter-cactus-binky-and-other-clever-visual-mashups")
//        let url = URL(string: "https://blog.chromium.org/2018/02/chrome-65-beta-css-paint-api-and.html")
//        let url = URL(string: "https://developer.apple.com/documentation/uikit/view_controllers/preserving_your_app_s_ui_across_launches?language=swift")
        
        let testName = "wired"
        let testSource = "https://www.wired.com/2017/03/now-we-know-why-microsoft-bought-linkedin/"
        
        // Load the input HTML
        let testURL = URL(string: testSource)!
        let inputHTML = try! String(contentsOf: testURL)

        // Write out the source HTML for testing
        let inputURL = documentDirectory.appendingPathComponent("\(testName)-input.html")
        try! inputHTML.write(to: inputURL, atomically: true, encoding: .utf16)

        let article = try! ContentExtractor.extractArticle(from: inputHTML, source: testURL)
        let content = article.wrappedContent!

        // Render the content in the window
        let html = renderHTML(withBody: content)
        webView!.loadHTMLString(html, baseURL: nil)

        // Write the result out for tests
        let resultURL = documentDirectory.appendingPathComponent("\(testName)-expected.html")
        try! content.write(to: resultURL, atomically: true, encoding: .utf16)
        
        print("**************************************************")
        print("* Article Title: \(String(describing: article.title))")
        print("* Article Publisher: \(String(describing: article.publisher))")
        print("* Article Publish Date: \(String(describing: article.publishDate?.description))")
        print("* Article Byline: \(String(describing: article.byline))")
        print("* Article Source: \(String(describing: article.source?.absoluteString))")
        print("**************************************************")
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

        s += "\n\n</head><body id='bodyId' class=dark>\n\n"
        s += body
        s += "\n\n</body></html>"
        
        return s
        
    }
}

