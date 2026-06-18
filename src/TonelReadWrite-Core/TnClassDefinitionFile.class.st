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

{ #category : 'instance creation' }
TnClassDefinitionFile class >> forClassNamed: nameString [
	"The new instance will be initialized as for a minimal new class file."

	^ self new initializeForClassNamed: nameString
]

{ #category : 'accessing' }
TnClassDefinitionFile >> classDefinition [

	^ classDefinition
]

{ #category : 'accessing' }
TnClassDefinitionFile >> classDefinition: anObject [

	classDefinition := anObject
]

{ #category : 'accessing' }
TnClassDefinitionFile >> classMethods [

	^ classDefinition classMethods
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

{ #category : 'initialization' }
TnClassDefinitionFile >> initializeForClassNamed: className [
	"Initialize enough to be able to write a class file with some default info but no methods."

	fileInfo := TnFileInfo new
						contentType: 'classFile';
						canonicalName: className , '.class.st';
						yourself.
	classDefinition := TnClassDefinition new
		name: className;
		superclassName: 'Object';
		yourself.
]

{ #category : 'accessing' }
TnClassDefinitionFile >> instanceMethods [

	^ classDefinition instanceMethods
]

{ #category : 'writing' }
TnClassDefinitionFile >> writeOn: aStream [

	super writeOn: aStream.
	aStream lf.
	classDefinition writeOn: aStream
]
