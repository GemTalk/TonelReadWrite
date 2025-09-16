Class {
	#name : 'TnMethodDefinition',
	#superclass : 'TnNode',
	#instVars : [
		'definingClass',
		'selector',
		'isMeta',
		'properties',
		'source'
	],
	#category : 'TonelReadWrite-Core-Model',
	#package : 'TonelReadWrite-Core',
	#tag : 'Model'
}

{ #category : 'private' }
TnMethodDefinition >> canBeWrittenAsSquareBracketMethod [

	| parser |
	parser := TnSquareBracketsParser new.
	[ parser parse: source ]
		on: PikaSyntaxError 
		do: [ ^ false ].
	^ true
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
