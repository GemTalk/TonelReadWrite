Class {
	#name : 'TnParser',
	#superclass : 'PikaParser',
	#category : 'TonelReadWrite-Core-Parser',
	#package : 'TonelReadWrite-Core',
	#tag : 'Parser'
}

{ #category : 'support' }
TnParser class >> squareBracketsGrammarSource [
	"Just the bit for square-bracket methods, separate since it is also used in writing."

	"The methodPattern AST node includes the trailing blank to simplify the MethodPatternParser."

	^ '
	MethodSource <- methodPattern:(MethodPattern WsBlank) "[" WsNl SmalltalkCode;
	MethodPattern <- (!(WsBlank "[") .)+;
	SmalltalkCode <- (SmalltalkStringLiteral / SmalltalkComment / SmalltalkCharacterLiteral / SmalltalkBlock / OtherSmalltalkCode)*;
	SmalltalkStringLiteral <- "\''" (!"\''" .)* "\''";
	SmalltalkComment <- "\"" ( !"\"" . )* "\"";
	SmalltalkCharacterLiteral <- "$" .;
	SmalltalkBlock <- "[" SmalltalkCode "]";
	OtherSmalltalkCode <- (!("\"" / "\''" / "$" / "[" / (WsNl "]")) .)+;

	WsBlank <- " ";
	WsNl <- "\n" / "\r\n";
	'
]
