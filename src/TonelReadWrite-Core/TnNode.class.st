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

{ #category : 'accessing' }
TnNode >> sourceReference [

	^ sourceReference
]

{ #category : 'accessing' }
TnNode >> sourceReference: anObject [

	sourceReference := anObject
]

{ #category : 'private' }
TnNode >> writeMapEntries: associations on: aStream [

	associations do: [ :each |
		aStream
			lf;
			tab;
			<< '#';
			<< each key;
			space;
			<< ':';
			space;
			<< each value printString;
			<< ',' ]
]

{ #category : 'private' }
TnNode >> writeMapNamed: mapName withRequiredProperties: requiredProperties optionalProperties: optionalPropertiesDict on: aStream [

	| sortedOptionalProperties |
	sortedOptionalProperties := SortedCollection sortUsing:
		                            #key ascending.
	sortedOptionalProperties addAll: optionalPropertiesDict associations.
	aStream
		<< mapName;
		space;
		<< '{'.
	self
		writeMapEntries: requiredProperties on: aStream;
		writeMapEntries: sortedOptionalProperties on: aStream.
	aStream
		skip: -1;
		"Overwrite that last comma"
		lf;
		<< '}';
		lf
]

{ #category : 'writing' }
TnNode >> writeOn: aStream [
	"Write my contents on aStream, in Tonel format."

	self subclassResponsibility
]
