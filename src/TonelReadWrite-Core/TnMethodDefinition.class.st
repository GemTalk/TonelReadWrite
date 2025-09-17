Class {
	#name : 'TnMethodDefinition',
	#superclass : 'TnNode',
	#instVars : [
		'definingClass',
		'selector',
		'isMeta',
		'properties',
		'messagePattern',
		'methodBody'
	],
	#category : 'TonelReadWrite-Core-Model',
	#package : 'TonelReadWrite-Core',
	#tag : 'Model'
}

{ #category : 'instance creation' }
TnMethodDefinition class >> fromSquareBracketsAst: squareBracketsAst [

	^ self new initializeFromSquareBracketsAst: squareBracketsAst
]

{ #category : 'private' }
TnMethodDefinition >> canBeWrittenAsSquareBracketMethod [

	| parser |
	parser := TnSquareBracketsParser new.
	[ parser parse: self source ]
		on: PikaSyntaxError 
		do: [ ^ false ].
	^ true
]

{ #category : 'private - astNodeLabels' }
TnMethodDefinition >> classNameAst: astNode [

	definingClass := astNode text
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
]

{ #category : 'parsing' }
TnMethodDefinition >> initializeFromSquareBracketsAst: squareBracketsAst [

	squareBracketsAst children do: [ :childAst |
		self perform: (childAst label , 'Ast:') asSymbol with: childAst ].
	^ self
]

{ #category : 'accessing' }
TnMethodDefinition >> isMeta [

	^ isMeta
]

{ #category : 'accessing' }
TnMethodDefinition >> isMeta: anObject [

	isMeta := anObject
]

{ #category : 'private - astNodeLabels' }
TnMethodDefinition >> isMetaAst: astNode [

	isMeta := true
]

{ #category : 'accessing' }
TnMethodDefinition >> messagePattern [

	^ messagePattern
]

{ #category : 'accessing' }
TnMethodDefinition >> messagePattern: anObject [

	messagePattern := anObject
]

{ #category : 'private - astNodeLabels' }
TnMethodDefinition >> messagePatternAst: astNode [
	"This includes the trailing blank."

	messagePattern := astNode text.
	selector := self selectorFromPatternAst: astNode
]

{ #category : 'accessing' }
TnMethodDefinition >> methodBody [

	^ methodBody
]

{ #category : 'accessing' }
TnMethodDefinition >> methodBody: anObject [

	methodBody := anObject
]

{ #category : 'private - astNodeLabels' }
TnMethodDefinition >> methodBodyAst: astNode [

	methodBody := astNode text
]

{ #category : 'private - astNodeLabels' }
TnMethodDefinition >> methodPropertiesAst: astNode [

	properties := self dictionaryFromOrderedMap:
		              (self mapFromAst: astNode)
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

{ #category : 'private' }
TnMethodDefinition >> selectorFromPatternAst: astNode [

	| stream |
	stream := WriteStream on: (String new: astNode text size).
	astNode children do: [ :child |
		child label = 'selectorPart' ifTrue: [ stream nextPutAll: child text ] ].
	^ stream contents
]

{ #category : 'writing' }
TnMethodDefinition >> writeOn: aStream [
	"Write my contents on aStream, in Tonel format."

	self canBeWrittenAsSquareBracketMethod
		ifTrue: [ self writeAsSquareBracketMethodOn: aStream ]
		ifFalse: [ self writeAsPropertiesMethodOn: aStream ]
]
