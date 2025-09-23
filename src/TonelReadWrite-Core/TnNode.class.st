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

{ #category : 'private' }
TnNode >> sortAndWriteDictionary: inputDictionary on: aStream [

	| sorted |
	sorted := SortedCollection sortUsing: #key ascending.
	sorted addAll: inputDictionary associations.
	sorted do: [ :each |
		aStream lf.
		each value writeOn: aStream ]
]

{ #category : 'accessing' }
TnNode >> sourceReference [

	^ sourceReference
]

{ #category : 'accessing' }
TnNode >> sourceReference: anObject [

	sourceReference := anObject
]

{ #category : 'as yet unclassified' }
TnNode >> stonEscape: aString on: outStream [

	| inStream |
	inStream := ReadStream on: aString.
	[ inStream atEnd ] whileFalse: [
		| char |
		char := inStream next.
		(char == $' or: [ char == $\ ]) ifTrue: [ outStream << '\' ].
		outStream nextPut: char ]
]

{ #category : 'private' }
TnNode >> writeAssociation: assoc on: aStream [

	aStream
		<< '#';
		<< assoc key;
		<< ' : '''.
	self stonEscape: assoc value on: aStream.
	aStream << ''''
]

{ #category : 'private' }
TnNode >> writeComment: commentString on: outStream [

	| inStream |
	commentString isEmpty ifTrue: [
		self error: 'Empty comment prohibited by spec' ].
	outStream
		<< '"';
		lf.
	inStream := ReadStream on: commentString.
	[ inStream atEnd ] whileFalse: [
		| char |
		char := inStream next.
		char == $" ifTrue: [ outStream nextPut: $" ].
		outStream nextPut: char ].
	outStream
		lf;
		<< '"';
		lf
]

{ #category : 'private' }
TnNode >> writeMap: map on: aStream [
	"Map is anonymous, all entries are optional."

	self
		writeMapNamed: nil
		withRequiredProperties: #(  )
		optionalProperties: map
		on: aStream
]

{ #category : 'private' }
TnNode >> writeMapEntries: associations on: aStream [

	associations do: [ :each |
		aStream
			lf;
			tab.
		self writeAssociation: each on: aStream.
		aStream << ',' ]
]

{ #category : 'private' }
TnNode >> writeMapName: mapName on: aStream [

	mapName ifNil: [ ^ self ].
	aStream
		<< mapName;
		space
]

{ #category : 'private' }
TnNode >> writeMapNamed: mapName withRequiredProperties: requiredProperties optionalProperties: optionalPropertiesDict on: aStream [

	| totalEntries |
	totalEntries := requiredProperties size + optionalPropertiesDict size.
	totalEntries = 0 ifTrue: [ ^ self ].
	self writeMapName: mapName on: aStream.
	requiredProperties size + optionalPropertiesDict size > 1 ifFalse: [
		^ self
			  writeSingleEntryMapWithRequiredProperties: requiredProperties
			  optionalProperties: optionalPropertiesDict
			  on: aStream ].
	self
		writeMultipleEntryMapWithRequiredProperties: requiredProperties
		optionalProperties: optionalPropertiesDict
		on: aStream
]

{ #category : 'private' }
TnNode >> writeMultipleEntryMapWithRequiredProperties: requiredProperties optionalProperties: optionalPropertiesDict on: aStream [

	| sortedOptionalProperties |
	sortedOptionalProperties := SortedCollection sortUsing:
		                            #key ascending.
	sortedOptionalProperties addAll: optionalPropertiesDict associations.
	aStream << '{'.
	self
		writeMapEntries: requiredProperties on: aStream;
		writeMapEntries: sortedOptionalProperties on: aStream.
	aStream
		skip: -1;
		"Overwrite that last comma"lf;
		<< '}';
		lf
]

{ #category : 'writing' }
TnNode >> writeOn: aStream [
	"Write my contents on aStream, in Tonel format."

	self subclassResponsibility
]

{ #category : 'writing' }
TnNode >> writeSingleEntryMapWithRequiredProperties: requiredProperties optionalProperties: optionalPropertiesDict on: aStream [

	| association |
	requiredProperties
		ifEmpty: [
			| props |
			props := optionalPropertiesDict associations.
			self assert: props size = 1.
			association := props first ]
		ifNotEmpty: [
			self assert: optionalPropertiesDict isEmpty.
			self assert: requiredProperties size = 1.
			association := requiredProperties first ].
	aStream << '{ '.
	self writeAssociation: association on: aStream.
	aStream
		<< ' }';
		lf
]
