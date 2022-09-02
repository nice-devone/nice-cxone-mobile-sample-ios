
import UIKit
import SafariServices
import CXOneChatSDK
class ProActiveActionPopup: UIView {
    let data: [String: Any]
    let actionId: UUID
    let closeButton = UIButton(type: .close)
    let actionDetails: ProactiveActionDetails
    var timer: Timer!
    var timerFired = false
    init(data: [String: Any], actionId: UUID) {
        self.data = data
        self.actionId = actionId
        self.actionDetails = ProactiveActionDetails(actionId: actionId, actionName: "Custom Popup Box", actionType: .customPopupBox, data: ProactiveActionData(content: ProactiveActionDataMessageContent(bodyText: data["bodyText"] as? String, headlineText: data["headingText"] as? String, headlineSecondaryText: nil, image: nil)))
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
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
        let url = action?["url"]
        let button = UIButton(configuration: .plain(), primaryAction: UIAction(handler: {[weak self] _ in
            let svc = SFSafariViewController(url: URL(string: url!)!)
            self?.getCurrentViewController()?.present(svc, animated: true, completion: nil)
            guard let self = self else {return}
            try? CXOneChat.shared.reportProactiveActionClick(data: self.actionDetails)
            try? CXOneChat.shared.reportProactiveActionSuccess(data: self.actionDetails)
            self.timer.invalidate()
        }))
        button.setTitle(text, for: .normal)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
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
        layer.cornerRadius = 18
        try? CXOneChat.shared.reportProactiveActionDisplay(data: actionDetails)
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
    }
    
    @objc func close(_ sender: UIButton) {
        self.isHidden = true
        if !timerFired {
            try? CXOneChat.shared.reportProactiveActionFail(data: actionDetails)
        }
    }
    
    private func getCurrentViewController() -> UIViewController? {

        if let rootController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    @objc func fireTimer() {
        timerFired = true
        try? CXOneChat.shared.reportProactiveActionFail(data: actionDetails)
    }
}
