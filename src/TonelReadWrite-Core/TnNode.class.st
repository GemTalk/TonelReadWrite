Class {
	#name : 'TnNode',
	#superclass : 'Object',
	#instVars : [
		'sourceReference'
	],
	#category : 'TonelReadWrite-Core-Model',
	#package : 'TonelReadWrite-Core',
	#tag : 'Model'
}

{ #category : 'utilities' }
TnNode class >> dictionaryFromOrderedMap: map [
	"Map is an OrderedCollection of Associations.
	Check its ordering and answer an unordered but otherwise
	equivalent Dictionary"

	| dict previousKey |
	dict := Dictionary new.
	previousKey := ''.
	map do: [ :each |
		| currentKey |
		currentKey := each key.
		currentKey > previousKey ifFalse: [
			self error: 'Keys not in canonical order: "' , currentKey
				, '" is not greater than "' , previousKey , '"' ].
		dict add: each.
		previousKey := currentKey ].
	^ dict
]

{ #category : 'accessing' }
TnNode >> sourceReference [

	^ sourceReference
]

{ #category : 'accessing' }
TnNode >> sourceReference: anObject [

	sourceReference := anObject
]
