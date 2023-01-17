import CXoneChatSDK
import SafariServices
import UIKit


class ProActiveActionPopup: UIView {
    
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
            try CXoneChat.shared.analytics.proactiveActionSuccess(true, data: actionDetails)
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
        label.text = data["headingText"] as? String
        label.font = .preferredFont(forTextStyle: .title3, compatibleWith: .init(legibilityWeight: .bold))
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(18)
        }
        
        let headeLineLabel = UILabel(frame: .zero)
        headeLineLabel.text = data["bodyText"] as? String
        headeLineLabel.numberOfLines = 0
        headeLineLabel.lineBreakMode = .byWordWrapping
        addSubview(headeLineLabel)
        
        headeLineLabel.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        
        let closeButton = UIButton(type: .close)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
        }
        
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
        addSubview(button)
        
        button.snp.makeConstraints { make in
            make.top.equalTo(headeLineLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(18)
        }
        
        try? CXoneChat.shared.analytics.proactiveActionDisplay(data: actionDetails)
        
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
    }
}
