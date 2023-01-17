import CXoneChatSDK
import SafariServices
import UIKit


protocol PluginMessageDelegate: AnyObject {
    func pluginMessageView(_ view: PluginMessageView, quickReplySelected text: String)
    func pluginMessageView(_ view: PluginMessageView, subElementDidTap subElement: PluginMessageSubElementType)
}

/// View to display for the plugin messages.
class PluginMessageView: UIView {
    
    // MARK: - Properties
    
    private var messageType: PluginMessageType?
    
    private var stackView = UIStackView()
    
    weak var delegate: PluginMessageDelegate?
    
    static let fileImageHeight: CGFloat = 100
    
    
    // MARK: - Init
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(frame: .zero)
        
        setupStackView()
    }
    
    
    // MARK: - Methods
    
    func configure(with messageType: PluginMessageType) {
        guard self.messageType == nil else {
            return
        }
        
        self.messageType = messageType
        
        handleMessageType(messageType, in: &stackView)
    }
}


// MARK: - Private methods

private extension PluginMessageView {
    
    func handleMessageType(_ type: PluginMessageType, in stackView: inout UIStackView) {
        switch type {
        case .textAndButtons(let entity):
            setupTextAndButtons(entity, in: &stackView)
        case .satisfactionSurvey(let entity):
            setupSatisfactionSurvey(entity, in: &stackView)
        case .menu(let entity):
            setupMenu(entity, in: &stackView)
        case .quickReplies(let entity):
            setupQuickReplies(entity, in: &stackView)
        case .gallery(let entities):
            let scrollView = UIScrollView()
            scrollView.isUserInteractionEnabled = true
            scrollView.showsHorizontalScrollIndicator = false
            addSubview(scrollView)
            
            scrollView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            stackView.removeFromSuperview()
            stackView.snp.removeConstraints()
            scrollView.addSubview(stackView)
            stackView.axis = .horizontal
            stackView.distribution = .fill
            
            stackView.snp.makeConstraints { make in
                make.edges.height.equalToSuperview()
            }
            
            setupGallery(entities, in: &stackView)
        case .subElements(let subElements):
            subElements.forEach { subElement in
                setupSubElement(subElement, into: &stackView)
            }
        case .custom(let entity):
            setupCustomVariables(entity.variables, in: &stackView)
        }
    }
    
    func setupTextAndButtons(_ element: PluginMessageTextAndButtons, in stackView: inout UIStackView) {
        element.elements.forEach { subElement in
            setupSubElement(subElement, into: &stackView)
        }
    }
    
    func setupSatisfactionSurvey(_ element: PluginMessageSatisfactionSurvey, in stackView: inout UIStackView) {
        element.elements.forEach { subElement in
            setupSubElement(subElement, into: &stackView)
        }
    }
    
    func setupMenu(_ element: PluginMessageMenu, in stackView: inout UIStackView) {
        element.elements.forEach { subElement in
            setupSubElement(subElement, into: &stackView)
        }
    }
    
    func setupQuickReplies(_ element: PluginMessageQuickReplies, in stackView: inout UIStackView) {
        element.elements.forEach { subElement in
            guard case .button(let entity) = subElement else {
                setupSubElement(subElement, into: &stackView)
                return
            }
            
            var config = UIButton.Configuration.bordered()
            config.buttonSize = .medium
            config.cornerStyle = .capsule
            
            let button = UIButton(configuration: config, primaryAction: UIAction(title: entity.text) { [weak self, weak delegate] _ in
                guard let self else {
                    return
                }
                
                self.isUserInteractionEnabled = false
                
                delegate?.pluginMessageView(self, quickReplySelected: entity.text)
            })
            
            stackView.addArrangedSubview(button)
        }
    }
    
    func setupGallery(_ elements: [PluginMessageType], in stackView: inout UIStackView) {
        elements.forEach { entity in
            var subStackView = UIStackView()
            stackView.addArrangedSubview(subStackView)
            subStackView.axis = .vertical
            subStackView.distribution = .fillProportionally
            subStackView.spacing = 10
            
            handleMessageType(entity, in: &subStackView)
        }
    }
    
    func setupCustomVariables(_ variables: [String: Any], in stackView: inout UIStackView) {
        // Currently support only buttons
        guard let buttons = variables["buttons"] as? [[String: String]] else {
            Log.error("Only buttons with color and size are currently supported for a custom plugin.")
            return
        }
        guard let color = variables["color"] as? String else {
            Log.error(.unableToParse("color", from: variables))
            return
        }
        guard let size = variables["size"] as? [String: String] else {
            Log.error(.unableToParse("color", from: variables))
            return
        }
        
        buttons.forEach { button in
            guard let id = button["id"] else {
                Log.error(.unableToParse("id", from: button))
                return
            }
            guard let title = button["name"]else {
                Log.error(.unableToParse("name", from: button))
                return
            }
            
            var config = UIButton.Configuration.filled()
            config.buttonSize = .get(for: size["ios"])
            config.baseBackgroundColor = UIColor(hexString: color)
            
            let button = UIButton(configuration: config, primaryAction: UIAction(title: title) { [weak delegate] _ in
                delegate?.pluginMessageView(self, subElementDidTap: .button(.init(id: id, text: title, postback: nil, url: nil, displayInApp: false)))
            })
            
            stackView.addArrangedSubview(button)
        }
    }
    
    func setupSubElement(_ subElement: PluginMessageSubElementType, into stackView: inout UIStackView) {
        switch subElement {
        case .text(let entity):
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .preferredFont(forTextStyle: .body)
            label.text = entity.text
            
            stackView.addArrangedSubview(label)
        case .title(let entity):
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .preferredFont(forTextStyle: .title2)
            label.textAlignment = .center
            label.text = entity.text
            
            stackView.addArrangedSubview(label)
        case .button(let entity):
            let button = UIButton(configuration: .filled(), primaryAction: UIAction(title: entity.text) { [weak self, weak delegate] _ in
                guard let self else {
                    return
                }
                
                self.isUserInteractionEnabled = false
                
                delegate?.pluginMessageView(self, subElementDidTap: subElement)
            })
            
            stackView.addArrangedSubview(button)
        case .file(let entity):
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.load(url: entity.url)
            imageView.layer.cornerRadius = 5

            imageView.snp.makeConstraints { make in
                make.height.equalTo(Self.fileImageHeight)
            }
            
            stackView.addArrangedSubview(imageView)
        }
    }
    
    func setupStackView() {
        addSubview(stackView)
        stackView.isUserInteractionEnabled = true
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 10

        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.lessThanOrEqualToSuperview().inset(10)
        }
    }
}


// MARK: - Helpers

private extension UIButton.Configuration.Size {

    static func get(for value: String?) -> UIButton.Configuration.Size {
        switch value {
        case "big":
            return .large
        case "middle":
            return .medium
        case "small":
            return .small
        default:
            return .mini
        }
    }
}
