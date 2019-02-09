//
//  SimonTreeNwk.swift
//  iTree
//
//  Created by mcmanderson on 5/25/17.
//  Copyright © 2019 Michael J Sanderson. All rights reserved.
//

// Data model for information regarding trees/studies, whether within app or in remote database

import UIKit
//import QuartzCore

class TreesData
	{
	// 
	//var treeInfoDictionary = [String:TreeInfoPackage]()
	var treeInfoDictionary:[String:TreeInfoPackage] = [:]
	//var treeInfoNamesSortedArray = [String]()
	var treeInfoNamesSortedArray:[String] = []

	enum TreesDataError: Error {
		case zeroEntries
		}

	init(usingMetaDataFileAt url:URL) throws
		{
		let s = try String(contentsOf:url)
		let lines = s.components(separatedBy: "\n")
		for line in lines
			{
			if line == "" { continue } // if lines begins or ends with \n the components method returns ""
			let treeInfo = try TreeInfoPackage(fromTableLine:line) // right now this dos not throw errors but could in future code
			treeInfo.dataLocation = .inBundle
			treeInfoDictionary[(treeInfo.treeName)]=treeInfo
			}
		treeInfoNamesSortedArray = Array(treeInfoDictionary.keys).sorted(by: <)
		if treeInfoNamesSortedArray.count == 0
			{ throw TreesDataError.zeroEntries}
		}

	init() throws
		{
		let nexusFilenamesFromBundle = getNexusFilenamesFromBundle()
		let nexusFilenamesFromDocDir = getNexusFilenamesFromDocumentsDir()

		for nexFile in nexusFilenamesFromBundle
			{
			let treeInfo = try TreeInfoPackage(fromFileName: nexFile)
			treeInfo.dataLocation = .inBundle
			treeInfoDictionary[(treeInfo.treeName)]=treeInfo
			}
		for nexFile in nexusFilenamesFromDocDir
			{
			let treeInfo = try TreeInfoPackage(fromFileName: nexFile)
			treeInfo.dataLocation = .inDocuments
			treeInfoDictionary[(treeInfo.treeName)]=treeInfo
			}
		treeInfoNamesSortedArray = Array(treeInfoDictionary.keys).sorted(by: <)
		}

	func appendTreesData(withTreeInfo treeInfo: TreeInfoPackage)
		{
		treeInfoDictionary[(treeInfo.treeName)]=treeInfo
		treeInfoNamesSortedArray.insert(treeInfo.treeName, at:0)
	
		}

	func selectTreeView(forTreeName treeName:String)->TreeView
		{
		// make all trees that have had a treeView at sometime in past be hidden in prep for selecting a new one
		for treeInfo in treeInfoDictionary.values
			{
			if treeInfo.treeView != nil
				{treeInfo.isHidden = true}
			}
			
		let treeInfo = treeInfoDictionary[treeName]!
		if treeInfo.treeView == nil // This tree view has never been created, so init it and return it
			{
			treeInfo.treeView = TreeView(using:treeInfo)
			}
		treeInfo.treeView!.isHidden = false
		return treeInfo.treeView!
		}

	func getNexusFilenamesFromBundle()->[String] // THESE HAVE TO HAVE A .NEX EXTENSION!!  No reason, just filename management in the bundle.
			{
			var matchingFileNames = [String]()
			let fileManager = FileManager.default
			do {
				let files = try fileManager.contentsOfDirectory(atPath:Bundle.main.bundlePath)
				for file in files
					{
					let matchesAr = matches(for: "\\.nex", in: file, withOptions:[.caseInsensitive])
					if matchesAr.count == 1
						{
						let filePath = Bundle.main.bundlePath + "/" + file
						if fileManager.fileExists(atPath: filePath)
							{
							//print(filePath,"...exists")
							matchingFileNames.append(filePath)
							}
						}
					}
				}
			catch
				{
				print ("Nexus Files not found")
				}

			return matchingFileNames
			}

	func getNexusFilenamesFromDocumentsDir()->[String]
		// If a study was added by document picker, the picker will only allow text files, but regardless of extension
		// The danger is that any file(s) might end up stored in the Tree directory, so for now, will try to parse first one. It might fail.
			{
			var matchingFileNames = [String]()
			let fileManager = FileManager.default
			if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
				{
				let studyDir = docsDir.appendingPathComponent("Studies")
				if let studyFolders = try? fileManager.contentsOfDirectory(at: studyDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
					{
					for studyFolder in studyFolders
						{
						let treeDir = studyFolder.appendingPathComponent("Tree")
						if let fileURLs = try? fileManager.contentsOfDirectory(at: treeDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
							{
							for fileURL in fileURLs
								{
								if fileURLs.count == 1
									{
									matchingFileNames.append(fileURL.path)
									}
								else
									{ print ("Failed to find exactly one nexus file in Tree directory")}}
								}
							}
						}
					}
			return matchingFileNames
			}




	}

//*************************************************************************
enum PhloraDataLocation {
	case inBundle
	case inDocuments
	}

class TreeInfoPackage
	{
	var treeName:String
	var displayTreeName:String
	var treeDescription:String
	var treeSource:String
	var mrcaArray: [Dictionary<String, String>] = []
	var treeViewController:TreeViewController?
	var treeView:TreeView?
	var isHidden:Bool = true
	var nLeaves:Int=0
	var nImages:Int?
	var imageSpace:Float?
	
	var dataLocation:PhloraDataLocation?
	var thumbStudyImage:UIImage?

	init(fromFileName file:String) throws
		{
			let nexusString = try String(contentsOfFile: file)
			(nLeaves, treeName, treeDescription, treeSource, mrcaArray) = try nexusParser(fromString: nexusString)
			displayTreeName = treeName.replacingOccurrences(of: "_", with: " ")
		}

	init(fromURL url : URL) throws
		{
			let nexusString = try String(contentsOf: url)
			(nLeaves, treeName, treeDescription, treeSource, mrcaArray) = try nexusParser(fromString: nexusString)
			displayTreeName = treeName.replacingOccurrences(of: "_", with: " ")
		}
	init(fromTableLine ln:String) throws
		{
			let fields = ln.components(separatedBy: "\t")
			treeName = fields[0]
			displayTreeName = treeName.replacingOccurrences(of: "_", with: " ")
			treeSource = fields[1]
			nLeaves = Int(fields[2])!
			nImages = Int(fields[3])
			imageSpace = Float(fields[4])
			treeDescription = ""

			//displayTreeName = treeName.replacingOccurrences(of: "_", with: " ")
		}
	}

//*************************************************************************

	func nexusParser(fromString nexusString:String) throws ->(Int,String,String,String, [[String:String]])
		{
		var mrca: [String:String] = [:]
		var mrcaArray: [Dictionary<String, String>] = []
		var treeDescription:String = ""
		var treeSource = ""
		var treeName:String = ""
		var nLeaves = 1
		var nLeftParens = 0
		var nRightParens = 0
		
		let commands = nexusString.split(whereSeparator: { $0 == ";" })
		for command in commands
			{
			//let chomped = command.drop(while: {$0 == "\n"}) ...working inconsistently
			let ctokens = matches(for: nwktokensTilde, in: String(command),withOptions:[.caseInsensitive])

			if ctokens.count >= 3 // could be a valid line; there might be others that just have white space or crap
				{
				if ctokens[0].lowercased() == "mrca" && ctokens[2] == "=" && ctokens.count == 6
					{
					//print ("Taxa = ",ctokens[1],ctokens[3],ctokens[5])
					mrca["cladeName"] = ctokens[1]
					mrca["specifierA"] = ctokens[3]
					mrca["logic"] = ctokens[4]	// this is either a ',' or a '~'
					mrca["specifierB"] = ctokens[5]
					mrcaArray.append(mrca)
					}

				if ctokens[0].lowercased() == "tree" && ctokens[2] == "=" && ctokens.count >= 4
					{
					treeName = ctokens[1]
					for token in ctokens[3...ctokens.count-1]
						{
						switch token
							{
							case ",":
								nLeaves += 1 // counting the number of leaves as commas+1
							case "(":
								nLeftParens += 1 // counting the number of leaves as commas+1
							case ")":
								nRightParens += 1 // counting the number of leaves as commas+1
							default:
								break
							}
						}
					treeDescription = ctokens[3...ctokens.count-1].joined()
					}

				if ctokens[0].lowercased() == "reference" && ctokens[1] == "=" && ctokens.count >= 3
					{
					treeSource = ctokens[2...ctokens.count-1].joined()
					treeSource = treeSource.replacingOccurrences(of: "'", with: "")
					}
				}
			}
		guard nLeaves>2 else {throw parserError.invalidTreeDescription}
		guard treeName != "" else {throw parserError.invalidTreeDescription}
		guard nRightParens == nLeftParens else {throw parserError.invalidTreeDescription}

		return (nLeaves, treeName, treeDescription, treeSource, mrcaArray)
		}



enum parserError: Error
	{
	case invalidTreeDescription
	}

/* Comments on parser
	1. Taxon names must begin with a letter and can only have letters, digits and underscores after that.
	2. Branch lengths can be in scientific notation but must be positive
*/

let nexusToken = "#nexus"
let commentTokens = "\\[.*?\\]"
//let nameTokens = "[A-Za-z]\\w*|\\'.*?\\'"   // Starts with letter, but can include additional numbers, underscores...remember \w includes letters numbers and underscore
let nameTokens = "[A-Za-z][-\\.\\w]*|\\'.*?\\'"   // Starts with letter, but can include additional numbers, underscores...remember \w includes letters numbers and underscore. Also, 1/5/19 I added dash to valid raw name token, but it is STILL MISHANDLING DASHES WITHIN A SINGLE QUOTE! 1/29/19 I added period character to this to handle things like 'spp.' in names
let puncTokens = "[=\\,\\(\\)\\;\\:]" // Does not include period
let numberTokens = "[0-9]+\\.?[0-9]+([eE][-+]\\d+)?"
let nwktokens = nameTokens + "|" + puncTokens   + "|" + numberTokens
let puncTokensPlusTilde = "[~=\\,\\(\\)\\;\\:]"
let nwktokensTilde = nameTokens + "|" + puncTokensPlusTilde // tilde not part of nwk specifications?


// Wrapper for regex match;  (thanks to StackOverflow!)
func matches(for regex: String, in text: String, withOptions options:NSRegularExpression.Options) -> [String] {

	do {
		let regex = try NSRegularExpression(pattern: regex, options:options)
		let nsString = text as NSString
		let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
		return results.map { nsString.substring(with: $0.range)}
	} catch let error {
		print("invalid regex: \(error.localizedDescription)")
		return []
	}
}

enum DataFileType {
	case treeFile
	case imageFile
	case textFile
	}


func fileExistsInDocs(srcFileType fileType:DataFileType, srcFilename:String, forStudy studyName:String) ->Bool
	// Check if a filename of a given type is present in the appropriate dir

	{
	var targetURL:URL
	let fileManager = FileManager.default
	if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		{
		targetURL = docsDir.appendingPathComponent("Studies").appendingPathComponent(studyName)
		switch fileType
			{
			case .textFile:
				targetURL = targetURL.appendingPathComponent("Text")
			case .treeFile:
				targetURL = targetURL.appendingPathComponent("Tree")
			case .imageFile:
				targetURL = targetURL.appendingPathComponent("Images")
			}
		targetURL = targetURL.appendingPathComponent(srcFilename)
		return fileManager.fileExists(atPath: targetURL.path)
		}
	return false
	}


// Newest version of this ...must provide source file names, whether from a node or elsewhere
func copyURLToDocs(src srcURL:URL, srcFileType fileType:DataFileType, srcFilename:String, forStudy studyName:String, overwrite:Bool) throws -> URL?
	// Copy a treefile, textfile or imagefile from some URL to correct Docs folder. Create such a folder if doesn't exist.
	// For tree or text, set node to nil.
	// If an image file, do special handling
	//		if node == nil, just copy to Images dir keeping the filename from the source URL
	//		if node is present, however, rename the new URL so that its name reflects the name of the node label!

	{
	var targetDir:URL
	var destURL:URL
	// May need to creat Studies dir, StudyName dir and either Tree/Images directory as needed
	let fileManager = FileManager.default
	if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		{
		targetDir = docsDir.appendingPathComponent("Studies").appendingPathComponent(studyName)
		switch fileType
			{
			case .textFile:
				targetDir = targetDir.appendingPathComponent("Text")
			case .treeFile:
				targetDir = targetDir.appendingPathComponent("Tree")
			case .imageFile:
				targetDir = targetDir.appendingPathComponent("Images")
			}
		destURL = targetDir.appendingPathComponent(srcFilename) // node was set to nil when called; just use original URL filename
		if fileManager.fileExists(atPath: targetDir.path) == false  // create the correct Study folder (and ancestors) if needed
			{
			try fileManager.createDirectory(at: targetDir, withIntermediateDirectories: true, attributes: nil)
			// THIS MIGHT FAIL; NEED TO DO ERROR HANDLING HERE!!
			}
		do
			{
			if fileManager.fileExists(atPath: destURL.path)
				{
				if overwrite
					{
					try? fileManager.removeItem(at: destURL) // if it's there get rid of it, then copy to it
					try fileManager.copyItem(at: srcURL, to: destURL)
					}
				else
					{ return nil }
				}
			else
				{
				try fileManager.copyItem(at: srcURL, to: destURL)
				}
			}
		catch
			{print ("Copy didn't succeed", error)}
		return destURL
		}
	return nil
	}

func copyURLToDocs(src srcURL:URL, srcFileType fileType:DataFileType, forStudy studyName:String, atNode node:Node?) throws -> URL?
	// Copy a treefile, textfile or imagefile from some URL to correct Docs folder. Create such a folder if doesn't exist.
	// For tree or text, set node to nil.
	// If an image file, do special handling
	//		if node == nil, just copy to Images dir keeping the filename from the source URL
	//		if node is present, however, rename the new URL so that its name reflects the name of the node label!

	{
	var targetDir:URL
	var destURL:URL?
	// May need to creat Studies dir, StudyName dir and either Tree/Images directory as needed
	let fileManager = FileManager.default
	if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		{
		targetDir = docsDir.appendingPathComponent("Studies").appendingPathComponent(studyName)
		let srcFilename = srcURL.lastPathComponent
		switch fileType
			{
			case .textFile:
				targetDir = targetDir.appendingPathComponent("Text")
				destURL = targetDir.appendingPathComponent(srcFilename)
			case .treeFile:
				targetDir = targetDir.appendingPathComponent("Tree")
				destURL = targetDir.appendingPathComponent(srcFilename)
			case .imageFile:
				targetDir = targetDir.appendingPathComponent("Images")
				if let node = node
					{
					let fileExtension = srcURL.pathExtension
					let fileName = node.originalLabel!
					destURL = targetDir.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
					}
				else
					{
					destURL = targetDir.appendingPathComponent(srcFilename) // node was set to nil when called; just use original URL filename
					}
			}
		if fileManager.fileExists(atPath: targetDir.path) == false  // create the correct Study folder (and ancestors) if needed
			{
			try fileManager.createDirectory(at: targetDir, withIntermediateDirectories: true, attributes: nil)
			// THIS MIGHT FAIL; NEED TO DO ERROR HANDLING HERE!!
			}
		do
			{
			try fileManager.copyItem(at: srcURL, to: destURL!)
			}
		catch
			{print ("Copy didn't succeed", error)}
		return destURL
		}
	return nil
	}

func copyImageToDocs(srcImage image:UIImage, srcFileType fileType:DataFileType, forStudy studyName:String, atNode node:Node?) throws -> URL?
	// Copy a treefile or imagefile from some URL to correct Docs folder. Create such a folder if doesn't exist.
	// If an image file, rename its copy based on the leaf label for that node.
	{
	var targetDir:URL
	var destURL:URL?
	// May need to creat Studies dir, StudyName dir and either Tree/Images directory as needed
	let fileManager = FileManager.default
	if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		{
		targetDir = docsDir.appendingPathComponent("Studies").appendingPathComponent(studyName)
		//let srcFilename = srcURL.lastPathComponent
		switch fileType
			{
			case .textFile:
				break // FINISH THIS!!!!!!!!!!!!!!!!!!
			case .treeFile:
				return nil
			case .imageFile:
				targetDir = targetDir.appendingPathComponent("Images")
				if let node = node
					{
					let fileExtension = "jpg"
					let fileName = node.originalLabel!
					destURL = targetDir.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
//print ("-->",destURL)
					}
			}
		if fileManager.fileExists(atPath: targetDir.path) == false  // create the correct Study folder (and ancestors) if needed
			{
			try fileManager.createDirectory(at: targetDir, withIntermediateDirectories: true, attributes: nil)
	// THIS MIGHT FAIL; NEED TO DO ERROR HANDLING HERE!!
			}
		do
			{
			//try fileManager.copyItem(at: srcURL, to: destURL!)
			if let jpeg = UIImageJPEGRepresentation(image, 1.0)
				{
				try jpeg.write(to:destURL!,options:[])
				}
			}
		catch
			{
			print ("Copy didn't succeed", destURL!, error)}
			return destURL
			}
		return nil
		}

func getManifestData(forStudy study:String, atRemoteServerPath serverPath:String) throws -> [(DataFileType , URL)]
	{
	var manifestArray:[(DataFileType , URL)] = []
	var fileType:DataFileType?
	guard let manifestURL = URL(string:serverPath)?.appendingPathComponent("Studies").appendingPathComponent(study).appendingPathComponent("Manifest.txt") else {return manifestArray}
	let s = try String(contentsOf:manifestURL)
	let lines = s.components(separatedBy: "\n")
	for line in lines
		{
		if line == "" { continue } // if lines begins or ends with \n the components method returns ""

		let fields = line.components(separatedBy: "\t")
		switch fields[0]
			{
			case "Image": // note this is 'Image' not 'Images', which is the directory name. This is a file type
				fileType = .imageFile
			case "Tree":
				fileType = .treeFile
			case "Text":
				fileType = .textFile
			default:
				break
			}
		if let url = URL(string:fields[1]),let fileType = fileType
			{
			manifestArray.append((fileType,url))
			}
		}
	return manifestArray
	}
