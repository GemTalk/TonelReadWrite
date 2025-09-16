Class {
	#name : 'TnClassDefinitionFile',
	#superclass : 'TnFile',
	#instVars : [
		'classDefinition'
	],
	#category : 'TonelReadWrite-Core-Model',
	#package : 'TonelReadWrite-Core',
	#tag : 'Model'
}

{ #category : 'accessing' }
TnClassDefinitionFile >> classDefinition [

	^ classDefinition
]

{ #category : 'accessing' }
TnClassDefinitionFile >> classDefinition: anObject [

	classDefinition := anObject
]

{ #category : 'accessing' }
TnClassDefinitionFile >> fileInfo: aFileInfo [

	aFileInfo contentType = 'classFile' ifFalse: [
		self error:
			'A class definition file should have a contentType of "classFile" but found "'
			, aFileInfo contentType , '"' ].
	(aFileInfo canonicalName endsWith: '.class.st') ifFalse: [
		self error:
			'A class definition file''s canonical name should end in ".class.st" but is: '
			, aFileInfo canonicalName ].
	super fileInfo: aFileInfo
]

{ #category : 'writing' }
TnClassDefinitionFile >> writeOn: aStream [

	super writeOn: aStream.
	aStream lf.
	classDefinition writeOn: aStream
]
