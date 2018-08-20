//
//  ImagePaneView.swift
//  QGTut
//
//  Created by mcmanderson on 6/27/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import Foundation
import UIKit


func centeredRect(center c:CGPoint, size s:CGSize)->CGRect
	{
	let origin = CGPoint(x:c.x-s.width/2, y:c.y-s.height/2)
	return CGRect(origin:origin,size:s)
	}

func rectFromTwoPoints(_ pt1:CGPoint, _ pt2:CGPoint)->CGRect
	{
	let origin = CGPoint(x: min(pt1.x,pt2.x), y:min(pt1.y,pt2.y))
	let size = CGSize(width: abs(pt1.x-pt2.x), height: abs(pt1.y-pt2.y))
//print ("**",pt1,pt2,CGRect(origin: origin, size: size))
	return CGRect(origin: origin, size: size)


	}

/*
NB. I needed to keep the frame size of the imagePane to be a superset of the imageView because the gesture recognizer
chain works by intersecting the frames of the hierarchy of views down to the imageView. If the frame of imagePane is merely intersecting
with the imageView it won't work properly, so keep the imagePane frame such that it strictly contains imageView. Thus the code in 'scale()'
*/

/*
Pane EVENTUALLY will appear initially with its center at the same Y as its node. However, this positioning
occurs during layoutSubviews of treeView. Panning the image pane changes its coordinates relative to the center of
its initial frame, which is set to (midX,y=0).
The pt relativePaneCenter keeps track of changes from this initial point, and therefore is always a useful measure
of translations relative to the node.
*/

