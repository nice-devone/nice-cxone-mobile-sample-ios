//
//  ImageCarousel.swift
//  iOSSDKExample
//
//  Created by Customer Dynamics Development on 12/9/21.
//

import Foundation
import CXOneChatSDK
import UIKit
import SafariServices

public class CarouselView: UIView, UIScrollViewDelegate {
	let scrollView = UIScrollView(frame: CGRect(x:0, y:0, width:320,height: 300))
	var elements: [MessagePayloadElement?] = []
	var pageControl : UIPageControl = UIPageControl(frame: CGRect(x:50,y: 300, width:200, height:50))
	
	func configure(elements: [MessagePayloadElement?]) {
		//configurePageControl()
		
		scrollView.delegate = self
		scrollView.layer.cornerRadius = 20
		if elements.count > 1 {
			scrollView.isPagingEnabled = true
		}

		self.addSubview(scrollView)
		configurePlugin(elements: elements)

		self.scrollView.contentSize = CGSize(width:self.scrollView.frame.size.width * CGFloat(elements.count), height: self.scrollView.frame.size.height)
		self.scrollView.isScrollEnabled = true
		pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
	}
	
	func configurePlugin(elements: [MessagePayloadElement?]) {
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
			if element?.type == "MENU" || element?.type == "QUICK_REPLIES" || element?.type == "INACTIVITY_POPUP" {
				guard let elements = element?.elements else { return }
				for plugin in elements {
					if plugin.type == "TEXT" {
						let label = UILabel()
						label.numberOfLines = 0
						label.font = UIFont.preferredFont(forTextStyle: .body)
						label.text = plugin.text ?? ""
						label.height(constant: 40)
						stackView.addArrangedSubview(label)
					} else if plugin.type == "TITLE" {
						let label = UILabel()
						label.numberOfLines = 0
						label.font = UIFont.preferredFont(forTextStyle: .title2)
						label.text = plugin.text ?? ""
						label.height(constant: 40)
						stackView.addArrangedSubview(label)
					} else if plugin.type == "COUNTDOWN" {
						let countdown = CountdownLabel(frame: CGRect(), fromDate: NSDate(), targetDate: NSDate(timeIntervalSinceNow: 10))
                        print(countdown.description)
					} else if plugin.type == "BUTTON" {
                        let button = PressableButton()
						button.colors = .init(
								button: UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1),
								shadow: UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1)
						)
						button.setTitle(plugin.text, for: .normal)
						button.addTarget(self, action: #selector(doSomething), for: .touchUpInside)
						button.tag = i
						button.height(constant: 40)
						stackView.addArrangedSubview(button)
					} else if plugin.type == "FILE" {
						if let url = plugin.url, plugin.url != "" {
                            let imageView = UIImageView()
							imageView.contentMode = .scaleAspectFit
							imageView.load(url: URL(string: url)!, completion: {
								image in
							})
							imageView.layer.cornerRadius = 5
							imageView.height(constant: 60)
							stackView.addArrangedSubview(imageView)
						}
					}
				}
			}
			stackView.frame = CGRect.init(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
			stackView.frame.origin.x = self.scrollView.frame.size.width * CGFloat(i)
			stackView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
			self.scrollView.addSubview(stackView)
			i += 1
		}
	}
	
	func configurePageControl() {
		// The total number of pages that are available is based on how many available colors we have.
		self.pageControl.numberOfPages = elements.count
		self.pageControl.currentPage = 0
		self.pageControl.tintColor = UIColor.red
		self.pageControl.pageIndicatorTintColor = UIColor.black
		self.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
		self.addSubview(pageControl)

	}

	// MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
	@objc func changePage(sender: AnyObject) -> () {
		let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
		scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
	}
	
	@objc func doSomething(sender: UIButton) {
		guard let url = elements[sender.tag]?.postback else { return }
		if url == "" {
			let svc = SFSafariViewController(url: URL(string: "https://www.google.com")!)
			getCurrentViewController()?.present(svc, animated: true, completion: nil)
		} else {
			let svc = SFSafariViewController(url: URL(string: url )!)
			getCurrentViewController()?.present(svc, animated: true, completion: nil)
		}
	}
	
	func getCurrentViewController() -> UIViewController? {

        if let rootController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController {
			var currentController: UIViewController! = rootController
			while( currentController.presentedViewController != nil ) {
				currentController = currentController.presentedViewController
			}
			return currentController
		}
		return nil

	}

	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
		pageControl.currentPage = Int(pageNumber)
	}
}

extension CGFloat {
	static func random() -> CGFloat {
		return CGFloat(arc4random()) / CGFloat(UInt32.max)
	}
}

extension UIColor {
	static func random() -> UIColor {
		return UIColor(
		   red:   .random(),
		   green: .random(),
		   blue:  .random(),
		   alpha: 1.0
		)
	}
}

extension UIView {
	func removeAllSubviews() {
		for subview in subviews {
			subview.removeFromSuperview()
		}
	}
}
