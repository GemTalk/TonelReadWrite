"
A small parser for extracting selectors out of a method pattern; useful in parsing Tonel files.
"
Class {
	#name : 'TnMessagePatternParser',
	#superclass : 'TnParser',
	#category : 'TonelReadWrite-Core-Parser',
	#package : 'TonelReadWrite-Core',
	#tag : 'Parser'
}

{ #category : 'support' }
TnMessagePatternParser class >> grammarSource [
	"self initializeGrammar"

	^ self messagePatternGrammarSource
]

{ #category : 'private - astNodeLabels' }
TnMessagePatternParser >> binarySelector: astNode [

	^ astNode text
]

{ #category : 'private - astNodeLabels' }
TnMessagePatternParser >> keywords: astNode [

	| result |
	result := ''.
	astNode children do: [ :keywordAst |
		result := result , keywordAst text ].
	^ result
]

{ #category : 'private - astNodeLabels' }
TnMessagePatternParser >> messagePattern: astNode [

	^ self visitAstNode: astNode onlyChild
]

{ #category : 'testing' }
TnMessagePatternParser >> shouldRecordSourceLocations [

	^ false
]

{ #category : 'private' }
TnMessagePatternParser >> syntaxCoverageRules [
	"This method should answer a collection of rule names that, between them, should cover all input text."

	^ #( 'MessagePattern' )
]

{ #category : 'private - astNodeLabels' }
TnMessagePatternParser >> unarySelector: astNode [

	^ astNode text
]