class ImagePaneView: UIView, UIGestureRecognizerDelegate
        {
		var imageView: UIImageView!
        var imageLabel=UILabel()
        var addImageLabel:UILabel?
        var associatedNode:Node?
        //var imageNameForDisplay:String!

		var paneCenter : CGPoint!
		//var relativePaneCenter = CGPoint(x:0,y:0)	// distance pane has moved from original point which was center of frame,
		//var scale:CGFloat = 1.0
		var isAttachedToNode:Bool = false
		var scale:CGFloat = 1.0
		//var maxScale:CGFloat = 1.0
		//var maxTransform:CGAffineTransform = CGAffineTransform.identity
		//var diagonalIsHidden:Bool = false
		var hasImage:Bool = false

// Default position of this view is centered on the frame provided to it
        init? (usingFrame f:CGRect,withFileNamePrefix name:String, atTreeDirectoryNamed tree:String)
                {
				isAttachedToNode = false
				paneCenter = CGPoint(x:f.midX,y:f.midY)
				super.init(frame:f)
				isUserInteractionEnabled=true

                guard let image = getImageFromFile(withFileNamePrefix:name, atTreeDirectoryNamed:tree)
               	else
                        {return nil}
				layoutPaneForImage(image)
				addLabel(withName:name)
            }

        init (usingFrame f:CGRect, atNode node:Node, onTree tree:XTree)
                {
                var imageName:String
				isAttachedToNode = true
				paneCenter = CGPoint(x:f.midX,y:f.midY)
				associatedNode = node
               super.init(frame:f)
                let image = getImageFromFile(withFileNamePrefix:node.originalLabel!, atTreeDirectoryNamed:tree.treeInfo.treeName)
				layoutPaneForImage(image)
				if let name = node.label
 					{imageName = name}
				else
					{imageName="Unlabeled node"}
				addLabel(withName:imageName)
				}

		func addLabel(withName name:String)
			{
			imageLabel = UILabel()
			self.addSubview(imageLabel)
			imageLabel.textColor = UIColor.white
			imageLabel.font = UIFont(name:"Helvetica", size:18)
			imageLabel.text = name
			imageLabel.backgroundColor=treeSettings.viewBackgroundColor
			imageLabel.translatesAutoresizingMaskIntoConstraints=false
			imageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
			//imageLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
			imageLabel.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
			//imageLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
			}


		func layoutPaneForImage(_ image:UIImage?)
			{

				var rectMult:CGFloat
				let L=treeSettings.initialImageSize
				var initialImageSize:CGSize

				if let image = image
					{
					let aspect = image.size.height/image.size.width
					if aspect >= 1.0
						{ rectMult=L/image.size.height }
					else
						{ rectMult=L/image.size.width }
					initialImageSize = CGSize(width:rectMult*image.size.width ,height:rectMult*image.size.height)
					hasImage = true // well, it should anyway, after loading it below
					}
				else
					{
					initialImageSize = CGSize(width:L ,height:L)
					hasImage = false // default empty image
					addAddImageLabel()
					}


				frame = centeredRect(center:paneCenter,size:initialImageSize)

				// to experiment with using scaled down sizes. didn't matter much
				//let thumb = resizeUIImage(image:image, toSize:initialImageSize)
				//imageView = UIImageView(image: thumb)


				imageView = UIImageView(image: image)
				imageView.contentMode = .scaleAspectFit
				imageView.isUserInteractionEnabled=true

				self.addSubview(imageView)

				imageView.translatesAutoresizingMaskIntoConstraints = false
				imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
				imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
				imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
				imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

				self.isUserInteractionEnabled=true
				layer.borderColor=UIColor.white.cgColor
				layer.borderWidth=2.0
				//imageView.layer.borderColor=UIColor.red.cgColor
				//imageView.layer.borderWidth=2.0
				
				
			}

func addImageButtonAction(sender: UIButton!) {
	
}

func addAddImageLabel()
	{
	addImageLabel = UILabel()

	//referenceLabel.font = UIFont(name:"Helvetica", size:14)

	addImageLabel!.textColor = UIColor(cgColor: appleBlue)
	addImageLabel!.text = "Add an image"
	addImageLabel!.textAlignment = .center
	addImageLabel!.backgroundColor = UIColor.white
	addSubview(addImageLabel!)

	addImageLabel!.translatesAutoresizingMaskIntoConstraints=false
	addImageLabel!.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
	addImageLabel!.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
	addImageLabel!.topAnchor.constraint(equalTo: topAnchor).isActive = true
	addImageLabel!.bottomAnchor.constraint(equalTo:bottomAnchor).isActive = true

	}

//==> NEED TO UPDATE THIS SO THAT FRAME STAYS CENTERED AT SAME PLACE ALWAYS, REGARDLESS OF IMAGEVIEW; NEEDED SO THAT
//POSITION OF PANE STAYS THE SAME WRT TREEVIEW. ELSE PANE SHIFTS AS WE ZOOM IN ON IMAGE. JUST MAKE THE FRAME
//A SQUARE PERHAPS...tricky, let's defer solution. can be corrected in realtime by small panning of image

		func scale(by scale:CGFloat, around pt:CGPoint, inTreeView treeView:DrawTreeView)
				{

				let theTransform = CGAffineTransform.identity.translatedBy(x: pt.x, y: pt.y).scaledBy(x: scale, y: scale).translatedBy(x: -pt.x, y: -pt.y) // note that this order is reversed from how you'd apply them to current transform (I think)
				let newBounds = bounds.applying(theTransform)
				let deltaOrigin = newBounds.origin // since original bounds was just 0,0

				let newSize = newBounds.size
				let newFrameOrigin = CGPoint(x: frame.origin.x+deltaOrigin.x, y: frame.origin.y+deltaOrigin.y)
				let newFrame = CGRect(origin: newFrameOrigin, size: newSize)

				let newLabelCenter = CGPoint(x:newSize.width/2,y:imageLabel.frame.height/2 + newSize.height)

				frame = newFrame
				imageLabel.center = newLabelCenter

				self.scale *= scale
				}

		func translate(dx x:CGFloat, dy y:CGFloat, inTreeView treeView:DrawTreeView)
				{
				let newCenter = CGPoint(x: center.x+x, y: center.y+y)
				center = newCenter
							/* ...useful when/if animating potentially offscreen
							let newRect = centeredRect(center: newCenter, size: bounds.size)
							if rectInPaneCoordsDoesIntersectWithWindow(paneRect:newRect, ofTreeView:treeView)
												{
												center = newCenter
												}
							*/
				}
	

		func setLocationRelativeToTreeTo(_ x:CGFloat, _ y:CGFloat)
				{
				self.transform = CGAffineTransform.identity.translatedBy(x: x, y: y)
				}

		func setLocationRelativeTo(treeView t:DrawTreeView)
				{
				if let node = associatedNode
					{
					let centerY = WindowCoord(fromTreeCoord: node.coord.y, inTreeView: t)
					//let centerX = center.x
					self.transform = CGAffineTransform.identity.translatedBy(x:0,y:centerY)
					}

				}


        // Used if view is called programmatically

        override init(frame: CGRect)
                {
                super.init(frame:frame)
                }
	

        // Used with IB
        required init?(coder aDecoder: NSCoder) {
                super.init(coder:aDecoder)
        }
	
		func convert(panePt pt:CGPoint, toTreeView treeView:DrawTreeView) -> CGPoint
			{
			let nodeY = self.associatedNode!.coord.y
			let treeCoordY = nodeY + pt.y
			let Y = WindowCoord(fromTreeCoord: treeCoordY, inTreeView:treeView)
			let X = pt.x
			return CGPoint(x: X, y: Y)
			}
		func isPanePointWithinWindow(panePt pt:CGPoint, ofTreeView treeView:DrawTreeView) -> Bool
			{
			let p = convert(panePt:pt, toTreeView:treeView)
			let r = treeView.decoratedTreeRect!
			if p.x > r.minX && p.x < r.maxX && p.y > r.minY && p.y < r.maxY
				{ return true }
			else
				{ return false }
			}

		func rectInPaneCoordsDoesIntersectWithWindow(paneRect rect:CGRect, ofTreeView treeView:DrawTreeView) -> Bool
			{
			let pt = rect.origin
			let p = convert(panePt:pt, toTreeView:treeView)
			let convertedRect = CGRect(origin:p, size:rect.size)
			let r = treeView.decoratedTreeRect!
			if r.intersects(convertedRect)
				{ return true }
			else
				{ return false }
			}


	}


