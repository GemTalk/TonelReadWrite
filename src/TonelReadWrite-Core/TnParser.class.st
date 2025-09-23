Class {
	#name : 'TnParser',
	#superclass : 'PikaParser',
	#category : 'TonelReadWrite-Core-Parser',
	#package : 'TonelReadWrite-Core',
	#tag : 'Parser'
}

{ #category : 'support' }
TnParser class >> methodGrammarSource [
	"For parsing methods to see whether they can be written as SquareBracketsMethods"

	^ '
	MessagePattern <- 
		messagePatternAndWhitespace:((KeywordAndArg (Whitespace KeywordAndArg)*
			/ selectorPart:BinarySelector Whitespace arg:Identifier 
			/ selectorPart:Identifier) 
		SameLineWhitespace?);
	KeywordAndArg <- selectorPart:Keyword Whitespace arg:Identifier;
	Keyword <- Identifier ":";
	BinarySelector <- BinaryCharacter+;
	Identifier <- Letter (Letter / Digit)*;
	BinaryCharacter <- [+/\\*~<>=@%|&?!\-,];
	Letter <- [A-Za-z_];
	Digit <- [0-9];
	Whitespace <- [ \n\t]+;
	SameLineWhitespace <- [ \t]+;
	SmalltalkCode <- (SmalltalkStringLiteral / SmalltalkComment / 
	SmalltalkCharacterLiteral / SmalltalkBlock / OtherSmalltalkCode)*;
	SmalltalkStringLiteral <- "\''" (!"\''" .)* "\''";
	SmalltalkComment <- "\"" ( !"\"" . )* "\"";
	SmalltalkCharacterLiteral <- "$" .;
	SmalltalkBlock <- "[" SmalltalkCode "]";
	OtherSmalltalkCode <- (!("\"" / "\''" / "$" / "[" / (WsNl "]")) .)+;
	WsNl <- "\n" / "\r\n";
'
]
