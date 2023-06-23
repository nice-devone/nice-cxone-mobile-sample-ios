import UIKit


class AudioPreviewView: UIView {
    
    // MARK: - Views
    
    let contentView = UIView()
    
    private let handleView = UIView()
    private let titleLabel = UILabel()
    
    private let audioContentView = UIView()
    let controlButton = UIButton()
    let recordingIndicatorView = UIView()
    let progressView = UIProgressView(progressViewStyle: .default)
    let timeLabel = UILabel()
    
    let deleteButton = UIButton()
    let recordControlButton = UIButton()
    let sendButton = UIButton()
    
    
    // MARK: - Properties
    
    private var isRecording = false
    
    private var isPlaying = false
    
    private let symbolConfig = UIImage.SymbolConfiguration(scale: .large)
    
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        
        addSubviews()
        setupSubviews()
        setupConstraints()
    }
    
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        audioContentView.layer.cornerRadius = 12
        contentView.roundCorners([.topLeft, .topRight], radius: 10)
    }
}


// MARK: - Actions

private extension AudioPreviewView {
    
    @objc
    func controlButtonDidTap() {
        isPlaying.toggle()
        
        controlButton.setImage(UIImage(systemName: isPlaying ? "pause.fill" : "play.fill", withConfiguration: symbolConfig), for: .normal)
    }
    
    @objc
    func recordControlButtonDidTap() {
        isRecording.toggle()
        
        titleLabel.text = isRecording ? "Recording new message..." : "Review your recorder message"
        progressView.tintColor = isRecording ? .black.withAlphaComponent(0.25) : .black
        
        controlButton.isEnabled = !isRecording
        deleteButton.isEnabled = !isRecording
        sendButton.isEnabled = !isRecording
        
        recordControlButton.setImage(
            UIImage(systemName: isRecording ? "mic.slash" : "arrow.2.circlepath.circle", withConfiguration: symbolConfig), for: .normal
        )
    }
}


// MARK: - Private methods

private extension AudioPreviewView {

    func addSubviews() {
        addSubview(contentView)
        contentView.addSubviews(handleView, titleLabel, audioContentView, deleteButton, recordControlButton, sendButton)
        audioContentView.addSubviews(controlButton, progressView, timeLabel)
    }
    
    func setupSubviews() {
        contentView.backgroundColor = .white
        
        handleView.backgroundColor = .lightGray
        handleView.layer.cornerRadius = 2
        
        titleLabel.text = "Review your recorder message"
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        titleLabel.textColor = .lightGray
        
        audioContentView.backgroundColor = .lightGray.withAlphaComponent(0.2)
        
        controlButton.setImage(UIImage(systemName: "play.fill", withConfiguration: symbolConfig), for: .normal)
        controlButton.tintColor = .black
        controlButton.addTarget(self, action: #selector(controlButtonDidTap), for: .touchUpInside)
        
        progressView.progress = 1
        progressView.tintColor = .black
        
        timeLabel.font = .preferredFont(forTextStyle: .caption1, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        
        deleteButton.setImage(UIImage(systemName: "trash.fill", withConfiguration: symbolConfig), for: .normal)
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.tintColor = .red
        deleteButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        recordControlButton.setImage(UIImage(systemName: "arrow.2.circlepath.circle", withConfiguration: symbolConfig), for: .normal)
        recordControlButton.imageView?.contentMode = .scaleAspectFit
        recordControlButton.tintColor = .systemBlue
        recordControlButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        recordControlButton.addTarget(self, action: #selector(recordControlButtonDidTap), for: .touchUpInside)
        
        sendButton.setImage(UIImage(systemName: "arrow.right.circle.fill", withConfiguration: symbolConfig), for: .normal)
        sendButton.imageView?.contentMode = .scaleAspectFit
        sendButton.tintColor = .systemBlue
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        handleView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.centerX.equalToSuperview()
            make.height.equalTo(4)
            make.width.equalTo(32)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(handleView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        audioContentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalTo(titleLabel)
        }
        controlButton.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(12)
        }
        progressView.snp.makeConstraints { make in
            make.centerY.equalTo(controlButton)
            make.leading.lessThanOrEqualTo(controlButton.snp.trailing).offset(10)
        }
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(progressView)
            make.leading.equalTo(progressView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(24)
        }
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(audioContentView.snp.bottom).offset(40)
            make.leading.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(10)
        }
        recordControlButton.snp.makeConstraints { make in
            make.centerY.equalTo(deleteButton)
            make.leading.equalTo(deleteButton.snp.trailing).offset(4)
        }
        sendButton.snp.makeConstraints { make in
            make.centerY.equalTo(deleteButton)
            make.trailing.equalTo(titleLabel)
        }
    }
}
