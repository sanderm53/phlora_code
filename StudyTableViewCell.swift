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

var treeInfo: TreeInfoPackage? {
    didSet {
        if let t = treeInfo {
        	studyLabel.text = t.treeName
        	nLeafLabel.text = "\(t.nLeaves) leaves"
			referenceLabel.text = t.treeSource
			// fetch an image file with the same filename prefix as the treeName (e.g., "Cactaceae.png" )
			if let image = getImageFromFile(withFileNamePrefix:t.treeName, atTreeDirectoryNamed:t.treeName)
				{
        		studyImageView.image = image
        		}
            setNeedsLayout()
        }
    }
}

override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

	backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    selectionStyle = .none

	studyImageView = UIImageView()
	studyImageView.contentMode = .scaleAspectFit // important
	contentView.addSubview(studyImageView)
	studyImageView.translatesAutoresizingMaskIntoConstraints=false
	studyImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	studyImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
	studyImageView.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
	studyImageView.widthAnchor.constraint(equalToConstant: 150.0).isActive = true

	studyLabel = UILabel()
	studyLabel.textColor = UIColor.white
	studyLabel.font = UIFont(name:"Helvetica", size:24)
	contentView.addSubview(studyLabel)
	studyLabel.translatesAutoresizingMaskIntoConstraints=false
	studyLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	studyLabel.leftAnchor.constraint(equalTo: studyImageView.rightAnchor, constant:20.0).isActive = true

	nLeafLabel = UILabel()
	nLeafLabel.textColor = UIColor.white
	nLeafLabel.font = UIFont(name:"Helvetica", size:18)
	contentView.addSubview(nLeafLabel)
	nLeafLabel.translatesAutoresizingMaskIntoConstraints=false
	nLeafLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	nLeafLabel.rightAnchor.constraint(equalTo: rightAnchor,constant:-50.0).isActive = true

	referenceLabel = UILabel()
	referenceLabel.textColor = UIColor.white
	referenceLabel.font = UIFont(name:"Helvetica", size:14)
	contentView.addSubview(referenceLabel)
	referenceLabel.translatesAutoresizingMaskIntoConstraints=false
	referenceLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant:+30.0).isActive = true
	referenceLabel.leftAnchor.constraint(equalTo: studyImageView.rightAnchor,constant:20.0).isActive = true


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

