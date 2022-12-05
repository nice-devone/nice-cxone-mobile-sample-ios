import UIKit


// MARK: - Protocol

public protocol PopupViewControllerDelegate: AnyObject {
	/// It is called when pop up is dismissed by tap outside
	func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController)
}

public extension PopupViewControllerDelegate {
	func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController) { }
}


// MARK: - Implementation

open class PopupViewController: UIViewController {
    
    // MARK: - Views
    
    /// The pop up view controller. It's not mandatory.
    private(set) open var contentController: UIViewController?
    /// The pop up view
    private(set) open var contentView: UIView?
    private var containerView = UIView()
    
    
    // MARK: - Properties
    
    /// Popup width, it's nil if width is determined by view's intrinsic size
    private(set) open var popupWidth: CGFloat?
    /// Popup height, it's nil if width is determined by view's intrinsic size
    private(set) open var popupHeight: CGFloat?
    /// Popup position, default is center
    private(set) open var position: PopupPosition = .center(nil)
    /// Background alpha, default is 0.5
    open var backgroundAlpha: CGFloat = 0.2
    /// Background color, default is black
    open var backgroundColor = UIColor.label
    /// Allow tap outside popup to dismiss, default is true
    open var canTapOutsideToDismiss = true
    /// Corner radius, default is 0 (no rounded corner)
    open var cornerRadius: CGFloat = 0
    /// Shadow enabled, default is true
    open var shadowEnabled = true
    /// The delegate to receive pop up event
    open weak var delegate: PopupViewControllerDelegate?
    
    private var isViewDidLayoutSubviewsCalled = false
    
    
    // MARK: - Init
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    /**
     Init with content view controller. Your pop up content is a view controller (easiest way to design it is using storyboard)
     - Parameters:
     - contentController: Popup content view controller
     - position: Position of popup content, default is center
     - popupWidth: Width of popup content. If it isn't set, width will be determine by popup content view intrinsic size.
     - popupHeight: Height of popup content. If it isn't set, height will be determine by popup content view intrinsic size.
     */
    public init(contentController: UIViewController, position: PopupPosition = .center(nil), popupWidth: CGFloat?, popupHeight: CGFloat?) {
        super.init(nibName: nil, bundle: nil)
        
        self.contentController = contentController
        self.contentView = contentController.view
        self.popupWidth = popupWidth
        self.popupHeight = popupHeight
        self.position = position
    }
    
