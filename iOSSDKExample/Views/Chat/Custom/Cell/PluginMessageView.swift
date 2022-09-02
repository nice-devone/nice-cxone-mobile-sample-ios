import Foundation
import CXOneChatSDK
import UIKit
import SafariServices

/// View to display for the plugin messages.
public class PluginMessageView: UIView, UIScrollViewDelegate {
	let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
	var elements: [MessageElement] = []
//	var pageControl : UIPageControl = UIPageControl(frame: CGRect(x: 50, y: 300, width: 200, height: 50))
	
	func configure(elements: [MessageElement]) {
//		configurePageControl()
		scrollView.delegate = self
		scrollView.layer.cornerRadius = 20
		if elements.count > 1 {
			scrollView.isPagingEnabled = true
		}

		self.addSubview(scrollView)
		configurePlugin(elements: elements)

		self.scrollView.contentSize = CGSize(width:self.scrollView.frame.size.width * CGFloat(elements.count), height: self.scrollView.frame.size.height)
		self.scrollView.isScrollEnabled = true
//		pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
	}
	
	private func configurePlugin(elements: [MessageElement]) {
		var i = 0
		self.elements = elements
		for element in elements {
            let stackView: UIStackView = {
                let stackView = UIStackView()
				stackView.axis = .vertical
                stackView.distribution = .fillEqually
				stackView.spacing = 10
				stackView.isLayoutMarginsRelativeArrangement = true
				stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
				return stackView
			}()
            if element.type == .menu || element.type == .quickReplies || element.type == .inactivityPopup || element.type == .satisfactionSurvey {
				guard let subElements = element.elements else { return }
				for subElement in subElements {
                    if subElement.type == .text {
						let label = UILabel()
						label.numberOfLines = 0
						label.font = UIFont.preferredFont(forTextStyle: .body)
                        label.text = subElement.text
						label.height(constant: 40)
						stackView.addArrangedSubview(label)
                    } else if subElement.type == .title {
						let label = UILabel()
						label.numberOfLines = 0
						label.font = UIFont.preferredFont(forTextStyle: .title2)
                        label.text = subElement.text
						label.height(constant: 40)
						stackView.addArrangedSubview(label)
                    } else if subElement.type == .countdown {
                    } else if (subElement.type == .button || subElement.type == .iFrameButton){
                        let button = PressableButton()
						button.colors = .init(
                            button: .primaryColor,
                            shadow: UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1)
						)
						button.setTitle(subElement.text, for: .normal)
						button.addTarget(self, action: #selector(handleButtonAction(sender:)), for: .touchUpInside)
						button.tag = i
                        if subElement.type == .iFrameButton {
                            button.height(constant: 40)
                        } else {
                            button.height(constant: 60)
                        }
						stackView.addArrangedSubview(button)
                    } else if subElement.type == .file {
						if let url = subElement.url, subElement.url != "" {
                            let imageView = UIImageView()
							imageView.contentMode = .scaleAspectFit
							imageView.load(url: URL(string: url)!, completion: {
								image in
							})
							imageView.layer.cornerRadius = 5
							imageView.height(constant: 60)
							stackView.addArrangedSubview(imageView)
						}
                    } else if subElement.type == .custom {
                        // TODO: Handle custom plugin
                    }
                }
                if element.type == .satisfactionSurvey {
                    scrollView.frame = CGRect(x: 0, y: 0, width: 320, height: 150)
                    stackView.distribution = .fillProportionally
                }
            } else if element.type == .button {
                                let label = UILabel()
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.font = UIFont.systemFont(ofSize: 17)
                label.text = element.text
                let textHeight = element.text.height(withConstrainedWidth: 320, font: UIFont.systemFont(ofSize: 17))
                stackView.addArrangedSubview(label)
                var config = UIButton.Configuration.plain()
                config.title = "Deep Link"
                let button = UIButton(configuration: config, primaryAction: nil)
                button.addTarget(self, action: #selector(handleButtonAction(sender:)), for: .touchUpInside)
                stackView.addArrangedSubview(button)
                print(textHeight)
                if textHeight < 22 {
                    stackView.distribution = .fillProportionally
                } else {
                    stackView.distribution = .equalSpacing
                }

                scrollView.frame = CGRect(x: 0, y: 0, width: 320, height: textHeight + 50 + 22)
            }
			stackView.frame = CGRect.init(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
			stackView.frame.origin.x = self.scrollView.frame.size.width * CGFloat(i)
			stackView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
			self.scrollView.addSubview(stackView)
			i += 1
		}
	}
    
    @objc private func handleButtonAction(sender: UIButton) {
        guard let postback = elements[sender.tag].postback else { return }
        if elements[sender.tag].type == .satisfactionSurvey {
            guard let urlString: String = elements[sender.tag].elements?.last?.url else {return}
            guard let url = URL(string: urlString) else {return}
            let svc = SFSafariViewController(url: url)
            getCurrentViewController()?.present(svc, animated: true, completion: nil)
        } else if elements[0].type == .button {
            let vc = UIStoryboard(name: "DeepLinkStoryBoard", bundle: nil).instantiateInitialViewController()
            getCurrentViewController()?.show(vc!, sender: nil)
        } else if postback == "" {
            let svc = SFSafariViewController(url: URL(string: "https://www.google.com")!)
            getCurrentViewController()?.present(svc, animated: true, completion: nil)
        } else {
            let svc = SFSafariViewController(url: URL(string: postback )!)
            getCurrentViewController()?.present(svc, animated: true, completion: nil)
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
	
//	func configurePageControl() {
//		// The total number of pages that are available is based on how many available colors we have.
//		self.pageControl.numberOfPages = elements.count
//		self.pageControl.currentPage = 0
//		self.pageControl.tintColor = UIColor.red
//		self.pageControl.pageIndicatorTintColor = UIColor.black
//		self.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
//		self.addSubview(pageControl)
//	}

	// MARK: TO CHANGE WHILE CLICKING ON PAGE CONTROL
//	@objc func changePage(sender: AnyObject) -> () {
//		let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
//		scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
//	}

//	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//		let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
//		pageControl.currentPage = Int(pageNumber)
//	}
}
