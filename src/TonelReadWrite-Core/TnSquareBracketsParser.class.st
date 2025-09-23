Class {
	#name : 'TnSquareBracketsParser',
	#superclass : 'TnParser',
	#category : 'TonelReadWrite-Core-Parser',
	#package : 'TonelReadWrite-Core',
	#tag : 'Parser'
}

{ #category : 'support' }
TnSquareBracketsParser class >> grammarSource [
	"self initializeGrammar"

	^ '
	start <- code:(MethodSource !.);
	MethodSource <- Whitespace? messagePattern:(MessagePattern) methodBody:SmalltalkCode;
	' , self methodGrammarSource
]

{ #category : 'private - astNodeLabels' }
TnSquareBracketsParser >> code: astNode [
	"Answer the method AST"

	^ astNode
]

{ #category : 'private' }
TnSquareBracketsParser >> syntaxCoverageRules [
	"This method should answer a collection of rule names that, between them, should cover all input text."

	^ #('start')
]
