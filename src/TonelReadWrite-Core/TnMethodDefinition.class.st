Class {
	#name : 'TnMethodDefinition',
	#superclass : 'TnNode',
	#instVars : [
		'definingClass',
		'selector',
		'isMeta',
		'source',
		'properties'
	],
	#category : 'TonelReadWrite-Core-Model',
	#package : 'TonelReadWrite-Core',
	#tag : 'Model'
}

{ #category : 'accessing' }
TnMethodDefinition >> addSource: aString [

	source := source , aString
]

{ #category : 'private' }
TnMethodDefinition >> astForSquareBracketsMethod [

	| parser |
	parser := TnSquareBracketsParser new.
	[ ^ parser parse: self source ]
		on: PikaSyntaxError
		do: [ ^ nil ]
]

{ #category : 'accessing' }
TnMethodDefinition >> definingClass [

	^ definingClass
]

{ #category : 'accessing' }
TnMethodDefinition >> definingClass: anObject [

	definingClass := anObject
]

{ #category : 'initializing' }
TnMethodDefinition >> initialize [

	super initialize.
	isMeta := false.
	properties := Dictionary new.
	source := ''
]

{ #category : 'accessing' }
TnMethodDefinition >> isMeta [

	^ isMeta
]

{ #category : 'accessing' }
TnMethodDefinition >> isMeta: anObject [

	isMeta := anObject
]

{ #category : 'accessing' }
TnMethodDefinition >> properties [

	^ properties
]

{ #category : 'accessing' }
TnMethodDefinition >> properties: anObject [

	properties := anObject
]

{ #category : 'accessing' }
TnMethodDefinition >> selector [

	^ selector
]

{ #category : 'accessing' }
TnMethodDefinition >> selector: anObject [

	selector := anObject
]

{ #category : 'accessing' }
TnMethodDefinition >> source [

	^ source
]

{ #category : 'private' }
TnMethodDefinition >> writeAsPropertiesMethodOn: aStream [

	| requiredProperties |
	requiredProperties := {
		                      ('class' -> definingClass).
		                      ('selector' -> selector).
		                      ('isMeta' -> isMeta printString).
		                      ('source' -> source) }.
	self
		writeMapNamed: 'Method'
		withRequiredProperties: requiredProperties
		optionalProperties: properties
		on: aStream
]

{ #category : 'private' }
TnMethodDefinition >> writeAsSquareBracketMethodWithAst: codeAst on: aStream [

	| patternAst bodyAst |
	patternAst := codeAst firstChild.
	bodyAst := codeAst secondChild.

	self writeMap: properties on: aStream.
	aStream << definingClass.
	isMeta ifTrue: [ aStream << ' class' ].
	aStream << ' >> '.
	self writePattern: patternAst on: aStream.
	aStream
		<< '[';
		<< bodyAst text;
		lf;
		<< ']';
		lf
]

{ #category : 'writing' }
TnMethodDefinition >> writeOn: aStream [
	"Write my contents on aStream, in Tonel format."

	| ast |
	ast := self astForSquareBracketsMethod.
	ast
		ifNil: [ self writeAsPropertiesMethodOn: aStream ]
		ifNotNil: [ self writeAsSquareBracketMethodWithAst: ast on: aStream  ]
]

{ #category : 'private' }
TnMethodDefinition >> writePattern: patternAst on: aStream [

	patternAst children do: [ :each |
		aStream
			<< each text;
			space ]
]
