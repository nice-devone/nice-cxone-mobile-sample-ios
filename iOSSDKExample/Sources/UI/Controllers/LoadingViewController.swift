import UIKit


class LoadingViewController: UIViewController {
    
    // MARK: - Properties
    
    private let stackView = UIStackView()
    
    let titleLabel = UILabel()
    var loadingActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.color = .white
        
        indicator.startAnimating()
        
        indicator.autoresizingMask = [
            .flexibleLeftMargin,
            .flexibleRightMargin,
            .flexibleTopMargin,
            .flexibleBottomMargin
        ]
        
        return indicator
    }()
    
    var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 1
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return blurEffectView
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.insertSubview(blurEffectView, at: 0)
        view.addSubview(stackView)
        stackView.addArrangedSubviews(loadingActivityIndicator, titleLabel)
        
        blurEffectView.frame = self.view.bounds
        
        stackView.axis = .vertical
        stackView.spacing = 10
        
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = .preferredFont(forTextStyle: .title3)
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
}
