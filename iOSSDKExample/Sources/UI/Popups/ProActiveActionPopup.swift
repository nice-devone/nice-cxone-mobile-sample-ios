import CXoneChatSDK
import SafariServices
import UIKit


class ProActiveActionPopup: UIView {
    
    // MARK: - Views
    
    private let closeButton = UIButton(type: .close)
    
    
    // MARK: - Properties
    
    private var timer: Timer?
    private var timerFired = false
    
    private let data: [String: Any]
    private let actionId: UUID
    private let actionDetails: ProactiveActionDetails
    
    
    // MARK: - Init
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(data: [String: Any], actionId: UUID) {
        self.data = data
        self.actionId = actionId
        self.actionDetails = ProactiveActionDetails(
            id: actionId,
            name: "Custom Popup Box",
            type: .customPopupBox,
            content: ProactiveActionDataMessageContent(
                bodyText: data["bodyText"] as? String,
                headlineText: data["headingText"] as? String
            )
        )
        super.init(frame: .zero)
        
        setup()
    }
}


// MARK: - Actions

private extension ProActiveActionPopup {
    
    @objc
    func fireTimer() {
        timerFired = true
        
        do {
            try CXoneChat.shared.analytics.proactiveActionSuccess(false, data: actionDetails)
        } catch {
            error.logError()
        }
    }
    
    @objc
    func close(_ sender: UIButton) {
        isHidden = true
        
        if !timerFired {
            do {
                try CXoneChat.shared.analytics.proactiveActionSuccess(false, data: actionDetails)
            } catch {
                error.logError()
            }
        }
    }
}


// MARK: - Private methods

private extension ProActiveActionPopup {

    func setup() {
        layer.cornerRadius = 18
        
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = data["headingText"] as? String
        label.font = .systemFont(ofSize: 17, weight: .bold)
        addSubview(label)
        
        let headeLineLabel = UILabel(frame: .zero)
        headeLineLabel.translatesAutoresizingMaskIntoConstraints = false
        headeLineLabel.text = data["bodyText"] as? String
        headeLineLabel.numberOfLines = 0
        headeLineLabel.lineBreakMode = .byWordWrapping
        addSubview(headeLineLabel)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(closeButton)
        
        closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -9).isActive = true
        closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 9).isActive = true
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        let action = data["action"] as? [String: String]
        let text = action?["text"]
        
        let button = UIButton(configuration: .plain(), primaryAction: UIAction { [weak self] _ in
            guard let self = self, let urlString = action?["url"], let url = URL(string: urlString) else {
                return
            }
            
            UIApplication.shared.currentController?.present(SFSafariViewController(url: url), animated: true)
            
            try? CXoneChat.shared.analytics.proactiveActionClick(data: self.actionDetails)
            try? CXoneChat.shared.analytics.proactiveActionSuccess(true, data: self.actionDetails)
            
            self.timer?.invalidate()
        })
        button.setTitle(text, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            headeLineLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
            headeLineLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            headeLineLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            button.topAnchor.constraint(equalTo: headeLineLabel.bottomAnchor, constant: 5),
            button.centerXAnchor.constraint(equalTo: headeLineLabel.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18)
        ])
        
        try? CXoneChat.shared.analytics.proactiveActionDisplay(data: actionDetails)
        
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
    }
}
