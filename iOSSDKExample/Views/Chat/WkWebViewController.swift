import UIKit
import WebKit

class WkWebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var url: URL!
    var toolbar: UIToolbar!
    var observerValue: NSKeyValueObservation?
    var goForward: UIBarButtonItem!
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate(
        [
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        title = webView.url?.baseURL?.description ?? ""
        let item = UIBarButtonItem(title: "Close", image: nil, primaryAction: UIAction(handler: {_ in
            self.close()
        }), menu: nil)
        navigationItem.leftBarButtonItem = item
        let appareance = UINavigationBarAppearance()
        appareance.backgroundColor =  UIColor(named: "BackColor") ?? .systemBackground
        navigationController?.navigationBar.standardAppearance = appareance
        navigationController?.navigationBar.scrollEdgeAppearance = appareance
        toolbar = UIToolbar()
        toolbar.backgroundColor = .systemBackground
        view.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            toolbar.topAnchor.constraint(equalTo: webView.bottomAnchor)
        ])
        layoutToolbar()
        observerValue = webView.observe(\.title) {(webV, _) in
            DispatchQueue.main.async {
                self.navigationItem.title = webV.title
            }
        }
        

    }
}
extension WkWebViewController {
    @objc func close() {
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
}
extension WkWebViewController {
    func layoutToolbar() {
        var items: [UIBarButtonItem] = []
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let goback = UIBarButtonItem(image: .init(systemName: "chevron.left"),
                                     style: .plain, target: self, action: #selector(goesBack))
        items.append(goback)
        items.append(space)
//        goForward = UIBarButtonItem(image: .init(systemName: "chevron.right"),
//                                        style: .plain, target: self, action: #selector(onForwardButtonPressed))
//        goForward.isEnabled = false
//        items.append(goForward)
//        items.append(space)
        let share = UIBarButtonItem(image: .init(systemName: "square.and.arrow.up"),
                                    style: .plain, target: self, action: #selector(shareLink))
        items.append(share)
        items.append(space)
        let browser = UIBarButtonItem(image: .init(systemName: "safari"),
                                      style: .plain, target: self, action: #selector(openInBrowser))
        items.append(browser)
        self.toolbar.items = items
    }
}
extension WkWebViewController {
    @objc func goesBack() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @objc func onForwardButtonPressed() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    @objc func shareLink() {
        guard let url = webView.url else { return }
        let items = [url]
        let sheet = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(sheet, animated: true)
    }
    @objc func openInBrowser() {
        guard let url = webView.url else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

