//
//  MyCALayer.swift
//  iTree
//
//  Created by mcmanderson on 6/5/17.
//  Copyright © 2017 mcmanderson. All rights reserved.
//

import UIKit

class MyCALayer: CALayer {

	@NSManaged var translateTreeBy:CGFloat


	override init()
		{
		super.init()
		print ("Initialized MyCALayer()")
		translateTreeBy=0.0
		//setup()
		}


	override init(layer: Any)
		{
		// This gets called a lot to make shadow copies of layer's (custom?) instance variables; hopefully not a memory leak
		super.init(layer: layer)
		print ("Initialized MyCALayer(layer)")
		if let layer = layer as? MyCALayer
			{
			translateTreeBy = layer.translateTreeBy
			}
		}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder:aDecoder)
		print ("Initialized MyCALayer")
	}


	override class func needsDisplay(forKey key: String) -> Bool
		{
		if self.isCustomAnimKey(key: key)
			{
			return true
			}
		return super.needsDisplay(forKey: key)
		}
	 
	private class func isCustomAnimKey(key: String) -> Bool
		{
		return key == "translateTreeBy"
		}


	override func action(forKey event: String) -> CAAction?
		{
		if MyCALayer.isCustomAnimKey(key: event)
			{
			if let animation = super.action(forKey: "backgroundColor") as? CABasicAnimation
				{
				animation.keyPath = event
				if let pLayer = presentation()
					{
					animation.fromValue = pLayer.translateTreeBy
					}
				animation.toValue = nil
				return animation
				}
			setNeedsDisplay()
			return nil
			}
		return super.action(forKey: event)
		}



}
