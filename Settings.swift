//
//  Settings.swift
//  iTree
//
//  Created by mcmanderson on 5/25/17.
//  Copyright © 2019 Michael J Sanderson. All rights reserved.
//

// Options used throughout app

import UIKit

struct Settings
	{
	let smallTableColWidth:CGFloat
	let mediumTableColWidth:CGFloat
	let largeButtonSize:CGSize		// e.g., buttons on main page
	let allowedToLoadImages:Bool
	let preLoadImages:Bool
	let imageBundleLoc:String
	let imageFileExtension:String
	let titleFontSize:CGFloat
	let titleFontName:String
	let titleFontColor:UIColor
	let labelFontSize:CGFloat
	let cladeLabelFontSize:CGFloat
	let labelFontName:String
	let labelFontColor:UIColor
	let infoFontSize:CGFloat
	let infoFontName:String
	let infoFontColor:UIColor
	let imageFontSize:CGFloat
	let imageFontName:String
	let imageFontColor:UIColor
	let imageMarginColor:CGColor
	let edgeColor:CGColor
	let edgeWidth:CGFloat
	let imageIconColor:CGColor
	let imageUnloadedColor:CGColor
	let imageIconRadius:CGFloat
	let imageIconAlphaThreshold:CGFloat
	let viewBackgroundColor:UIColor
	let truncateLabels:Bool
	let truncateLabelsLength:CGFloat
	let replaceUnderscore:Bool
	let replaceSingleQuotes:Bool
	let initialImagePaneSize:CGFloat
	let initialImageXPos:CGFloat // X position of center of image, in tree coords
	let imageToIconLineColor:CGColor
	let treeViewInsetX:CGFloat
	let treeViewInsetY:CGFloat
	let studyTableRowHeight:CGFloat
	let studyTableImageHeight:CGFloat
	let studyTableLabelFontSize:CGFloat
	let studyTableReferenceFontSize:CGFloat
	let studyTableNLeafFontSize:CGFloat
	let imageSizeAtLowRes:CGFloat
	let imageResolutionSmallSize:CGFloat // product of height and width of image is compared to this cutoff to determine its "resolution"
	let defaultDatabasePath:String
	let minLabelWidth:CGFloat // labels are not allowed to be squeezed smaller than this width
	}

let iPhoneTreeSettings=Settings(
	smallTableColWidth:75,
	mediumTableColWidth:75,
	largeButtonSize:CGSize(width: 200, height: 400),
	allowedToLoadImages:true,
	preLoadImages:false,
	imageBundleLoc:"Images.bundle",
	imageFileExtension:"jpg",
	titleFontSize:20,
	titleFontName:"Helvetica",
	titleFontColor:UIColor.white,
	labelFontSize:12,
	cladeLabelFontSize:24,
	labelFontName:"Helvetica",
	labelFontColor:UIColor.white,
	infoFontSize:16,
	infoFontName:"Helvetica",
	infoFontColor:UIColor.white,
	imageFontSize:24,
	imageFontName:"Helvetica",
	imageFontColor:UIColor.yellow,
	imageMarginColor:UIColor.white.cgColor,
	edgeColor:UIColor.green.cgColor,
	edgeWidth:1.5,
	imageIconColor:UIColor.gray.cgColor,
	imageUnloadedColor:UIColor.blue.cgColor,
	imageIconRadius:15.0,
	imageIconAlphaThreshold:0.75,
	viewBackgroundColor:UIColor.black,
	truncateLabels:true,
	truncateLabelsLength:100.0,
	replaceUnderscore:true,
	replaceSingleQuotes:true,
	initialImagePaneSize:150.0,
	initialImageXPos:300.0,
	imageToIconLineColor:UIColor.yellow.cgColor,
	treeViewInsetX:15,
	treeViewInsetY:15, // program sets X=Y anyway because of device rotations
	studyTableRowHeight:125,
	studyTableImageHeight:100,
	studyTableLabelFontSize:16,
	studyTableReferenceFontSize:12,
	studyTableNLeafFontSize:12,
	imageSizeAtLowRes:1000.0,
	imageResolutionSmallSize:1000000.0,
	//defaultDatabasePath:"http://db.herbarium.arizona.edu/phlora"
	defaultDatabasePath:"http://phlora.org",
	minLabelWidth:35
	)

	let iPadTreeSettings=Settings(
	smallTableColWidth:100,
	mediumTableColWidth:200,
	largeButtonSize:CGSize(width: 300, height: 600),
	allowedToLoadImages:true,
	preLoadImages:false,
	imageBundleLoc:"Images.bundle",
	imageFileExtension:"jpg",
	titleFontSize:30,
	titleFontName:"Helvetica",
	titleFontColor:UIColor.white,
	labelFontSize:18,
	cladeLabelFontSize:30,
	labelFontName:"Helvetica",
	labelFontColor:UIColor.white,
	infoFontSize:16,
	infoFontName:"Helvetica",
	infoFontColor:UIColor.white,
	imageFontSize:24,
	imageFontName:"Helvetica",
	imageFontColor:UIColor.yellow,
	imageMarginColor:UIColor.white.cgColor,
	edgeColor:UIColor.green.cgColor,
	edgeWidth:1.5,
	imageIconColor:UIColor.gray.cgColor,
	imageUnloadedColor:UIColor.blue.cgColor,
	imageIconRadius:15.0,
	imageIconAlphaThreshold:0.75,
	viewBackgroundColor:UIColor.black,
	truncateLabels:true,
	truncateLabelsLength:200.0,
	replaceUnderscore:true,
	replaceSingleQuotes:true,
	//initialImagePaneSize:250.0,
	initialImagePaneSize:400.0,
	initialImageXPos:300.0,
	imageToIconLineColor:UIColor.yellow.cgColor,
	treeViewInsetX:15,
	treeViewInsetY:15, // program sets X=Y anyway because of device rotations
	studyTableRowHeight:200,
	studyTableImageHeight:150,
	studyTableLabelFontSize:24,
	studyTableReferenceFontSize:14,
	studyTableNLeafFontSize:18,
	imageSizeAtLowRes:1000.0,
	imageResolutionSmallSize:1000000.0,
	//defaultDatabasePath:"http://db.herbarium.arizona.edu/phlora"
	defaultDatabasePath:"http://phlora.org",
	minLabelWidth:50
	)

	var treeSettings = iPadTreeSettings // as a default