    /**
     Init with content view
     - Parameters:
     - contentView: Popup content view
     - position: Position of popup content, default is center
     - popupWidth: Width of popup content. If it isn't set, width will be determine by popup content view intrinsic size.
     - popupHeight: Height of popup content. If it isn't set, height will be determine by popup content view intrinsic size.
     */
    public init(contentView: UIView, position: PopupPosition = .center(nil), popupWidth: CGFloat?, popupHeight: CGFloat?) {
        super.init(nibName: nil, bundle: nil)
        self.contentView = contentView
        self.popupWidth = popupWidth
        self.popupHeight = popupHeight
        self.position = position
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
        
        setupUI()
        addDismissGesture()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !isViewDidLayoutSubviewsCalled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.setupViews()
            }
        }
        
        isViewDidLayoutSubviewsCalled = true
    }
    
    
    // MARK: - Setup
    
    private func addDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTapGesture(gesture:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView?.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = backgroundColor.withAlphaComponent(backgroundAlpha)
        
        if cornerRadius > 0 {
            contentView?.layer.cornerRadius = cornerRadius
            contentView?.layer.masksToBounds = true
        }
        
        if shadowEnabled {
            containerView.layer.shadowOpacity = 0.2
            containerView.layer.shadowColor = UIColor.label.cgColor
            containerView.layer.shadowRadius = 3
            let dxVal = -1.0
            let rect = containerView.bounds.insetBy(dx: dxVal, dy: dxVal)
            containerView.layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
    
    private func setupViews() {
        if let contentController = contentController {
            addChild(contentController)
        }
        
        addViews()
        addSizeConstraints()
        addPositionConstraints()
    }
    
    private func addViews() {
        view.addSubview(containerView)
        
        guard let contentView = contentView else {
            Log.error(CommonError.unableToParse("contentView"))
            return
        }
        
        containerView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: containerView.rightAnchor)
        ])
    }
    
    
    // MARK: - Add constraints
    
    private func addSizeConstraints() {
        if let popupWidth = popupWidth {
            containerView.widthAnchor.constraint(equalToConstant: popupWidth).isActive = true
        }
        
        if let popupHeight = popupHeight {
            containerView.heightAnchor.constraint(equalToConstant: popupHeight).isActive = true
        }
    }
    
    private func addPositionConstraints() {
        switch position {
        case .center(let offset):
            addCenterPositionConstraints(offset: offset)
            
        case .topLeft(let offset):
            addTopLeftPositionConstraints(offset: offset, anchorView: nil)
            
        case .topRight(let offset):
            addTopRightPositionConstraints(offset: offset)
            
        case .bottomLeft(let offset):
            addBottomLeftPositionConstraints(offset: offset)
            
        case .bottomRight(let offset):
            addBottomRightPositionConstraints(offset: offset)
            
        case .top(let offset):
            addTopPositionConstraints(offset: offset)
            
        case .left(let offset):
            addLeftPositionConstraints(offset: offset)
            
        case .bottom(let offset):
            addBottomPositionConstraints(offset: offset)
            
        case .right(let offset):
            addRightPositionConstraints(offset: offset)
            
        case .offsetFromView(let offset, let anchorView):
            addTopLeftPositionConstraints(offset: offset, anchorView: anchorView)
        }
    }
    
    private func addCenterPositionConstraints(offset: CGPoint?) {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offset?.x ?? 0),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offset?.y ?? 0)
        ])
    }
    
    private func addTopLeftPositionConstraints(offset: CGPoint?, anchorView: UIView?) {
        var position: CGPoint = offset ?? .zero
        
        if let anchorView = anchorView {
            let anchorViewPosition = view.convert(CGPoint.zero, from: anchorView)
            position = CGPoint(x: position.x + anchorViewPosition.x, y: position.y + anchorViewPosition.y)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: position.y),
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: position.x)
        ])
    }
    
    private func addTopRightPositionConstraints(offset: CGPoint?) {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: offset?.y ?? 0),
            view.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: offset?.x ?? 0)
        ])
    }
    
    private func addBottomLeftPositionConstraints(offset: CGPoint?) {
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: offset?.y ?? 0),
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: offset?.x ?? 0)
        ])
    }
    
    private func addBottomRightPositionConstraints(offset: CGPoint?) {
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: offset?.y ?? 0),
            view.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: offset?.x ?? 0)
        ])
    }
    
    private func addTopPositionConstraints(offset: CGFloat) {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: offset),
            view.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0)
        ])
    }
    
    private func addLeftPositionConstraints(offset: CGFloat) {
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: offset),
            view.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0)
        ])
    }
    
    private func addBottomPositionConstraints(offset: CGFloat) {
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: offset),
            view.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0)
        ])
    }
    
    private func addRightPositionConstraints(offset: CGFloat) {
        NSLayoutConstraint.activate([
            view.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: offset),
            view.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0)
        ])
    }
}


// MARK: - Actions

extension PopupViewController {
    
	@objc
    func dismissTapGesture(gesture: UIGestureRecognizer) {
		dismiss(animated: true) {
			self.delegate?.popupViewControllerDidDismissByTapGesture(self)
		}
	}
}


// MARK: - UIGestureRecognizerDelegate

extension PopupViewController: UIGestureRecognizerDelegate {
    
	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		guard let touchView = touch.view, canTapOutsideToDismiss else {
			return false
		}
		
		return !touchView.isDescendant(of: containerView)
	}
}
