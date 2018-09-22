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
	case text
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









func docDirectoryNameFor(study studyName:String, inLocation dataLocation: PhloraDataLocation, ofType dirType: DirectoryType, create createFlag:Bool)  -> URL?
	{
	let fileManager = FileManager.default
	//let studyName = treeInfo.treeName
	//guard let dataLocation = treeInfo.dataLocation
	//else { return nil }
	switch dataLocation
		{
		case .inBundle:
				switch dirType
					{
					case .study:
						return nil
					case .tree, .text:
						return Bundle.main.bundleURL
					case .images:
						return Bundle.main.bundleURL.appendingPathComponent(treeSettings.imageBundleLoc).appendingPathComponent(studyName)
					}

		case .inDocuments:
			if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
				{
				var studyDir = docsDir.appendingPathComponent("Studies").appendingPathComponent(studyName)
				switch dirType
					{
					case .study:
						break
					case .tree:
						studyDir = studyDir.appendingPathComponent("Tree")
					case .images:
						studyDir = studyDir.appendingPathComponent("Images")
					case .text:
						studyDir = studyDir.appendingPathComponent("Text")
					}
				if createFlag == true && fileManager.fileExists(atPath: studyDir.path) == false  // create if needed
					{
					do {
						try fileManager.createDirectory(at: studyDir, withIntermediateDirectories: true, attributes: nil)
						}
					catch
						{ return nil }
					}
				return studyDir
				}
			else
				{return nil}
		}
	}

func getStudyImage(forStudyName studyName:String, inLocation location:PhloraDataLocation) -> UIImage? // which has a filename like study.jpg
	{
	var image,returnImage:UIImage?
	let ext = ["jpg","png"]
	if location == .inBundle
		{
		if let dir = docDirectoryNameFor(study:studyName, inLocation:.inBundle, ofType:.images, create: true)
			{
			let imageURL0 = dir.appendingPathComponent(studyName).appendingPathExtension(ext[0])
			let imageURL1 = dir.appendingPathComponent(studyName).appendingPathExtension(ext[1])
			var image = UIImage(contentsOfFile:imageURL0.path)
			if image == nil
				{
				image = UIImage(contentsOfFile:imageURL1.path) // try the other extension
				}
			returnImage = image
			}
		}

	if let dir = docDirectoryNameFor(study:studyName, inLocation:.inDocuments, ofType:.images, create: true)
		{
		let imageURL0 = dir.appendingPathComponent(studyName).appendingPathExtension(ext[0])
		let imageURL1 = dir.appendingPathComponent(studyName).appendingPathExtension(ext[1])
		image = UIImage(contentsOfFile:imageURL0.path)
		if image == nil
			{
			image = UIImage(contentsOfFile:imageURL1.path) // try the other extension
			}
		if image != nil
			{returnImage = image} // second, docs image takes precedence and gets returned if present
		}
	
	return returnImage
	}

func getFileURLMatching(study studyName:String, filenameBase fnb:String, extensions exts:[String], ofType dirType: DirectoryType, create createFlag:Bool)->URL?
// Returns LAST URL that matches looking first in bundle then in docs and looking at all extensions.
// Checks both bundle and docs even though we could pass the parameter to tell it which; keep code simple
	{
	var retURL:URL?
	let fileManager = FileManager.default
	let dataLocations = [PhloraDataLocation.inBundle, PhloraDataLocation.inDocuments]
	for dataLocation in dataLocations
		{
		if let dir = docDirectoryNameFor(study:studyName, inLocation:dataLocation, ofType:dirType, create: createFlag)
			{
			for ext in exts
				{
				let url = dir.appendingPathComponent(fnb).appendingPathExtension(ext)
				if fileManager.fileExists(atPath: url.path)
					{
					retURL = url
					}
				}
			}
		}
	return retURL
	}

func getStudyImage(forStudyName studyName:String) -> UIImage? // which has a filename like study.jpg
	{
	guard let url = getFileURLMatching(study:studyName, filenameBase:studyName, extensions: ["jpg","png"], ofType:.images, create:true) else { return nil }
	return UIImage(contentsOfFile:url.path)
}
