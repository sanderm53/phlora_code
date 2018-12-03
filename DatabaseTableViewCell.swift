//
//  StudyTableViewCell.swift
//  QGTut
//
//  Created by mcmanderson on 6/22/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import Foundation
import UIKit


class DatabaseTableViewCell: UITableViewCell {

//var studyLabel: UILabel!
var leafLabel: UILabel!

var studyLabel:UILabel!
var sourceLabel:UILabel!
var nLeafLabel:UILabel!
var nImagesLabel:UILabel!
var imageSpaceLabel:UILabel!
var downloadButton:UIButton!

var treeInfo: TreeInfoPackage? {
    didSet {
        if let t = treeInfo {
			
        	studyLabel.text = t.displayTreeName
			sourceLabel.text = t.treeSource
        	nLeafLabel.text = "\(t.nLeaves) leaves"
        	nImagesLabel.text = "\(t.nImages!) images"
       		imageSpaceLabel.text = "\(t.imageSpace!) GB"

			// fetch an image file with the same filename prefix as the treeName (e.g., "Cactaceae.png" )

            setNeedsLayout()
        }
    }
}


override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

	//backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
	backgroundColor = nil
    selectionStyle = .none

		let margins = contentView.layoutMarginsGuide

		studyLabel = label(text:"",font:UIFont(name:"Helvetica", size:treeSettings.studyTableNLeafFontSize)!,textColor:UIColor.white)
		sourceLabel = label(text:"",font:UIFont(name:"Helvetica", size:treeSettings.studyTableNLeafFontSize)!,textColor:UIColor.white)
		nLeafLabel = label(text:"",font:UIFont(name:"Helvetica", size:treeSettings.studyTableNLeafFontSize)!,textColor:UIColor.white)
		nImagesLabel = label(text:"",font:UIFont(name:"Helvetica", size:treeSettings.studyTableNLeafFontSize)!,textColor:UIColor.white)
		imageSpaceLabel = label(text:"",font:UIFont(name:"Helvetica", size:treeSettings.studyTableNLeafFontSize)!,textColor:UIColor.white)
		downloadButton = UIButton(type: .custom) // defaults to frame of zero size! Have to do custom to short circuit the tint color assumption for example
		downloadButton.addTarget(self, action: #selector(handleDownloadButton), for: .touchUpInside)
		downloadButton.setTitleColor(UIColor.red, for: .normal)
		let myAttributes = [
			NSForegroundColorAttributeName : UIColor.red,
			NSFontAttributeName : UIFont(name:"Helvetica", size:18)!
			]
		let mySelectedAttributedTitle = NSAttributedString(string: "Download", attributes: myAttributes)
   		downloadButton.setAttributedTitle(mySelectedAttributedTitle, for: .normal)

		let leftStack = UIStackView(arrangedSubviews:[studyLabel,sourceLabel,nLeafLabel])
		leftStack.axis = .vertical
		leftStack.distribution = .fillEqually
		leftStack.alignment = .fill
		leftStack.spacing = 2

		let centerStack = UIStackView(arrangedSubviews:[nImagesLabel,imageSpaceLabel])
		centerStack.axis = .vertical
		centerStack.distribution = .fillEqually
		centerStack.alignment = .fill
		centerStack.spacing = 2

		let rightStack = UIStackView(arrangedSubviews:[downloadButton])
		rightStack.axis = .vertical
		rightStack.distribution = .fillEqually
		rightStack.alignment = .fill
		rightStack.spacing = 2


		let rowStackView = UIStackView(arrangedSubviews:[leftStack,centerStack,rightStack])
		rowStackView.axis = .horizontal
		rowStackView.distribution = .fillEqually
		rowStackView.alignment = .fill
		rowStackView.spacing = 50
		rowStackView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(rowStackView)
	
		rowStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		rowStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		rowStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		rowStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true


}

	func handleDownloadButton(sender:UIButton)
		{
		
		}
	func label (text t:String, font :UIFont, textColor color:UIColor)->UILabel
		{
		let label = UILabel()
		label.text = t
		//label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
		label.textColor = color
		label.font = font
		return label
		}

required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}

override func prepareForReuse() {
    super.prepareForReuse()

}

override func layoutSubviews() {
    super.layoutSubviews()
}


}

