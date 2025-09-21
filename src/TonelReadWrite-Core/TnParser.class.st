Class {
	#name : 'TnParser',
	#superclass : 'PikaParser',
	#traits : 'TTnAstTools',
	#classTraits : 'TTnAstTools classTrait',
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
		patternAndWhitespace:(messagePattern:(KeywordAndArg (Whitespace KeywordAndArg)*
			/ selectorPart:BinarySelector Whitespace arg:Identifier 
			/ selectorPart:Identifier) 
		postPatternWhitespace:TrailingWhitespace?);
	KeywordAndArg <- selectorPart:Keyword Whitespace arg:Identifier;
	Keyword <- Identifier ":";
	BinarySelector <- BinaryCharacter+;
	BinaryCharacter <- [+/\\*~<>=@%|&?!\-,];
	Identifier <- Letter (Letter / Digit)*;
	Letter <- [A-Za-z_];
	Digit <- [0-9];

	Whitespace <- [ \n\t]+;
	TrailingWhitespace <- [ \t]+;
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
		dict at: each key put: each value text.
		previousKey := currentKey ].
	^ dict
]
