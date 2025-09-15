"
Tests that valid test files can be parsed to a model and re-written from that model without change.
Let's also see how Pharo Tonel handles ""double quotes.""
"
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

	| inputFile inputString parseResult outStream |
	inputFile := self stackClassFile.
	inputString := inputFile contents.
	parseResult := TnParser new parseFile: inputFile.
	self assert: parseResult class identicalTo: TnClassDefinitionFile.
	outStream := WriteStream on: (String new: inputString size).
	parseResult writeOn: outStream.
	self assert: outStream contents equals: inputString
]
