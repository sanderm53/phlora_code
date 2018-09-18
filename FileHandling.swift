//
//  FileHandling.swift
//  QGTut
//
//  Created by mcmanderson on 9/13/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import UIKit

enum DirectoryType {
	case study
	case images
	case tree
	}

func copyImageToDocs(srcImage image:UIImage, copyToDir targetDir:URL, usingFileNameBase targetFileNameBase:String) throws -> URL?
	// Copy a treefile or imagefile from some URL to correct Docs folder. Create such a folder if doesn't exist.
	// If an image file, rename its copy based on the leaf label for that node.
	{
	//var targetDir:URL
	var destURL:URL?
	let fileExtension = "jpg"
	let fileManager = FileManager.default
	destURL = targetDir.appendingPathComponent(targetFileNameBase).appendingPathExtension(fileExtension)
	if fileManager.fileExists(atPath: targetDir.path) == false  // create the correct Study folder (and ancestors) if needed
		{
		try fileManager.createDirectory(at: targetDir, withIntermediateDirectories: true, attributes: nil)
// THIS MIGHT FAIL; NEED TO DO ERROR HANDLING HERE!!
		}
	do {
		if let jpeg = UIImageJPEGRepresentation(image, 1.0)
			{
			try jpeg.write(to:destURL!,options:[])
			}
		}
	catch
		{
		print ("Copy didn't succeed", destURL, error)
		}
	return destURL
	}










//func docDirectoryNameFor(study studyName:String, ofType dirType: DirectoryType, forDataLocation dataLocation:PhloraDataLocation)  -> URL?
func docDirectoryNameFor(treeInfo:TreeInfoPackage, ofType dirType: DirectoryType)  -> URL?
	{
	let fileManager = FileManager.default
	let studyName = treeInfo.treeName
	guard let dataLocation = treeInfo.dataLocation
	else { return nil }
	switch dataLocation
		{
		case .inBundle:
				switch dirType
					{
					case .study:
						return nil
					case .tree:
						return Bundle.main.bundleURL
					case .images:
						return Bundle.main.bundleURL.appendingPathComponent(treeSettings.imageBundleLoc).appendingPathComponent(studyName)
					}

		case .inDocuments:
			if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
				{
				let studyDir = docsDir.appendingPathComponent("Studies").appendingPathComponent(studyName)
				switch dirType
					{
					case .study:
						return studyDir
					case .tree:
						return studyDir.appendingPathComponent("Tree")
					case .images:
						return studyDir.appendingPathComponent("Images")
					}
				}
			else
				{return nil}
		
		
		}
	}

func getStudyImage(treeInfo:TreeInfoPackage) -> UIImage? // which has a filename like study.jpg
	{
	if let dir = docDirectoryNameFor(treeInfo:treeInfo, ofType:.images)
		{
		let ext = ["jpg","png"]

		let imageURL0 = dir.appendingPathComponent(treeInfo.treeName).appendingPathExtension(ext[0])
		let imageURL1 = dir.appendingPathComponent(treeInfo.treeName).appendingPathExtension(ext[1])
		var image = UIImage(contentsOfFile:imageURL0.path)
		if image == nil
			{
			image = UIImage(contentsOfFile:imageURL1.path) // try the other extension
			if image == nil
				{ return nil }
			}
		return image
		}
	else {return nil}
	}

/*
// IN PROCESS OF KILLING THIS CODE:
func getImageFromFile(withFileNamePrefix fileNamePrefix:String, atTreeDirectoryNamed treeDir:String)->UIImage?
	// treeDir is commonly just named from the treeName
	{
		let ext = ["jpg","png"]
		let imageBundlePath = Bundle.main.bundlePath + "/" + treeSettings.imageBundleLoc + "/" + treeDir
		guard let imageBundle = Bundle(path: imageBundlePath	)
		else { return nil }
		let imageFilename0 = fileNamePrefix+"."+ext[0]
		let imageFilename1 = fileNamePrefix+"."+ext[1]
		var image = UIImage(named:imageFilename0,in:imageBundle,compatibleWith:nil)
		if image == nil
			{
			image = UIImage(named:imageFilename1,in:imageBundle,compatibleWith:nil) // try the other extension
			if image == nil
				{ return nil }
			}
		return image
	}
*/
