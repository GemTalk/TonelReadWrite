Class {
	#name : 'TnParser',
	#superclass : 'PikaParser',
	#category : 'TonelReadWrite-Core-Parser',
	#package : 'TonelReadWrite-Core',
	#tag : 'Parser'
}

{ #category : 'support' }
TnParser class >> messagePatternGrammarSource [
	"This grammar allows loose definitions of whitespace
	so it can parse arbitrary Smalltalk patterns in
	a PropertiesMethod entry in a file."

	^ '
	MessagePattern <- 
		messagePattern:(unarySelector:Identifier Whitespace 
			/ binarySelector:BinarySelector Whitespace arg:Identifier Whitespace 
			/ keywords:(KeywordAndArg (Whitespace KeywordAndArg)*) Whitespace?);
	KeywordAndArg <- keyword:Keyword Whitespace arg:Identifier;
	Keyword <- Identifier ":";
	BinarySelector <- BinaryCharacter+;
	BinaryCharacter <- [+/\\*~<>=@%|&?!\-,];
	Identifier <- Letter (Letter / Digit)*;
	Letter <- [A-Za-z_];
	Digit <- [0-9];

	Whitespace <- [ \n\t]+;

	'
]

{ #category : 'support' }
TnParser class >> squareBracketsGrammarSource [
	"Just the bit for square-bracket methods, separate since it is also used in writing."

	"The methodPattern AST node includes the trailing blank to simplify the MethodPatternParser."

	^ '
	SmalltalkCode <- (SmalltalkStringLiteral / SmalltalkComment / 
		SmalltalkCharacterLiteral / SmalltalkBlock / OtherSmalltalkCode)*;
	SmalltalkStringLiteral <- "\''" (!"\''" .)* "\''";
	SmalltalkComment <- "\"" ( !"\"" . )* "\"";
	SmalltalkCharacterLiteral <- "$" .;
	SmalltalkBlock <- "[" SmalltalkCode "]";
	OtherSmalltalkCode <- (!("\"" / "\''" / "$" / "[" / (WsNl "]")) .)+;

	WsBlank <- " ";
	WsNl <- "\n" / "\r\n";
	' , self messagePatternGrammarSource
]

{ #category : 'private' }
TnParser >> dictionaryFromOrderedMap: map [
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
TnParser >> mapFromAst: astNode [
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

{ #category : 'private' }
TnParser >> unescape: inputString [
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
