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
        var diagonalLineView: DiagonalLineView? 	// not always present perhaps
        var associatedNode:Node?
        //var imageNameForDisplay:String!

		var paneCenter : CGPoint!
		var relativePaneCenter = CGPoint(x:0,y:0)	// distance pane has moved from original point which was center of frame,
		//var scale:CGFloat = 1.0
		var isAttachedToNode:Bool = false
		var scale:CGFloat = 1.0
		var maxScale:CGFloat = 1.0
		var maxTransform:CGAffineTransform = CGAffineTransform.identity
		var diagonalIsHidden:Bool = false
/*
		override var center:CGPoint  // I need this to set up the right direction of the diag line depending on position of pane above or below the latitude of the taxon label (which is always at center=0 in the superviews coord system
			{
			didSet {
print ("Observing center",center.y)
					if let dlview = self.diagonalLineView
						{
						if super.center.y > 0
							{ dlview.diagonalToUpperRight = true }
						else
							{ dlview.diagonalToUpperRight = false }
						}
					
					}
			}
*/

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

        init? (usingFrame f:CGRect, atNode node:Node, onTree tree:XTree)
                {
                var imageName:String
				isAttachedToNode = true
				paneCenter = CGPoint(x:f.midX,y:f.midY)
				associatedNode = node
               super.init(frame:f)
                guard let image = getImageFromFile(withFileNamePrefix:node.originalLabel!, atTreeDirectoryNamed:tree.treeInfo.treeName)
               	else
                        {return nil}
				layoutPaneForImage(image)
				if let name = node.label
 					{imageName = name}
				else
					{imageName="Unlabeled node"}
				addLabel(withName:imageName)
				addDiagonal()
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

		func addDiagonal()
			{
			diagonalLineView = DiagonalLineView(point1: CGPoint(x:frame.width,y:0), point2: CGPoint(x:400,y:bounds.midY))
			// remember this frame is in coords of paneView because it is a subview of it!
//print (frame, frame.origin, associatedNode!.coord)
			self.addSubview(diagonalLineView!)
			}

		func layoutPaneForImage(_ image:UIImage)
			{

				var rectMult:CGFloat
				let L=treeSettings.initialImageSize
				let aspect = image.size.height/image.size.width
				if aspect >= 1.0
					{ rectMult=L/image.size.height }
				else
					{ rectMult=L/image.size.width }
				let initialImageSize = CGSize(width:rectMult*image.size.width ,height:rectMult*image.size.height)

				maxScale = 1/rectMult
				maxTransform = CGAffineTransform.identity.scaledBy(x: maxScale, y: maxScale)

				frame = centeredRect(center:paneCenter,size:initialImageSize)

				// to experiment with using scaled down sizes. didn't matter much
				//let thumb = resizeUIImage(image:image, toSize:initialImageSize)
				//imageView = UIImageView(image: thumb)


				imageView = UIImageView(image: image)
				imageView.contentMode = .scaleAspectFit
				imageView.isUserInteractionEnabled=true
				imageView.center = CGPoint(x:initialImageSize.width/2,y:initialImageSize.height/2)
				imageView.bounds.size = initialImageSize

				self.addSubview(imageView)

//print ("Initial pane frame, center = ", frame, center)
//transform = CGAffineTransform.identity.translatedBy(x: 100, y: 100)
//print ("Transformed pane frame, center = ", frame, center)


				self.isUserInteractionEnabled=true
				layer.borderColor=UIColor.white.cgColor
				layer.borderWidth=2.0
				//imageView.layer.borderColor=UIColor.red.cgColor
				//imageView.layer.borderWidth=2.0
			}



//==> NEED TO UPDATE THIS SO THAT FRAME STAYS CENTERED AT SAME PLACE ALWAYS, REGARDLESS OF IMAGEVIEW; NEEDED SO THAT
//POSITION OF PANE STAYS THE SAME WRT TREEVIEW. ELSE PANE SHIFTS AS WE ZOOM IN ON IMAGE. JUST MAKE THE FRAME
//A SQUARE PERHAPS...tricky, let's defer solution. can be corrected in realtime by small panning of image

		func scale(by scale:CGFloat, around pt:CGPoint, inTreeView treeView:DrawTreeView)
				{
				// This lets us pinch to a point in the imageView; thanks to stackoverflow (B. Paulino)
				

// begin new code...
//  NOTE DOES NOT YET UPDATE THE DIAGONAL LINE SMOOTHELY; SAME GUNK AS LABEL NO DOUBT
let oldCenter = center
let rect = imageView.frame
let theTransform = CGAffineTransform.identity.translatedBy(x: pt.x, y: pt.y).scaledBy(x: scale, y: scale).translatedBy(x: -pt.x, y: -pt.y) // note that this order is reversed from how you'd apply them to curren transform (I think)
let newRect = rect.applying(theTransform)
let deltaOrigin = newRect.origin
let newSize = newRect.size
let newFrameOrigin = CGPoint(x: frame.origin.x+deltaOrigin.x, y: frame.origin.y+deltaOrigin.y)
let newPaneViewFrame = CGRect(origin: newFrameOrigin, size: newSize)
let newImageViewFrame = CGRect(origin: CGPoint(x:0,y:0), size: newSize)
let newLabelCenter = CGPoint(x:newPaneViewFrame.width/2,y:imageLabel.frame.height/2 + newPaneViewFrame.height)
//diagonalLineView?.isHidden = true


	let newDiagonalFrame = upDateDiagonalFrame(usingFrame: newPaneViewFrame, iconX:804)



					UIView.animate(withDuration:0.2, animations:
							{
							//self.imageView.transform = transform
							self.imageView.frame = newImageViewFrame
							self.frame = newPaneViewFrame
							self.imageLabel.center = newLabelCenter
				//self.diagonalLineView!.frame = newDiagonalFrame
							}
/*							,
							completion:
								{
								finished in
								//self.diagonalLineView?.isHidden = false
								}
*/
							)
				self.scale *= scale
/* OLD CODE
				let pinchCenter = CGPoint(x:pt.x-imageView.bounds.midX,y:pt.y-imageView.bounds.midY)
				let transform = imageView.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y).scaledBy(x: scale, y: scale).translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
				imageView.transform = transform

				self.scale *= scale

				// This wraps the superview (imagePane) around the imageview. Kind of a pain. Must be a cleverer way, but
				// pinchCenter above seems to get scaled by transforms, so can't use that directly
				// Also Apple docs claim that frame is undefined when we use transforms...but here it is bounds that stays constant


				let newImageOrigin = imageView.frame.origin
				let oldCenter = center
				frame = frame.offsetBy(dx: newImageOrigin.x, dy: newImageOrigin.y)
				frame.size = CGSize(width:imageView.frame.width,height:imageView.frame.height)
				imageView.frame = imageView.frame.offsetBy(dx: -newImageOrigin.x, dy: -newImageOrigin.y)
*/

				relativePaneCenter.x += (center.x-oldCenter.x)
				relativePaneCenter.y += (center.y-oldCenter.y) // update the position of this relative pane center based on new frame calcs

				//treeView.setNeedsDisplay() // needed so we update the connector line to the node
				}

		func translate(dx x:CGFloat, dy y:CGFloat, inTreeView treeView:DrawTreeView) // Don't use transforms, because they mess with the pane frame, which I need in scale
				{
				//frame = frame.offsetBy(dx: x, dy: y)
					let newCenter = CGPoint(x: center.x+x, y: center.y+y)
let newRect = centeredRect(center: newCenter, size: bounds.size)
if rectInPaneCoordsDoesIntersectWithWindow(paneRect:newRect, ofTreeView:treeView)
					{

					center = newCenter
					relativePaneCenter.x += x
					relativePaneCenter.y += y // update the position of this relative pane center based on new frame calcs
	//...really affects pans and scaling: noticably flickers
					//treeView.setNeedsDisplay() // needed so we update the connector line to the node
					}
				}
	

		func setLocationRelativeToTreeTo(_ x:CGFloat, _ y:CGFloat)
				{
				self.transform = CGAffineTransform.identity.translatedBy(x: x, y: y)
				//self.transform = CGAffineTransform.identity.translatedBy(x: x, y: y).translatedBy(x: relativePaneCenter.x, y: relativePaneCenter.y)
				}

		func setLocationRelativeToTreeTo()
				{
				if let node = associatedNode
					{
					let centerY = WindowCoord(fromTreeCoord: node.coord.y + relativePaneCenter.y, inTreeView: superview as! DrawTreeView)
					let centerX = self.center.x
					center = CGPoint(x:centerX,y:centerY)


					//self.transform = CGAffineTransform.identity.translatedBy(x: centerX, y: centerY)
					//self.transform = CGAffineTransform.identity.translatedBy(x: x, y: y)
					//self.transform = CGAffineTransform.identity.translatedBy(x: x, y: y).translatedBy(x: relativePaneCenter.x, y: relativePaneCenter.y)
					}
				}

//  not using this yet...
		func shouldDisplayDiagonal()->Bool
			{
			if let sv = superview
				{
				if self.frame.width < sv.frame.width * 0.6
					{ return true }
				else
					{ return false }
				}
			else
				{ return false }
			}

		func upDateDiagonalFrame(iconX icx:CGFloat)
			{
			// want pt1 and pt2 in paneView's coordinates...
			let pt1 = CGPoint(x:frame.width,y:0)
			
			let xDist = icx - frame.maxX // distance to right side of frame
			let pt2 = CGPoint(x:pt1.x+xDist, y:-relativePaneCenter.y+frame.height/2)
			
			
			if let dlview = diagonalLineView
				{
				if pt1.x > pt2.x // pane moving past imageIcon to right, stop displaying
					{
					dlview.isHidden = true
					return
					}
				else
					{ dlview.isHidden = false }
				if (pt1.y>pt2.y)
					{dlview.diagonalToUpperRight = true}
				else
					{dlview.diagonalToUpperRight = false}

				dlview.frame = rectFromTwoPoints(pt1,pt2)
				
				//dlview.setNeedsDisplay() // yes to avoid drawing the actual line via some wonky xformation
				}
			}

		func upDateDiagonalFrame(usingFrame f:CGRect,  iconX icx:CGFloat)->CGRect
			{
			// want pt1 and pt2 in paneView's coordinates...
			let pt1 = CGPoint(x:f.width,y:0)
			
			let xDist = icx - f.maxX // distance to right side of frame
			let pt2 = CGPoint(x:pt1.x+xDist, y:-center.y+f.height/2)
			
			if pt1.x > pt2.x // pane moving past imageIcon to right, stop displaying
				{ return CGRect() }
			

			let newFrame = rectFromTwoPoints(pt1,pt2)
				
			return newFrame
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

//*******************************************************************************************************
//*******************************************************************************************************

class DiagonalLineView: UIView
        {
		var diagonalToUpperRight:Bool!

        init?(point1 pt1:CGPoint, point2 pt2:CGPoint)
        		{
                super.init(frame:CGRect()) // zero frame
                self.isOpaque = false // this may slow rendering
                self.contentMode = .redraw // need this, otherwise when frame is changed, it does NOT call draw(), and bitmap of diagonal gets distorted by default content scale mode
				frame = rectFromTwoPoints(pt1,pt2)
/*
				if (pt1.y>pt2.y)
					{diagonalToUpperRight = true}
				else
					{diagonalToUpperRight = false}
*/
				//layer.borderColor=UIColor.red.cgColor
				//layer.borderWidth=2.0
                }

        override init(frame: CGRect)
        		{
                super.init(frame:frame)
                }
        required init?(coder aDecoder: NSCoder)
        		{
                super.init(coder:aDecoder)
        		}

		override func draw(_ rect: CGRect)
			{
			var start,end:CGPoint
return
			if bounds.width == 0 || bounds.height == 0
				{ return }

			if let sv = superview as? ImagePaneView
				{
				if sv.center.y - sv.bounds.midY > 0
					{ diagonalToUpperRight = true }
				else
					{ diagonalToUpperRight = false }

				}

			if diagonalToUpperRight
				{
				start = CGPoint(x: bounds.minX, y: bounds.maxY)
				end = CGPoint(x: bounds.maxX, y: bounds.minY)
				}
			else
				{
				start = CGPoint(x: bounds.minX, y: bounds.minY)
				end = CGPoint(x: bounds.maxX, y: bounds.maxY)
				}

			let ctx = UIGraphicsGetCurrentContext()!
			ctx.setLineWidth(treeSettings.edgeWidth)

			ctx.move(to:start)
			ctx.addLine(to:end)
			ctx.setStrokeColor(treeSettings.imageToIconLineColor) // restore stroke color
			ctx.setLineDash(phase: 0, lengths: [1,3])
			ctx.strokePath()
			ctx.setLineDash(phase: 0, lengths: [])

			}


		}
