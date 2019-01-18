//
//  StudyTableViewCell.swift
//  QGTut
//
//  Created by mcmanderson on 6/22/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import Foundation
import UIKit



protocol DatabaseTableViewCellDelegate
	{
	func downloadTapped(_ cell:DatabaseTableViewCell)
	}

class DatabaseTableViewCell: UITableViewCell {

	var delegate:DatabaseTableViewCellDelegate?

	var leafLabel: UILabel!
	var studyLabel:UILabel!
	var sourceLabel:UILabel!
	var nLeafLabel:UILabel!
	var nImagesLabel:UILabel!
	var imageSpaceLabel:UILabel!
	var downloadButton:UIButton!


	var treeInfo: TreeInfoPackage?
	
func configure(using t:TreeInfoPackage)
	{
	treeInfo = t
	studyLabel.text = t.displayTreeName
	sourceLabel.text = t.treeSource
	nLeafLabel.text = "\(t.nLeaves) leaves"
	nImagesLabel.text = "\(t.nImages!) images"
	imageSpaceLabel.text = "\(t.imageSpace!) GB"
	}

override init(style: UITableViewCellStyle, reuseIdentifier: String?)
	{
    super.init(style: style, reuseIdentifier: reuseIdentifier)

	backgroundColor = nil // transparent
    selectionStyle = .none

	let margins = contentView.layoutMarginsGuide

	studyLabel = label(text:"",font:UIFont(name:"Helvetica", size:treeSettings.studyTableLabelFontSize)!,textColor:UIColor.white)
	sourceLabel = label(text:"",font:UIFont(name:"Helvetica", size:treeSettings.studyTableNLeafFontSize)!,textColor:UIColor.white)
	nLeafLabel = label(text:"",font:UIFont(name:"Helvetica", size:treeSettings.studyTableNLeafFontSize)!,textColor:UIColor.white)
	nImagesLabel = label(text:"",font:UIFont(name:"Helvetica", size:treeSettings.studyTableNLeafFontSize)!,textColor:UIColor.white)
	imageSpaceLabel = label(text:"",font:UIFont(name:"Helvetica", size:treeSettings.studyTableNLeafFontSize)!,textColor:UIColor.white)
	downloadButton = UIButton(type: .custom) // defaults to frame of zero size! Have to do custom to short circuit the tint color assumption for example
	downloadButton.frame.size = CGSize(width: 75, height: 50)
	downloadButton.addTarget(self, action: #selector(handleDownloadButton), for: .touchUpInside)
	downloadButton.setTitleColor(UIColor.red, for: .normal)

	//sourceLabel.lineBreakMode = .byWordWrapping Doesnt work, maybe vert constr
	//sourceLabel.numberOfLines = 2

	let myAttributes = [
		NSForegroundColorAttributeName : UIColor.red,
		NSFontAttributeName : UIFont(name:"Helvetica", size:treeSettings.studyTableNLeafFontSize)!
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



	leftStack.translatesAutoresizingMaskIntoConstraints = false
	contentView.addSubview(leftStack)
	centerStack.translatesAutoresizingMaskIntoConstraints = false
	contentView.addSubview(centerStack)
	rightStack.translatesAutoresizingMaskIntoConstraints = false
	contentView.addSubview(rightStack)


// Three columns look like this on iPad | ......springy...... |    200 pts    | 100 pts |

	leftStack.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
	leftStack.trailingAnchor.constraint(equalTo: centerStack.leadingAnchor).isActive = true
	leftStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

	centerStack.trailingAnchor.constraint(equalTo: rightStack.leadingAnchor).isActive = true
	centerStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
	centerStack.widthAnchor.constraint(equalToConstant: treeSettings.mediumTableColWidth).isActive = true

	rightStack.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
	rightStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
	rightStack.widthAnchor.constraint(equalToConstant: treeSettings.smallTableColWidth).isActive = true

		// Couldn't use a row stack and also keep cols aligned and at right positions...
	}
	
	func handleDownloadButton(sender:UIButton)
		{
		delegate?.downloadTapped(self)
		}


	func label (text t:String, font :UIFont, textColor color:UIColor)->UILabel
		{
		let label = UILabel()
		label.text = t
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

