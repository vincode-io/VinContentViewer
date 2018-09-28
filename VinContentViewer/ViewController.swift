//Copyright © 2018 Vincode, Inc. All rights reserved.

import Cocoa
import WebKit
import VinContent

class ViewController: NSViewController, ContentExtractorDelegate {
 
//    let testName = "authenticavl"
//    let testSource = "https://authenticavl.com/travel/crater-lake-national-park/"
    
    //        let testName = "foxnews"
    //        let testSource = "http://www.foxnews.com/us/2018/09/24/woman-in-viral-memorial-day-beach-arrest-is-indicted.html"
    
    //        let testName = "android-dev"
    //        let testSource = "https://android-developers.googleblog.com/2018/09/android-studio-32.html"
    
    //        let testName = "mandatory"
    //        let testSource = "http://www.mandatory.com/living/1465085-ranked-the-5-best-programming-languages-you-should-learn-in-2018"
    //
    //        let testName = "forbes"
    //        let testSource = "https://www.forbes.com/sites/startswithabang/2018/07/20/this-simple-thought-experiment-shows-why-we-need-quantum-gravity/"
    
    
    //        let testName = "washingtonpost"
    //        let testSource = "https://www.washingtonpost.com/politics/2018/09/23/cosby-accusers-powerful-message-christine-blasey-ford/?utm_term=.568a8bde6833"
    
    //        let testName = "mondaynote"
    //        let testSource = "https://mondaynote.com/50-years-in-tech-part-5-starting-apple-france-a925e0d4c169?source=rss-d6c6baafd47d------2"
    
//    let testName = "wired"
//    let testSource = "https://www.wired.com/2017/03/now-we-know-why-microsoft-bought-linkedin"

    let testName = "nytimes"
    let testSource = "https://www.nytimes.com/2018/09/24/world/middleeast/iran-attack-military-parade.html"

    private var extractor: ContentExtractor!
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
        
        
        let url = URL(string: testSource)!
        extractor = ContentExtractor(url)
        extractor.delegate = self
        extractor.process()
        
    }

    func processDidFail(with error: Error) {
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        print(error)
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    }
    
    func processDidComplete(article: ExtractedArticle) {
        
        guard let documentDirectory = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            return
        }

        let content = article.wrappedContent!
        
        let inputURL = documentDirectory.appendingPathComponent("\(testName)-input.html")
        try! article.sourceHTML!.write(to: inputURL, atomically: true, encoding: .utf8)

        // Render the content in the window
        let html = renderHTML(withBody: content)
        webView!.loadHTMLString(html, baseURL: nil)
        
        // Write the result out for tests
        let resultURL = documentDirectory.appendingPathComponent("\(testName)-expected.html")
        try! content.write(to: resultURL, atomically: true, encoding: .utf8)
        
        print("**************************************************")
        print("* Article Title: \(String(describing: article.title))")
        print("* Article Publisher: \(String(describing: article.publisher))")
        print("* Article Publish Date: \(String(describing: article.publishDate?.description))")
        print("* Article Byline: \(String(describing: article.byline))")
        print("* Article Source: \(String(describing: article.description))")
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

