//
//  AnnotatedProgressView.swift
//  QGTut
//
//  Created by mcmanderson on 12/14/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import Foundation
import UIKit

// A modified progress view that has a few personalized labels and is adapted to work nicely for counting files transferred (integers out of total integer)

class AnnotatedProgressView:UIView

	{
		var progressView = UIProgressView(progressViewStyle: .default)
		var titleLabel = UILabel()
		var progressLabel = UILabel()
		var cancelButton = UIButton(type: .roundedRect)
	
		init()
			{
			super.init(frame:CGRect()) // 0-frame because it will be set up with constraints

			isHidden = true
			backgroundColor = UIColor.black
			layer.borderColor = UIColor.gray.cgColor
			layer.borderWidth = 1.0
			layer.cornerRadius = 5.0

			progressView.isHidden = true
			progressView.trackTintColor = UIColor.gray
			progressView.progressTintColor = UIColor.blue

			titleLabel.textColor = UIColor.white
			titleLabel.textAlignment = .center
			progressLabel.textColor = UIColor.white
			progressLabel.textAlignment = .center

			cancelButton.addTarget(nil, action: #selector(DatabaseTableViewController.handleCancelDownloadButton), for: .touchUpInside)
// Note: the selector had to be specified at to which class the handle func is defined in, seems to defeat purpose of generic responder chain
			cancelButton.frame.size = CGSize(width: 100, height: 20)
			cancelButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
			cancelButton.frame = CGRect(origin: CGPoint(x:0,y:0), size: cancelButton.frame.size)
			cancelButton.setTitleColor(UIColor.black, for: .normal)
			let myAttributes = [
				NSForegroundColorAttributeName : UIColor.red,
				NSFontAttributeName : UIFont(name:"Helvetica", size:20)!
				]
			let mySelectedAttributedTitle = NSAttributedString(string: "Cancel", attributes: myAttributes)
			cancelButton.setAttributedTitle(mySelectedAttributedTitle, for: .normal)

			self.addSubview(progressView)
			self.addSubview(titleLabel)
			self.addSubview(progressLabel)
			self.addSubview(cancelButton)

			addConstraints()
			}

		func addConstraints() // should put this all in a stackview
			{
			progressView.translatesAutoresizingMaskIntoConstraints = false
			titleLabel.translatesAutoresizingMaskIntoConstraints = false
			progressLabel.translatesAutoresizingMaskIntoConstraints = false
			cancelButton.translatesAutoresizingMaskIntoConstraints = false

			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
			titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
			titleLabel.bottomAnchor.constraint(equalTo: progressLabel.topAnchor).isActive = true

			progressLabel.leadingAnchor.constraint(equalTo: progressView.trailingAnchor,constant:15).isActive = true
			progressLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
			progressLabel.bottomAnchor.constraint(equalTo: cancelButton.topAnchor).isActive = true
			progressLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

			progressView.leadingAnchor.constraint(equalTo: leadingAnchor,constant:15).isActive = true
			progressView.widthAnchor.constraint(equalToConstant: 150).isActive = true
			progressView.heightAnchor.constraint(equalToConstant: 5).isActive = true
			progressView.centerYAnchor.constraint(equalTo: progressLabel.centerYAnchor).isActive = true
			
			cancelButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
			cancelButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
			cancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
			cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
			}

		func start(title t:String, nFilesToDownload:Int)
			{
			titleLabel.text = "  Downloading from study: \(t)..."
			isHidden = false
			progressView.setProgress(0, animated: false) // have to set this to zero instantly and then...
			updateProgress(int1: 0, int2: nFilesToDownload)
			progressView.isHidden = false // surprised I have to do this; should get unhidden when superview does?
			}

		func updateProgress(int1 i1:Int, int2 i2:Int)
			{
			guard i2 > 0 else { return }
			progressView.setProgress(Float(i1)/Float(i2), animated: true)
			progressLabel.text = "File \(i1) of \(i2)"
			}


        override init(frame: CGRect)
                {
                super.init(frame:frame)
                }
        required init?(coder aDecoder: NSCoder)
        		{
                super.init(coder:aDecoder)
				}
	}
