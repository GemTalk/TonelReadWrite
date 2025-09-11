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

{ #category : 'instance creation' }
TnFileInfo class >> fromMap: map [
	"Map is an OrderedCollection of Associations; mandatory keys first."

	| tonelVersion contentType canonicalName instance |
	map size < 3 ifTrue: [ self error: 'Incomplete file information map' ].
	tonelVersion := map removeFirst.
	contentType := map removeFirst.
	canonicalName := map removeFirst.
	tonelVersion key = 'tonelVersion' ifFalse: [
		self error: 'Expected key "tonelVersion," found ' , tonelVersion key ].
	tonelVersion value = '1.0' ifFalse: [
		self error: 'Unsupported Tonel version ' , tonelVersion value ].
	contentType key = 'contentType' ifFalse: [
		self error: 'Expected key "contentType," found ' , contentType key ].
	canonicalName key = 'name' ifFalse: [
		self error: 'Expected key "name," found ' , canonicalName key ].
	instance := self new.
	instance
		tonelVersion: tonelVersion value;
		contentType: contentType value;
		canonicalName: canonicalName value;
		optionalFileInfo: (TnNode dictionaryFromOrderedMap: map).
	^ instance
]

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
