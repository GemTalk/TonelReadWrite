Class {
	#name : 'TnMethodPatternParserTest',
	#superclass : 'TestCase',
	#instVars : [
		'parser'
	],
	#category : 'TonelReadWrite-Tests',
	#package : 'TonelReadWrite-Tests'
}

{ #category : 'support' }
TnMethodPatternParserTest >> setUp [

	parser := TnMethodPatternParser new
]

{ #category : 'tests' }
TnMethodPatternParserTest >> testBinaryFailure [

	| selectors |
	selectors := #( '#' '$*' '-^' '!@%,<`>?|' ).
	selectors do: [ :selector |
		self should: [ parser parse: selector , ' arg ' ] raise: Error ]
]

{ #category : 'tests' }
TnMethodPatternParserTest >> testBinarySuccess [

	| selectors |
	selectors := #( '*' '-*' '!@%,<>?|' ).
	selectors do: [ :selector |
		| result |
		result := parser parse: selector , ' arg '.
		self assert: result equals: selector ]
]

{ #category : 'tests' }
TnMethodPatternParserTest >> testKeywordSuccess [

	| selectors selector threeSelectors result patternString |
	selectors := #( 'goof:' 'widdershins:' 'L33T:' 'g0urd:' ).
	selector := selectors atRandom.
	result := parser parse: selector , ' arg '.
	self assert: result equals: selector.
	threeSelectors := {
		                  selectors atRandom.
		                  selectors atRandom.
		                  selectors atRandom }.
	patternString := threeSelectors first , ' arg1 '
	                 , threeSelectors second , ' arg2 '
	                 , threeSelectors third , ' arg3 '.
	result := parser parse: patternString.
	self
		assert: result
		equals:
		threeSelectors first , threeSelectors second , threeSelectors third
]

{ #category : 'tests' }
TnMethodPatternParserTest >> testUnaryFailure [

	| selectors |
	selectors := #( '' 6 '6b' '_%' '&2' ).
	selectors do: [ :selector |
		self should: [ parser parse: selector , ' ' ] raise: Error ]
]

{ #category : 'tests' }
TnMethodPatternParserTest >> testUnarySuccess [

	| selectors |
	selectors := #( anIdentifier a b6 _foo _22a ).
	selectors do: [ :selector |
		| result |
		result := parser parse: selector , ' '.
		self assert: result equals: selector ]
]
