//
//  StudyTableViewCell.swift
//  QGTut
//
//  Created by mcmanderson on 6/22/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import Foundation
import UIKit


class ImageTableViewCell: UITableViewCell {

//var studyLabel: UILabel!
var leafLabel: UILabel!
//var referenceLabel: UILabel!
var taxonImagePane: ImagePaneView!
var savedNode:Node?


override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

	//backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
	backgroundColor = nil
    selectionStyle = .none

	taxonImagePane = ImagePaneView(atNode:nil, withImage:nil, imageLabel:nil, showBorder:false)
	taxonImagePane.contentMode = .scaleAspectFit // important
	contentView.addSubview(taxonImagePane)
	taxonImagePane.translatesAutoresizingMaskIntoConstraints=false
	taxonImagePane.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	taxonImagePane.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
	taxonImagePane.heightAnchor.constraint(equalToConstant: treeSettings.studyTableImageHeight).isActive = true
	taxonImagePane.widthAnchor.constraint(equalToConstant: treeSettings.studyTableImageHeight).isActive = true


	leafLabel = UILabel()
	leafLabel.textColor = UIColor.white
	leafLabel.font = UIFont(name:"Helvetica", size:treeSettings.studyTableNLeafFontSize)
	contentView.addSubview(leafLabel)
	leafLabel.translatesAutoresizingMaskIntoConstraints=false
	leafLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	leafLabel.leftAnchor.constraint(equalTo: taxonImagePane.rightAnchor, constant:20.0).isActive = true

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

func getStudyImage(forStudyName studyName:String) -> UIImage? // which has a filename like study.jpg
		{
		guard let url = getFileURLMatching(study:studyName, filenameBase:studyName, extensions: ["jpg","png"], ofType:.images) else { return nil }
		return UIImage(contentsOfFile:url.path)
	}

/*
func loadThumbAsync(atNode node:Node)
	{
	savedNode = node
	DispatchQueue.global(qos: .userInitiated).async {
		if node.imageThumb != nil { return } // I don't know, let's check again in case another thread did this?
		node.imageThumb = resizeUIImageToFitSquare(UIImage(contentsOfFile:node.imageFileURL!.path)!, withHeight: treeSettings.studyTableRowHeight)

		//print ("Did load cell asynchronously? ",indexPath.row, node.originalLabel!, node.imageThumb != nil)

		if let image = node.imageThumb
			{
			DispatchQueue.main.async {
				if  self.savedNode!.originalLabel == node.originalLabel // cell has not been reused/scrolled up, bleck
					{ self.taxonImagePane.loadImage(image) }
				}
			}
		}
	}
*/


}

