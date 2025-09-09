Class {
	#name : 'Tonel1ParserTest',
	#superclass : 'TestCase',
	#category : 'TonelReadWrite-Tests',
	#package : 'TonelReadWrite-Tests'
}

{ #category : 'support' }
Tonel1ParserTest >> _testFileDirectory [
	"Answer the directory where our test Tonel files reside."

	| repo |
	repo := IceRepository registry
		        detect: [ :each | each name = 'TonelReadWrite' ]
		        ifNone: [ self fail: 'TonelReadWrite repository not found' ].
	^ repo location / 'TestFiles'
]

{ #category : 'support' }
Tonel1ParserTest >> stackClassFile [

	^ self _testFileDirectory / 'Stack.class.st'
]

{ #category : 'tests' }
Tonel1ParserTest >> testParseStack [

	| parseResult |
	parseResult := Tonel1Parser new parseFile: self stackClassFile.
	self halt
]
