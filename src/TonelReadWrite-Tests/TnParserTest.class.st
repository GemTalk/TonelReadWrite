Class {
	#name : 'TnParserTest',
	#superclass : 'TestCase',
	#category : 'TonelReadWrite-Tests',
	#package : 'TonelReadWrite-Tests'
}

{ #category : 'support' }
TnParserTest >> _testFileDirectory [
	"Answer the directory where our test Tonel files reside."

	| repo |
	repo := IceRepository registry
		        detect: [ :each | each name = 'TonelReadWrite' ]
		        ifNone: [ self fail: 'TonelReadWrite repository not found' ].
	^ repo location / 'TestFiles'
]

{ #category : 'support' }
TnParserTest >> stackClassFile [

	^ self _testFileDirectory / 'Stack.class.st'
]

{ #category : 'tests' }
TnParserTest >> testParseStack [

	| parseResult |
	parseResult := TnParser new parseFile: self stackClassFile.
	self halt
]
