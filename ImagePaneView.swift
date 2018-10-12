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
*/

class ImagePaneView: UIView, UIGestureRecognizerDelegate
        {
		var imageView: UIImageView!
        var imageLabel=UILabel()
        var addImageLabel:UILabel?
        var associatedNode:Node?

		var paneCenter : CGPoint!
		var isAttachedToNode:Bool = false
		var scale:CGFloat = 1.0
		var hasImage:Bool = false
		var isFrozen:Bool = false // frozen means it stays in place as tree is panned
		var imageWindowCoord:CGFloat = 0.0

// Default position of this view is centered on the frame provided to it
         init ()
                {
				isAttachedToNode = false
				let f = CGRect()
				paneCenter = CGPoint(x:f.midX,y:f.midY)
				super.init(frame:f)
				isUserInteractionEnabled=true
				layoutPaneForImage(nil)
            }
/*
       init? (treeInfo:TreeInfoPackage)
                {
				isAttachedToNode = false
				let f = CGRect()
				paneCenter = CGPoint(x:f.midX,y:f.midY)
				super.init(frame:f)
				isUserInteractionEnabled=true
                let image = getStudyImage(forStudyName:treeInfo.treeName, inLocation:treeInfo.dataLocation!)
				layoutPaneForImage(image)
            }
*/
        init (usingFrame f:CGRect, atNode node:Node, onTree tree:XTree)
                {
                var imageName:String
				isAttachedToNode = true
				paneCenter = CGPoint(x:f.midX,y:f.midY)
				associatedNode = node
               	super.init(frame:f)
 				if let name = node.label
 					{imageName = name}
				else
					{imageName="Unlabeled node"}
				addLabel(withName:imageName)
               //let image = getImageFromFile(withFileNamePrefix:node.originalLabel!, atTreeDirectoryNamed:tree.treeInfo.treeName)

				if let url = node.imageFileURL
					{
					layoutPaneForImage(UIImage(contentsOfFile:url.path))
					}
				else
					{ layoutPaneForImage(nil) }
				// Only put border around images on tree view (i.e. in this initializer)
				layer.borderColor=UIColor.white.cgColor
				layer.borderWidth=2.0

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

		func addImage (_ image:UIImage) // add image to existing pane, get rid of addAdd label
			{
				var rectMult:CGFloat
				let L=treeSettings.initialImageSize
				var initialImageSize:CGSize
				let aspect = image.size.height/image.size.width
				if aspect >= 1.0
					{ rectMult=L/image.size.height }
				else
					{ rectMult=L/image.size.width }
				initialImageSize = CGSize(width:rectMult*image.size.width ,height:rectMult*image.size.height)
				hasImage = true
				//imageView.image = image
				imageView.image = resizeUIImage(image: image, toSize: initialImageSize)
				frame.size = initialImageSize
				if let addImageLabel = addImageLabel
					{
					addImageLabel.removeFromSuperview()
				}
			}
		func reloadImageToFitPaneSize () // add image to existing pane, which may have changed size during zoom; resize image to fit pane's imageView
			{
			if let url = associatedNode?.imageFileURL
				{
				if let image = UIImage(contentsOfFile:url.path)
					{ imageView.image = resizeUIImage(image: image, toSize: imageView.bounds.size) }
				}
			}
		func deleteImage() // assumes image is present, so have to reset after deleting and add a addImageLabel
			{
				hasImage = false
				imageView.image = nil
				addAddImageLabel()
				if let node = associatedNode
					{
					node.hasImageFile = false
					node.hasImage = false
					node.isDisplayingImage = false
					}
				let L = treeSettings.initialImageSize
				frame.size =  CGSize(width:L ,height:L) // reset to original square size

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
					imageView = UIImageView(image: resizeUIImage(image:image, toSize:initialImageSize))
					}
				else
					{
					initialImageSize = CGSize(width:L ,height:L)
					hasImage = false // default empty image
					addAddImageLabel()
					imageView = UIImageView(image: nil) // works even if image == nil
					}


				frame = centeredRect(center:paneCenter,size:initialImageSize)


				imageView.contentMode = .scaleAspectFit
				imageView.isUserInteractionEnabled=true

				self.addSubview(imageView)

				imageView.translatesAutoresizingMaskIntoConstraints = false
				imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
				imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
				imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
				imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

				self.isUserInteractionEnabled=true
				//imageView.layer.borderColor=UIColor.red.cgColor
				//imageView.layer.borderWidth=2.0
				
				
			}


		func addAddImageLabel()
			{
			addImageLabel = UILabel()

			//referenceLabel.font = UIFont(name:"Helvetica", size:14)

			addImageLabel!.textColor = UIColor(cgColor: appleBlue)
			addImageLabel!.text = "Add an image"
			addImageLabel!.textAlignment = .center
		let studyPUBackgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
		addImageLabel!.backgroundColor = studyPUBackgroundColor
		//addImageLabel!.layer.borderColor=UIColor.white.cgColor
		//addImageLabel!.layer.borderWidth=0.5



			addSubview(addImageLabel!)

			addImageLabel!.translatesAutoresizingMaskIntoConstraints=false
			addImageLabel!.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
			addImageLabel!.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
			addImageLabel!.topAnchor.constraint(equalTo: topAnchor).isActive = true
			addImageLabel!.bottomAnchor.constraint(equalTo:bottomAnchor).isActive = true

			}


		func scale(by scale:CGFloat, around pt:CGPoint, inTreeView treeView:DrawTreeView)
				{

	//print ("Around Pt:",pt)
	
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
				let testFrameInsets:CGFloat = 100
				var vertInset,horizInset:CGFloat

				// my way of keeping images within window during movement
				// careful, frame vs center are wonky in this code...rect comparisons need to be done with frames
				let newCenter = CGPoint(x: center.x+x, y: center.y+y)
				var testPaneFrame = frame.offsetBy(dx: x, dy: y)
				//...keep the panes from moving offscreen in the following way. For small images, don't let their center go off
				// screen. For larger images, make sure there is an overhang of dimension 'testFrameInsets' onto the visible window
				if testPaneFrame.height > 2.0 * testFrameInsets
					{ vertInset = testFrameInsets}
				else
					{ vertInset = testPaneFrame.height/2 }
				if testPaneFrame.width > 2.0 * testFrameInsets
					{ horizInset = testFrameInsets}
				else
					{ horizInset = testPaneFrame.width/2 }
				testPaneFrame = UIEdgeInsetsInsetRect(testPaneFrame, UIEdgeInsets(top: vertInset, left: horizInset, bottom: vertInset, right: horizInset))
				//....Following does the actual trapping
				if treeView.bounds.intersects(testPaneFrame)
												{
												center = newCenter
												}
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
			//let pt = rect.origin
			//let p = convert(panePt:pt, toTreeView:treeView)
			
	let convertedRect = self.convert(rect, to: treeView)
			
			//let convertedRect = CGRect(origin:p, size:rect.size)
			let r = treeView.decoratedTreeRect!
			if r.intersects(convertedRect)
				{ return true }
			else
				{ return false }
			}

	func freeze(inTreeView treeView:DrawTreeView)
		{
		if let node = associatedNode
			{
			isFrozen = true
			imageWindowCoord = WindowCoord(fromTreeCoord: node.coord.y, inTreeView: treeView)
			treeView.setNeedsDisplay()
			}
		}

	func unfreeze(inTreeView treeView:DrawTreeView)
		{
		if let node = associatedNode
			{
			isFrozen=false
			let targetTreeCoord = TreeCoord(fromWindowCoord: imageWindowCoord,inTreeView: treeView)
			let necessaryRectYCoordOffset = targetTreeCoord - node.coord.y
			frame = frame.offsetBy(dx: 0, dy: necessaryRectYCoordOffset)
			treeView.setNeedsDisplay()
			//self.setNeedsDisplay()
			}
		}

	}


