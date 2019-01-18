//
//  htmlTextViewController.swift
//  QGTut
//
//  Created by mcmanderson on 6/20/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import Foundation
import UIKit

	func HTMLFileToAttributedString(fromHTMLFilePrefix:String)->NSAttributedString
		{
		if let htmlURL = Bundle.main.url(forResource: fromHTMLFilePrefix, withExtension: "html"),
			let data = NSData(contentsOf: htmlURL)
			{
			   do
				{
				let attrStr = try NSAttributedString(data: data as Data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil)
//print (attrStr)
				return (attrStr)
				}
			   catch
				{
				print("Error creating attributed string in HTMLFileToAttributedString")
				}
			}
		else
			{
			print ("Error finding file, etc., in HTMLFileToAttributedString")
			}
		return (NSAttributedString(string: "Error return from HTMLFileToAttributedString"))
		}


class htmlFileTextViewController: UIViewController {

	var htmlFilePrefix:String?
	var textView:UITextView!

	override func viewDidAppear(_ animated: Bool)
		{
		super.viewDidAppear(animated)
		}

	override func viewWillAppear(_ animated: Bool)
		{
		super.viewWillAppear(animated)
        //navigationController!.setToolbarHidden(true, animated: false)
		navigationController!.setNavigationBarHidden(false, animated: false)
		}
	override func viewDidLoad()
		{
		super.viewDidLoad()

		self.title = htmlFilePrefix // This will be displayed in middle button of navigation bar at top
		navigationController!.setNavigationBarHidden(false, animated: false)
        navigationController!.setToolbarHidden(true,
             animated: false)
        view.backgroundColor=UIColor.black
		textView = UITextView()
		self.view.addSubview(textView)
		textView.attributedText = HTMLFileToAttributedString(fromHTMLFilePrefix:htmlFilePrefix!)
		textView.isEditable=false // careful, sometimes seems to throw constraint errors
		textView.backgroundColor=UIColor.black
		//let margins = view.layoutMarginsGuide
		textView.translatesAutoresizingMaskIntoConstraints=false
		let margins = view.readableContentGuide
		textView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		textView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		textView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true

		if title == "About" // Add some logos just for this page; hack
			{
			let imageView1 = UIImageView(image: UIImage(named:"UA.jpg"))
			let imageView2 = UIImageView(image: UIImage(named:"Yale.png"))
			let imageView3 = UIImageView(image: UIImage(named:"NSF.png"))
			imageView1.contentMode = .scaleAspectFit
			imageView2.contentMode = .scaleAspectFit
			imageView3.contentMode = .scaleAspectFit
			let stackView = UIStackView(arrangedSubviews:[imageView1,imageView2,imageView3])
			stackView.axis = .horizontal
			stackView.distribution = .fillEqually
			stackView.alignment = .fill
			stackView.spacing = 50
			stackView.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(stackView)
			
			stackView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor,constant:-25).isActive = true
			stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
			stackView.widthAnchor.constraint(equalToConstant: 250.0).isActive = true
			stackView.heightAnchor.constraint(equalToConstant: 75.0).isActive = true
			textView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant:-25.0).isActive = true
			}
		else
			{
			textView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
			}

 		}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		}


   override func viewDidLayoutSubviews()
   		{
		super.viewDidLayoutSubviews()
    	self.textView.setContentOffset(CGPoint.zero, animated: false) // ensures that the top of the text appears visible at top of screen  (else it sometimes gets scrolled up and hidden
    	}


// ********************************** I have disabled device rotations in info.plist!, so the following is mute and not current

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
	
//		super.viewWillTransition(to: size, with: coordinator)

		}

	}
