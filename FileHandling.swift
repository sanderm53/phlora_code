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
//**********************

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
		print ("Copy didn't succeed", destURL!, error)
		}
	return destURL
	}

//**********************

// Location of files depends on whether they are built-in or user-added (cf. PhloraDataLocation enum). Form a correct URL for this
// and return it with subdirectories for images, trees, etc., as needed. This URL will be used to read or write as needed.

func docDirectoryNameFor(study studyName:String, inLocation dataLocation: PhloraDataLocation, ofType dirType: DirectoryType, create createFlag:Bool)  -> URL?
	{
	let fileManager = FileManager.default

	switch dataLocation
		{
		case .inBundle:
				switch dirType
					{
					//case .study:
					//	return nil
					case .tree, .text, .study:
						return Bundle.main.bundleURL
					case .images:
						return Bundle.main.bundleURL.appendingPathComponent(treeSettings.imageBundleLoc).appendingPathComponent(studyName)
					}

		case .inDocuments:
			if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
				{
				var theDir = docsDir.appendingPathComponent("Studies").appendingPathComponent(studyName)
				switch dirType
					{
					case .study:
						break
					case .tree:
						theDir = theDir.appendingPathComponent("Tree")
					case .images:
						theDir = theDir.appendingPathComponent("Images")
					case .text:
						theDir = theDir.appendingPathComponent("Text")
					}
				if createFlag == true && fileManager.fileExists(atPath: theDir.path) == false  // create if needed
					{
					do {
						try fileManager.createDirectory(at: theDir, withIntermediateDirectories: true, attributes: nil)
						}
					catch
						{ return nil }
					}
				return theDir
				}
			else
				{return nil}
		}
	}


//**********************

func getFileURLMatching(study studyName:String, filenameBase fnb:String, extensions exts:[String], ofType dirType: DirectoryType)->URL?
// Returns LAST URL that matches looking first in bundle then in docs and looking at all extensions.
// Checks both bundle and docs even though we could pass the parameter to tell it which; keep code simple
	{
	var retURL:URL?
	let fileManager = FileManager.default
	let dataLocations = [PhloraDataLocation.inBundle, PhloraDataLocation.inDocuments]
	for dataLocation in dataLocations
		{
		if let dir = docDirectoryNameFor(study:studyName, inLocation:dataLocation, ofType:dirType, create: false)
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

//**********************


