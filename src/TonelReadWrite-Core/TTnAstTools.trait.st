Trait {
	#name : 'TTnAstTools',
	#traits : 'TPikaAstTools',
	#classTraits : 'TPikaAstTools classTrait',
	#category : 'TonelReadWrite-Core-Parser',
	#package : 'TonelReadWrite-Core',
	#tag : 'Parser'
}

{ #category : 'private' }
TTnAstTools >> dictionaryFromOrderedMap: map [
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

{ #category : 'private' }
TTnAstTools >> mapFromAst: astNode [
	"astNode is the root of key/value pairs. Answer an OrderedCollection of 
	Associations representing these pairs. Order is preserved for verifying
	ordering in the file."

	| map currentKey |
	map := OrderedCollection new.
	currentKey := nil. "lint"
	astNode children do: [ :child |
		| text |
		text := self unescape: child text.
		child label = 'key'
			ifTrue: [ currentKey := text ]
			ifFalse: [ map add: currentKey -> text ] ].
	^ map
]

{ #category : 'asserting' }
TTnAstTools >> shouldRecordSourceLocations [

	^ true
]

{ #category : 'private' }
TTnAstTools >> unescape: inputString [
	"Answer a copy of the inputString with \' and \\ replaced by ' and \"

	| inStream outStream |
	inStream := ReadStream on: inputString.
	outStream := WriteStream on: (String new: inputString size).
	[ inStream atEnd ] whileFalse: [
		| char |
		char := inStream next.
		char == $\ ifTrue: [ "Handle escape"
			inStream atEnd ifTrue: [
				self error:
					'Incomplete escape sequence at end of string: ' , inputString ].
			char := inStream next.
			(char ~~ $' and: [ char ~~ $\ ]) ifTrue: [
				self error:
					'Unrecognized escape sequence: \' , (String with: char) ] ].
		outStream nextPut: char ].
	^ outStream contents
]
