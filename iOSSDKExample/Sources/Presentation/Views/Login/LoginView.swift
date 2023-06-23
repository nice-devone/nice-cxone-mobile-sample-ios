import SnapKit
import UIKit


class LoginView: UIView {
    
    // MARK: - Views
    
    private let stackView = UIStackView()
    
    let guestButton = PrimaryButton()
    let oAuthButton = UIButton()
    
    
    // MARK: - Initialization

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)

        addAllSubviews()
        setupSubviews()
        setupConstraints()
    }
}


// MARK: - Private methods

private extension LoginView {
    
    func addAllSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubviews(guestButton, oAuthButton)
    }

    func setupSubviews() {
        backgroundColor = .systemBackground
        
        stackView.axis = .vertical
        stackView.spacing = 10
        
        guestButton.setTitle("Continue as guest", for: .normal)
        
        oAuthButton.setImage(Assets.btnLWA_gold_209x48, for: .normal)
        oAuthButton.setImage(Assets.btnLWA_gold_209x48pressed, for: .selected)
        oAuthButton.isHidden = true
    }
    
    func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        oAuthButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
}
