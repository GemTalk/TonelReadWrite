Class {
	#name : 'TnFileInfo',
	#superclass : 'TnNode',
	#instVars : [
		'tonelVersion',
		'contentType',
		'optionalFileInfo',
		'canonicalName'
	],
	#category : 'TonelReadWrite-Core-Model',
	#package : 'TonelReadWrite-Core',
	#tag : 'Model'
}

{ #category : 'accessing' }
TnFileInfo >> canonicalName [

	^ canonicalName
]

{ #category : 'accessing' }
TnFileInfo >> canonicalName: anObject [

	canonicalName := anObject
]

{ #category : 'accessing' }
TnFileInfo >> contentType [

	^ contentType
]

{ #category : 'accessing' }
TnFileInfo >> contentType: anObject [

	contentType := anObject
]

{ #category : 'accessing' }
TnFileInfo >> optionalFileInfo [

	^ optionalFileInfo
]

{ #category : 'accessing' }
TnFileInfo >> optionalFileInfo: anObject [

	optionalFileInfo := anObject
]

{ #category : 'accessing' }
TnFileInfo >> tonelVersion [

	^ tonelVersion
]

{ #category : 'accessing' }
TnFileInfo >> tonelVersion: anObject [

	tonelVersion := anObject
]

{ #category : 'writing' }
TnFileInfo >> writeOn: aStream [
	"Write my contents on aStream, in Tonel format."

	self
		writeMapNamed: 'TonelFile'
		withRequiredProperties: {
				('tonelVersion' -> tonelVersion).
				('contentType' -> contentType).
				('name' -> canonicalName) }
		optionalProperties: optionalFileInfo
		on: aStream
]
