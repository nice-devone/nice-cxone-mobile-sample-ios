import CXoneChatSDK
import SafariServices
import UIKit


/// View to display for the plugin messages.
class PluginMessageView: UIView, UIScrollViewDelegate {
    
    // MARK: - Views
    
    let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
    var elements: [MessageElement] = []
    
    
    // MARK: - Methods
    
    func configure(elements: [MessageElement]) {
        addSubview(scrollView)
        
        scrollView.contentSize = CGSize(
            width: scrollView.frame.size.width * CGFloat(elements.count),
            height: scrollView.frame.size.height
        )
        scrollView.delegate = self
        scrollView.layer.cornerRadius = 20
        scrollView.isPagingEnabled = elements.count > 1
        scrollView.isScrollEnabled = true
        
        configurePlugin(elements: elements)
    }
}


// MARK: - Actions

private extension PluginMessageView {
    
    @objc
    func handleButtonAction(sender: UIButton) {
        guard let postback = elements[safe: sender.tag]?.postback else {
            Log.error(CommonError.unableToParse("postback", from: elements[safe: sender.tag]))
            return
        }
        
        if elements[safe: sender.tag]?.type == .satisfactionSurvey {
            guard let urlString = elements[safe: sender.tag]?.elements?.last?.url, let url = URL(string: urlString) else {
                Log.error(CommonError.unableToParse("url", from: elements[safe: sender.tag]?.elements?.last?.url))
                return
            }
            
            UIApplication.shared.rootViewController?.present(SFSafariViewController(url: url), animated: true)
        } else if elements[safe: 0]?.type == .button {
            guard let controller = UIStoryboard(name: "DeepLinkStoryBoard", bundle: nil).instantiateInitialViewController() else {
                Log.error("Could not init DeepLinkStoryBoard")
                return
            }
            
            UIApplication.shared.rootViewController?.show(controller, sender: self)
        } else if postback == "" {
            guard let url = URL(string: "https://www.google.com") else {
                Log.error(CommonError.unableToParse("url"))
                return
            }
            UIApplication.shared.rootViewController?.present(SFSafariViewController(url: url), animated: true)
        } else {
            guard let url = URL(string: postback) else {
                Log.error(CommonError.unableToParse("url", from: postback))
                return
            }
            
            UIApplication.shared.rootViewController?.present(SFSafariViewController(url: url), animated: true)
        }
    }
}


// MARK: - Private methods

private extension PluginMessageView {
    
    func configurePlugin(elements: [MessageElement]) {
        self.elements = elements
        var index = 0
        
        for element in elements {
            var stackView = UIStackView()
            stackView.axis = .vertical
            stackView.distribution = .fillEqually
            stackView.spacing = 10
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
            
            switch element.type {
            case .menu, .quickReplies, .inactivityPopup, .satisfactionSurvey:
                guard let subElements = element.elements else {
                    Log.error(CommonError.unableToParse("subElements", from: element))
                    return
                }
                
                for subElement in subElements {
                    setupSubElement(subElement, withIndex: index, in: &stackView)
                }
                
                if element.type == .satisfactionSurvey {
                    scrollView.frame = CGRect(x: 0, y: 0, width: 320, height: 150)
                    stackView.distribution = .fillProportionally
                }
            case .button:
                setupDeeplinkButton(with: element, in: &stackView)
            default:
                Log.warning("Trying to handle unsupported element type - \(element.type)")
            }
            
            stackView.frame = CGRect.init(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            stackView.frame.origin.x = scrollView.frame.size.width * CGFloat(index)
            stackView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            
            scrollView.addSubview(stackView)
            
            index += 1
        }
    }
    
    func setupSubElement(_ subElement: MessageElement, withIndex index: Int, in stackView: inout UIStackView) {
        switch subElement.type {
        case .text:
            let label = UILabel()
            stackView.addArrangedSubview(label)
            
            label.numberOfLines = 0
            label.font = .preferredFont(forTextStyle: .body)
            label.text = subElement.text
            
            label.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
        case .title:
            let label = UILabel()
            stackView.addArrangedSubview(label)
            
            label.numberOfLines = 0
            label.font = .preferredFont(forTextStyle: .title2)
            label.text = subElement.text
            
            label.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
        case .button, .iFrameButton:
            let button = PressableButton()
            stackView.addArrangedSubview(button)
            
            button.colors = .init(button: .primaryColor, shadow: UIColor(rgb: 41, 128, 185))
            button.setTitle(subElement.text, for: .normal)
            button.addTarget(self, action: #selector(handleButtonAction(sender:)), for: .touchUpInside)
            button.tag = index
            
            button.snp.makeConstraints { make in
                make.height.equalTo(subElement.type == .iFrameButton ? 40 : 60)
            }
        case .file:
            if let urlString = subElement.url, let url = URL(string: urlString) {
                let imageView = UIImageView()
                stackView.addArrangedSubview(imageView)
                
                imageView.contentMode = .scaleAspectFit
                imageView.load(url: url)
                imageView.layer.cornerRadius = 5
                
                
                imageView.snp.makeConstraints { make in
                    make.height.equalTo(60)
                }
            }
        default:
            Log.warning("Trying to handle unsupported subelement type - \(subElement.type)")
        }
    }
    
    func setupDeeplinkButton(with element: MessageElement, in stackView: inout UIStackView) {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = element.text
        
        let textHeight = element.text.height(withConstrainedWidth: 320, font: UIFont.systemFont(ofSize: 17))
        stackView.addArrangedSubview(label)
        
        var config = UIButton.Configuration.plain()
        config.title = "Deep Link"
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(handleButtonAction), for: .touchUpInside)
        stackView.addArrangedSubview(button)
        
        stackView.distribution = textHeight < 22 ? .fillProportionally : .equalSpacing
        
        scrollView.frame = CGRect(x: 0, y: 0, width: 320, height: textHeight + 50 + 22)
    }
}
