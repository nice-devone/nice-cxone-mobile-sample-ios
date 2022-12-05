import UIKit


class PrimaryButton: BaseButton {
    
    // MARK: - Init
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init() {
        super.init()
        
        configure()
    }
}


// MARK: - Private methods

private extension PrimaryButton {
    
    func configure() {
        configuration?.baseBackgroundColor = .systemBlue
        setTitleColor(.white, for: .normal)
    }
}
