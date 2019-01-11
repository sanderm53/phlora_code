//
//  XTree.swift
//  QGTut
//
//  Created by mcmanderson on 5/16/17.
//  Copyright © 2017 mcmanderson. All rights reserved.
//

import UIKit



enum TreeType {
	case cladogram
	case phylogram
	case chronogram
	}

enum LadderizeType {
	case left
	case right
	case asis
	}

struct Position {
	var pos:Int
	var nearestLeft:Int
	var nearestRight:Int
	
	init(at pos:Int)
		{
		self.pos = pos
		nearestLeft = -10000
		nearestRight = +10000
		}
	
	}

class XTree {

	var tok: String
	var root: Node!		// Only solution I've found to problem of the initializer calling makeClade is to make this an optional
	var tokix: Int=0
	var tokens: [String]
	var nodeArray: [Node]=[] // leaf node array, nodes laid out in order top to bottom on screen, since ladderize is set by default
	// MOVE TO IMAGE TABLE... var nodeArraySortedByLabel: [Node] = [] // based on previous but sorted alphabetically by original leaf label; SHOULD DO LAZY SOMEHOW?
	var nodeHash: [String:Node] = [:]
	var minY:CGFloat=0.0 // min and max leaf node locations
	var maxY:CGFloat=0.0
	var numDescLvs:UInt!
	//var imageCollection:ImageCollection!
	var treeInfo:TreeInfoPackage
	var hasCladeNames:Bool=false
	var hasImageFiles:Bool=false
	var nImages:Int = 0

	//init(withNwkStr nwktree : String)
	init(withTreeInfoPackage data : TreeInfoPackage)
		{
		treeInfo = data

		tokens = matches(for: nwktokens, in: treeInfo.treeDescription, withOptions:[])
		//print(tokens)
		tok=tokens[0]
		root = makeClade()						// Make the tree structure from nwk string
		numDescLvs=root.numDescendantLeaves()	// Sets up this node property at all nodes
		root.ladderize(direction: .left)
		var startingID:UInt = 0
		(_,_) = root.assignLeafIDs(startingWith:&startingID)
		root.putNodeArray(into:&nodeArray)
		for node in nodeArray { nodeHash [node.originalLabel!] = node }

		// TO IMAGE TABLE... nodeArraySortedByLabel = nodeArray.sorted (by: {$0.originalLabel! < $1.originalLabel! } )

		root.prepareLabels()					// This edits labels as requested, copying originallable->label
		//root.setEdgeAlphaModifier(haveSeenInternalLabel: root.isLabelPresent()) // works on label, so prepare must be done first
		let mrcaArray = treeInfo.mrcaArray
		assignLabels(fromMRCAList:mrcaArray)
		nImages = checkForImageFiles()

		setupNearestImageIconPositions(for:nodeArray) // also called in process_images() in fetchImageController when adding a new image
		}
	func setupNearestImageIconPositions(for nodeArray:[Node])
		// the integer distance between the closer image icon above and below;
		// NEED TO CHECK BOUNDARY CASES
		{
		var curPos:Position?
		var prevPos:Position
		curPos = Position(at:0)
		if nodeArray[0].hasImageFile()
			{
			curPos = Position(at:0)
			}
		else
			{
			curPos = nextPos(for:nodeArray,after:0)
			}
		while curPos != nil
			{
			prevPos = curPos!
			curPos = nextPos(for:nodeArray,after:curPos!.pos)
			if curPos != nil
				{
				prevPos.nearestRight = curPos!.pos
				curPos!.nearestLeft = prevPos.pos

				}
			nodeArray[prevPos.pos].closestImageIconNeighberDistance = min(abs(prevPos.pos-prevPos.nearestLeft),abs(prevPos.pos-prevPos.nearestRight))
//print ("NNd ",prevPos.pos, nodeArray[prevPos.pos].closestImageIconNeighberDistance)
			}
		}
	func nextPos(for nodeArray:[Node], after pos:Int)->Position?
		{
		if pos+1 <= nodeArray.count-1
			{
			for i in pos+1...nodeArray.count-1
				{
				if nodeArray[i].hasImageFile()
					{ return Position(at:i)}
				}
			}
		return nil
		}

