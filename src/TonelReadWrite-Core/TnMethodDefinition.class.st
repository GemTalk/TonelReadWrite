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
