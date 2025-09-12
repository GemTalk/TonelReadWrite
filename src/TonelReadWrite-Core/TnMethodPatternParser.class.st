"
A small parser for extracting selectors out of a method pattern; useful in parsing Tonel files.
"
Class {
	#name : 'TnMethodPatternParser',
	#superclass : 'PikaParser',
	#category : 'TonelReadWrite-Core-Parser',
	#package : 'TonelReadWrite-Core',
	#tag : 'Parser'
}

{ #category : 'support' }
TnMethodPatternParser class >> grammarSource [
	"self initializeGrammar"

	^ '
	MessagePattern <- 
		messagePattern:(unarySelector:Identifier Space 
			/ binarySelector:BinarySelector Space Identifier Space 
			/ keywords:(keyword:Keyword Space Identifier Space)+);
	Keyword <- Identifier ":";
	BinarySelector <- BinaryCharacter+;
	BinaryCharacter <- [+/\\*~<>=@%|&?!\-,];
	Identifier <- Letter (Letter / Digit)*;
	Letter <- [A-Za-z_];
	Digit <- [0-9];
	Space <- " ";
	'
]

{ #category : 'private - astNodeLabels' }
TnMethodPatternParser >> binarySelector: astNode [

	^ astNode text
]

{ #category : 'private - astNodeLabels' }
TnMethodPatternParser >> keywords: astNode [

	| result |
	result := ''.
	astNode children do: [ :keywordAst |
		result := result , keywordAst text ].
	^ result
]

{ #category : 'private - astNodeLabels' }
TnMethodPatternParser >> messagePattern: astNode [

	^ self visitAstNode: astNode onlyChild
]

{ #category : 'testing' }
TnMethodPatternParser >> shouldRecordSourceLocations [

	^ false
]

{ #category : 'private' }
TnMethodPatternParser >> syntaxCoverageRules [
	"This method should answer a collection of rule names that, between them, should cover all input text."

	^ #( 'MessagePattern' )
]

{ #category : 'private - astNodeLabels' }
TnMethodPatternParser >> unarySelector: astNode [

	^ astNode text
]
