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
	MethodSource <- messagePattern:(MessagePattern) "[" WsNl SmalltalkCode;
	' , self squareBracketsGrammarSource
]

{ #category : 'private - astNodeLabels' }
TnSquareBracketsParser >> code: astNode [

	^ astNode text
]

{ #category : 'testing' }
TnSquareBracketsParser >> shouldRecordSourceLocations [

	^ false
]

{ #category : 'private' }
TnSquareBracketsParser >> syntaxCoverageRules [
	"This method should answer a collection of rule names that, between them, should cover all input text."

	^ #('start')
]
