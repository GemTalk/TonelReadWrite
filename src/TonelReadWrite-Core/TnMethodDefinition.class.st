Class {
	#name : 'TnMethodDefinition',
	#superclass : 'TnNode',
	#traits : 'TTnAstTools',
	#classTraits : 'TTnAstTools classTrait',
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

{ #category : 'private - astNodeLabels' }
TnMethodDefinition >> methodBody: astNode [

	source := source , astNode text
]

{ #category : 'private - astNodeLabels' }
TnMethodDefinition >> methodPropertiesAst: astNode [

	properties := self dictionaryFromOrderedMap:
		              (self mapFromAst: astNode)
]

{ #category : 'private - astNodeLabels' }
TnMethodDefinition >> methodSourceAst: astNode [

	self setSourceLocationOf: self from: astNode.
	astNode children do: [ :childAst | self visitAstNode: childAst ]
]

{ #category : 'private - astNodeLabels' }
TnMethodDefinition >> patternAndWhitespace: astNode [
	"The pattern is the start of the source, but for a squareBracketsMethod, the 
	parser strips out the [ and the newline after it, so to get the source
	offsets right we add here a space (taking the place of the [) and a newline."

	| text sourceStream selectorStream |
	text := astNode text.
	sourceStream := WriteStream on: (String new: text size + 2).
	sourceStream
		<< text;
		space;
		lf.
	source := sourceStream contents.

	selectorStream := WriteStream on: (String new: text size).
	astNode children do: [ :childAst |
		childAst label = 'selectorPart' ifTrue: [
			selectorStream << childAst text ] ].
	selector := selectorStream contents
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

{ #category : 'accessing' }
TnMethodDefinition >> source [

	^ source
]

{ #category : 'accessing' }
TnMethodDefinition >> source: anObject [

	source := anObject
]

{ #category : 'writing' }
TnMethodDefinition >> writeOn: aStream [
	"Write my contents on aStream, in Tonel format."

	self canBeWrittenAsSquareBracketMethod
		ifTrue: [ self writeAsSquareBracketMethodOn: aStream ]
		ifFalse: [ self writeAsPropertiesMethodOn: aStream ]
]
