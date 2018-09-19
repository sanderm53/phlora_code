//
//  StudyTableViewCell.swift
//  QGTut
//
//  Created by mcmanderson on 6/22/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import Foundation
import UIKit


class StudyTableViewCell: UITableViewCell {

var studyLabel: UILabel!
var nLeafLabel: UILabel!
var referenceLabel: UILabel!
var studyImageView: UIImageView!
var studyImagePane: ImagePaneView!

var treeInfo: TreeInfoPackage? {
    didSet {
        if let t = treeInfo {
        	studyLabel.text = t.treeName
        	nLeafLabel.text = "\(t.nLeaves) leaves"
			referenceLabel.text = t.treeSource
			// fetch an image file with the same filename prefix as the treeName (e.g., "Cactaceae.png" )

			if let image = getStudyImage(treeInfo:t)
				{
				studyImagePane.addImage(image)
				}
			else
				{
				if studyImagePane.hasImage
					{ studyImagePane.deleteImage()} // in case we are reusing a cell with an image pane already populated
				}

            setNeedsLayout()
        }
    }
}

override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

	backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    selectionStyle = .none


	studyImagePane = ImagePaneView()
	studyImagePane.contentMode = .scaleAspectFit // important
	contentView.addSubview(studyImagePane)
	studyImagePane.translatesAutoresizingMaskIntoConstraints=false
	studyImagePane.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	studyImagePane.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
	studyImagePane.heightAnchor.constraint(equalToConstant: treeSettings.studyTableImageHeight).isActive = true
	studyImagePane.widthAnchor.constraint(equalToConstant: treeSettings.studyTableImageHeight).isActive = true


	studyLabel = UILabel()
	studyLabel.textColor = UIColor.white
	studyLabel.font = UIFont(name:"Helvetica", size:treeSettings.studyTableLabelFontSize)
	contentView.addSubview(studyLabel)

	nLeafLabel = UILabel()
	nLeafLabel.textColor = UIColor.white
	nLeafLabel.font = UIFont(name:"Helvetica", size:treeSettings.studyTableNLeafFontSize)
	contentView.addSubview(nLeafLabel)

	referenceLabel = UILabel()
	referenceLabel.textColor = UIColor.white
	referenceLabel.font = UIFont(name:"Helvetica", size:treeSettings.studyTableReferenceFontSize)
	contentView.addSubview(referenceLabel)

	if UIDevice.current.userInterfaceIdiom == .pad
		{ // Spread out and take advantage of horiz space

		studyLabel.translatesAutoresizingMaskIntoConstraints=false
		studyLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		studyLabel.leftAnchor.constraint(equalTo: studyImagePane.rightAnchor, constant:20.0).isActive = true
		nLeafLabel.translatesAutoresizingMaskIntoConstraints=false
		nLeafLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		nLeafLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor,constant:-50.0).isActive = true
		referenceLabel.translatesAutoresizingMaskIntoConstraints=false
		referenceLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant:+30.0).isActive = true
		referenceLabel.leftAnchor.constraint(equalTo: studyImagePane.rightAnchor,constant:20.0).isActive = true

		}
	else
		{ // put all text in vert column
		studyLabel.translatesAutoresizingMaskIntoConstraints=false
		studyLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		studyLabel.leftAnchor.constraint(equalTo: studyImagePane.rightAnchor, constant:10.0).isActive = true
		nLeafLabel.translatesAutoresizingMaskIntoConstraints=false
		nLeafLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant:-20.0).isActive = true
		nLeafLabel.leftAnchor.constraint(equalTo: studyImagePane.rightAnchor, constant:10.0).isActive = true
		referenceLabel.translatesAutoresizingMaskIntoConstraints=false
		referenceLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant:+20.0).isActive = true
		referenceLabel.leftAnchor.constraint(equalTo: studyImagePane.rightAnchor, constant:10.0).isActive = true

		}


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

