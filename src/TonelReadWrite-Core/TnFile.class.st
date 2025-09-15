"
Abstract. Represents a Tonel file.
"
Class {
	#name : 'TnFile',
	#superclass : 'TnNode',
	#instVars : [
		'fileInfo'
	],
	#category : 'TonelReadWrite-Core-Model',
	#package : 'TonelReadWrite-Core',
	#tag : 'Model'
}

{ #category : 'accessing' }
TnFile >> fileInfo [

	^ fileInfo
]

{ #category : 'accessing' }
TnFile >> fileInfo: anObject [

	fileInfo := anObject
]

{ #category : 'writing' }
TnFile >> writeOn: aStream [
	"Write my contents on aStream, in Tonel format."
	
	fileInfo writeOn: aStream
]
