//
//  Settings.swift
//  iTree
//
//  Created by mcmanderson on 5/25/17.
//  Copyright © 2017 mcmanderson. All rights reserved.
//

import UIKit

struct Settings
	{
	let allowedToLoadImages:Bool
	let preLoadImages:Bool
	let imageBundleLoc:String
	let imageFileExtension:String
	let titleFontSize:CGFloat
	let titleFontName:String
	let titleFontColor:UIColor
	let labelFontSize:CGFloat
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
	let imageIconRadius:CGFloat
	let imageIconAlpha:CGFloat
	let viewBackgroundColor:UIColor
	let truncateLabels:Bool
	let truncateLabelsLength:CGFloat
	let replaceUnderscore:Bool
	let replaceSingleQuotes:Bool
	let initialImageSize:CGFloat
	let initialImageXPos:CGFloat // X position of center of image, in tree coords
	let imageToIconLineColor:CGColor
	let treeViewInsetX:CGFloat
	let treeViewInsetY:CGFloat
	let helpViewSize:CGSize
	let helpFileNamePrefix:String // .html file with Phlora help information as HTML text
	let studyTableRowHeight:CGFloat
	let studyTableImageHeight:CGFloat
	let studyTableLabelFontSize:CGFloat
	let studyTableReferenceFontSize:CGFloat
	let studyTableNLeafFontSize:CGFloat
	}

let iPhoneTreeSettings=Settings(
	allowedToLoadImages:true,
	preLoadImages:false,
	imageBundleLoc:"Images.bundle",
	imageFileExtension:"jpg",
	titleFontSize:30,
	titleFontName:"Helvetica",
	titleFontColor:UIColor.white,
	labelFontSize:12,
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
	imageIconRadius:15.0,
	imageIconAlpha:0.75,
	viewBackgroundColor:UIColor.black,
	truncateLabels:true,
	truncateLabelsLength:100.0,
	replaceUnderscore:true,
	replaceSingleQuotes:true,
	initialImageSize:150.0,
	initialImageXPos:300.0,
	imageToIconLineColor:UIColor.yellow.cgColor,
	treeViewInsetX:15,
	treeViewInsetY:15, // program sets X=Y anyway because of device rotations
	helpViewSize:CGSize(width: 250, height: 400),
	helpFileNamePrefix:String("helpDocPhone"),
	studyTableRowHeight:125,
	studyTableImageHeight:100,
	studyTableLabelFontSize:16,
	studyTableReferenceFontSize:12,
	studyTableNLeafFontSize:12
	)

	let iPadTreeSettings=Settings(
	allowedToLoadImages:true,
	preLoadImages:false,
	imageBundleLoc:"Images.bundle",
	imageFileExtension:"jpg",
	titleFontSize:30,
	titleFontName:"Helvetica",
	titleFontColor:UIColor.white,
	labelFontSize:18,
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
	imageIconRadius:15.0,
	imageIconAlpha:0.75,
	viewBackgroundColor:UIColor.black,
	truncateLabels:true,
	truncateLabelsLength:200.0,
	replaceUnderscore:true,
	replaceSingleQuotes:true,
	initialImageSize:150.0,
	initialImageXPos:300.0,
	imageToIconLineColor:UIColor.yellow.cgColor,
	treeViewInsetX:15,
	treeViewInsetY:15, // program sets X=Y anyway because of device rotations
	helpViewSize:CGSize(width: 500, height: 400),
	helpFileNamePrefix:String("helpDoc"),
	studyTableRowHeight:200,
	studyTableImageHeight:150,
	studyTableLabelFontSize:24,
	studyTableReferenceFontSize:14,
	studyTableNLeafFontSize:18
	)

	var treeSettings = iPadTreeSettings // as a default
