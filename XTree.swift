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


class XTree {

	var tok: String
	var root: Node!		// Only solution I've found to problem of the initializer calling makeClade is to make this an optional
	var tokix: Int=0
	var tokens: [String]
	var nodeArray: [Node]=[]
	var nodeHash: [String:Node] = [:]
	var minY:CGFloat=0.0 // min and max leaf node locations
	var maxY:CGFloat=0.0
	var numDescLvs:UInt!
	var imageCollection:ImageCollection!
	var treeInfo:TreeInfoPackage
	var hasCladeNames:Bool=false

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

		root.prepareLabels()					// This edits labels as requested, copying originallable->label
		root.setEdgeAlphaModifier(haveSeenInternalLabel: root.isLabelPresent()) // works on label, so prepare must be done first
		let mrcaArray = treeInfo.mrcaArray
		//print (mrcaArray)
		assignLabels(fromMRCAList:mrcaArray)
		imageCollection=ImageCollection(forTree:self)
//		imageCollection.setup(withNode:root)


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