	func checkForImageFiles() -> Int
		{
		// If a data package is annotated as being .inDocuments its image files are ONLY in that location,
		// but if they are .inBundle, they might be in either place because user may have added their own images
		// to a bundle data set.
		// Note this checks for both node and study images...
		var nImages = 0
		var nodesWithImagesDict:[String:Bool] = [:]
		let fileManager = FileManager.default

		// Iff it is a bundle data location,  check there
		if treeInfo.dataLocation! == .inBundle
			{
			let imageBundleURL = Bundle.main.bundleURL.appendingPathComponent(treeSettings.imageBundleLoc).appendingPathComponent(treeInfo.treeName)
			if let fileURLs = try? fileManager.contentsOfDirectory(at: imageBundleURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
						{
						for fileURL in fileURLs
							{
							let fileNameBase = fileURL.deletingPathExtension().lastPathComponent
							if let node = nodeHash[fileNameBase]
								{
								//print ("\(fileNameBase) exists in tree")
								//node.hasImageFile() = true
								node.imageFileURL = fileURL
								node.imageFileDataLocation = .inBundle
								nodesWithImagesDict[fileNameBase] = true
								hasImageFiles=true
								}
							else
								{
								//print ("Filebase from bundle not found on tree:",fileNameBase)
								}
							}
						nImages = nodesWithImagesDict.keys.count
						}
			}


		// Also ALWAYS check in docs folder for user added images
		if let docsDir = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
			{
			//print (docsDir)
			let studyDir = docsDir.appendingPathComponent("Studies")
			if fileManager.fileExists(atPath: studyDir.path) == false
				{
				return nImages // This means we've never added images from outside the bundle to our app--bail
				}
			let studyName = treeInfo.treeName
			let imagesDir = studyDir.appendingPathComponent(studyName).appendingPathComponent("Images")
			if let fileURLs = try? fileManager.contentsOfDirectory(at: imagesDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
					{
					for fileURL in fileURLs
						{
						let fileNameBase = fileURL.deletingPathExtension().lastPathComponent
						if let node = nodeHash[fileNameBase]
							{
							//print ("\(fileNameBase) exists in tree")
							//node.hasImageFile() = true
							node.imageFileURL = fileURL
							node.imageFileDataLocation = .inDocuments
							nodesWithImagesDict[fileNameBase] = true
							hasImageFiles=true
							}
						else
							{
							//print ("Filebase from docs not found on tree:",fileNameBase)
							}
						}
					nImages = nodesWithImagesDict.keys.count
					}
			}
		return nImages
		}


	func assignLabels(fromMRCAList list:[Dictionary<String, String>])
		{
		for mrca in list
			{
			switch mrca["logic"]!
				{
				case ",": assignMRCALabelNodeBased(as:mrca["cladeName"]!, usingSpecifierA:mrca["specifierA"]!, andB:mrca["specifierB"]!)  // bad news if these optionals are nil
				case "~": assignMRCALabelStemBased(as:mrca["cladeName"]!, usingSpecifierA:mrca["specifierA"]!, andB:mrca["specifierB"]!)  // bad news if these optionals are nil
				default: break
				}
			}
		}
		
	func assignMRCALabelNodeBased(as cladeName:String, usingSpecifierA labelA:String, andB labelB:String)
		{
		// eg bob = species1 , species2;
		var node:Node?
		self.root.setNodeFlags(to: false)
		guard let leafA = nodeHash[labelA] else {print ("Leaf label \(labelA) is not in tree; clade name not assigned"); return }
		guard let leafB = nodeHash[labelB] else {print ("Leaf label \(labelB) is not in tree; clade name not assigned"); return }
		node = leafA
		while node != nil
			{
			node!.nodeFlag=true
			node = node!.parent
			}
		node = leafB
		while node != nil
			{
			if node!.nodeFlag == true
				{
				node!.label = cladeName // NB! I am storing the cladeName as the display label -- really need to go through prepare label stuff!
				hasCladeNames = true
				return
				}
			node = node!.parent
			}
		}

	func assignMRCALabelStemBased(as cladeName:String, usingSpecifierA labelA:String, andB labelB:String)
		// eg bob = species1 ~ species2;
		{
		var node:Node?
		self.root.setNodeFlags(to: false)
		guard let leafA = nodeHash[labelA] else {print ("Leaf label \(labelA) is not in tree; clade name not assigned"); return }
		guard let leafB = nodeHash[labelB] else {print ("Leaf label \(labelB) is not in tree; clade name not assigned"); return }
		node = leafB
		while node != nil
			{
			node!.nodeFlag=true
			node = node!.parent
			}
		node = leafA
		while node!.parent != nil
			{
			if node!.parent!.nodeFlag == true
				{
				node!.label = cladeName // NB! I am storing the cladeName as the display label -- really need to go through prepare label stuff!
				hasCladeNames = true
				return
				}
			node = node!.parent
			}
		}


	func makeClade ()->Node
		{
		let rootNode = Node()
		var currentNode : Node?  // key to make optional, else problems with initialization, blech
		while tokix<tokens.endIndex
			{
			tokix+=1
			tok = tokens[tokix]
			if ( matches(for:nameTokens,in : tok, withOptions:[]).isEmpty) // this is not a name
				{
				switch tok
					{
					case "(":
						currentNode = makeClade()
						rootNode.add(child : currentNode!)
					case ")":
						return rootNode
					default:
						break
					}
				}
			else	// this is a name or a branch length
				{
				switch tokens[tokix-1]
					{
					case ")":
						currentNode!.originalLabel=tok
					case ":":
						currentNode!.length=Float(tok)
					default:
						currentNode = Node(withLabel: tok)
						rootNode.add(child : currentNode!)

					}
				}
			}
		return rootNode
		}



	func printTree()
		{
		//if root != nil
		root.printTree()
		}




}
