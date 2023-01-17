import UIKit
import WebKit


class WkWebViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: - Views
    
    let webView = WKWebView()
    let toolbar = UIToolbar()
    let goForward = UIBarButtonItem()
    
    
    // MARK: - Properties
    
    let url: URL
    var observerValue: NSKeyValueObservation?
    
    
    // MARK: - Init
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAllSubviews()
        setupSubviews()
        setupConstraints()
    }
}


// MARK: - Actions

extension WkWebViewController {
    
    @objc
    func close() {
        dismiss(animated: true)
    }
    
    @objc
    func goesBack() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc
    func onForwardButtonPressed() {
        guard webView.canGoForward else {
            Log.error("Unable to go forward.")
            return
        }
        
        webView.goForward()
    }
    
    @objc
    func shareLink() {
        guard let url = webView.url else {
            Log.error(CommonError.unableToParse("url", from: webView))
            return
        }
        
        self.present(UIActivityViewController(activityItems: [url], applicationActivities: nil), animated: true)
    }
    
    @objc
    func openInBrowser() {
        guard let url = webView.url else {
            Log.error(CommonError.unableToParse("url", from: webView))
            return
        }
        guard UIApplication.shared.canOpenURL(url) else {
            Log.error("Unable to open url - \(url)")
            return
        }
        
        UIApplication.shared.open(url)
    }
}


// MARK: - Private methods

private extension WkWebViewController {
    
    func addAllSubviews() {
        view.addSubviews(webView, toolbar)
    }
    
    func setupSubviews() {
        title = webView.url?.baseURL?.description ?? ""
        
        webView.load(URLRequest(url: url))
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", primaryAction: UIAction { [weak self] _ in
            self?.close()
        })
        
        toolbar.backgroundColor = .systemBackground
        
        toolbar.items = [
            .init(image: .init(systemName: "chevron.left"), style: .plain, target: self, action: #selector(goesBack)),
            .flexibleSpace(),
            .init(image: .init(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareLink)),
            .flexibleSpace(),
            .init(image: .init(systemName: "safari"), style: .plain, target: self, action: #selector(openInBrowser))
        ]
        
        observerValue = webView.observe(\.title) { [weak navigationItem] webView, _ in
            DispatchQueue.main.async {
                navigationItem?.title = webView.title
            }
        }
    }
    
    func setupConstraints() {
        webView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        toolbar.snp.makeConstraints { make in
            make.top.equalTo(webView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
