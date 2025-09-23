"
Parser for Tonel version 1 files, according to the draft Tonel version 1 format specified at https://github.com:GemTalk/TonelSpec.

Uses the Pika parser (a PEG parser) to do the parsing into an object structure that reflects the structure of the file.
"
Class {
	#name : 'TnFileParser',
	#superclass : 'TnParser',
	#instVars : [
		'currentClass',
		'currentMethod'
	],
	#category : 'TonelReadWrite-Core-Parser',
	#package : 'TonelReadWrite-Core',
	#tag : 'Parser'
}

{ #category : 'support' }
TnFileParser class >> grammarSource [
	"self initializeGrammar"

	"PEG grammar source code, which gets compiled to an actual Tonel grammar and cached in the 
	tonelGrammar class instance variable.
	This grammar is strict, since it is intended to test the spec and read mostly files that
	are machine-written, not hand-edited. In the future, this may be factored into a strict
	grammar for testing and a permissive grammar for reading and correcting hand-edited files."

	^ '
	TonelFile <- tonelFile:(TnClassDefinitionFile:ClassDefinitionFile / TnClassExtensionFile:ClassExtensionFile /
		TnPackagePropertiesFile:PackagePropertiesFile / TnClassDefinitionPropertiesFile:ClassDefinitionPropertiesFile /
		TnClassExtensionPropertiesFile:ClassExtensionPropertiesFile / TnMethodFile:TonelMethodFile / 
		TnPackageFile:PackageFile);
	ClassDefinitionFile <- TonelFileObject WsNl classDefinition:ClassDefinition !.;
	ClassExtensionFile <- TonelFileObject WsNl ClassExtension !.;
	PackagePropertiesFile <- TonelFileObject WsNl PackageProperties !.;
	ClassDefinitionPropertiesFile <- TonelFileObject WsNl ClassProperties !.;
	ClassExtensionPropertiesFile <- TonelFileObject WsNl TonelClassExtensionObject !.;
	TonelMethodFile <- TonelFileObject WsNl DescribedSmalltalkMethod !.;
	PackageFile <- TonelFileObject WsNl PackageProperties WsNl PackageContents !.;

	PackageProperties <- packageComment:Comment? PackagePropertiesObject;
	ClassProperties <- classComment:Comment? classProperties:ClassPropertiesObject;			
	Comment <- "\"" WsNl commentBody:(!(WsNl "\"" WsNl) .)* WsNl "\"" WsNl;
	
	PackageContents <- (ClassDefinitions WsNl ClassExtensions) / ClassDefinitions / ClassExtensions;
	ClassDefinitions <- (ClassDefinition WsNl ClassDefinitions) / ClassDefinition;
	ClassExtensions <- (ClassExtension WsNl ClassExtensions) / ClassExtension;
	ClassDefinition <- ClassProperties (WsNl methods:SmalltalkMethods)?;
	ClassExtension <- TonelClassExtensionObject WsNl SmalltalkMethods;

	SmalltalkMethods <- (DescribedSmalltalkMethod WsNl SmalltalkMethods) / DescribedSmalltalkMethod;
	DescribedSmalltalkMethod <- squareBracketsMethod:SquareBracketsMethod / 
		propertiesMethod:PropertiesMethod;
	PropertiesMethod <- "Method " Map;
	SquareBracketsMethod <- methodProperties:Map? ClassIdentification WsBlank 
		methodSource:SquareBracketsMethodSource WsNl;
	SquareBracketsMethodSource <- MessagePattern "[" WsNl ("]" / methodBody:SmalltalkCode WsNl "]");
	ClassIdentification <- ClassIdentifier WsBlank ">>";
	ClassIdentifier <- definingClass:Identifier (WsBlank isMeta:"class")?;

	TonelFileObject <- "TonelFile" WsBlank fileInfo:Map;
	PackagePropertiesObject <- "Package" WsBlank packageInfo:Map;
	ClassPropertiesObject <- "Class" WsBlank Map;
	TonelClassExtensionObject <- "Extension" WsBlank classExtension:Map;
	Map <- SingleEntryMap / MultipleEntryMap;
	SingleEntryMap <- "{" WsBlank Association WsBlank "}" WsNl;
	MultipleEntryMap <- "{" WsNl AssociationLines "}" WsNl;
	AssociationLines <- NotLastAssociationLine+ LastAssociationLine;
	NotLastAssociationLine <- WsTab Association "," WsNl;
	LastAssociationLine <- WsTab Association WsNl;
	Association <- SimpleSymbol WsBlank ":" WsBlank (String / values:List);
	List <- "[" WsNl ListElements WsTab "]" WsNl;
	ListElements <- (ListElement WsNl) / (ListElement "," WsNl ListElements);
	ListElement <- WsTabTab listElement:String;
	String <- "\''" StringChars "\''";
	StringChars <- value:(StringChar / StringEscape)*;
	StringChar <- !"\''" !"\\" .;
	StringEscape <- "\\\\" / "\\\''";
	SimpleSymbol <- "#" key:SimpleSymbolChar+;
	SimpleSymbolChar <- [A-Za-z0-9\-_./];

	WsTab <- "\t";
	WsTabTab <- WsTab WsTab;
	WsBlank <- " ";
' , self methodGrammarSource
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> classComment: astNode [

	| commentText |
	commentText := self unDoubleCommentQuotesIn: astNode onlyChild text.
	currentClass comment: commentText
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> classDefinition: astNode [

	| classDefinition |
	currentClass := classDefinition := TnClassDefinition new.
	astNode children do: [ :child | self visitAstNode: child ].
	currentClass := nil.
	^ classDefinition
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> classProperties: astNode [

	| propertiesMap nameEntry superclassEntry |
	propertiesMap := self mapLabeled: 'classProperties' fromAst: astNode.
	nameEntry := propertiesMap removeFirst.
	nameEntry key = 'name' ifFalse: [
		self error: 'Expected key oflabel "name," found: ' , nameEntry key ].
	currentClass name: nameEntry value text.
	superclassEntry := propertiesMap removeFirst.
	superclassEntry key = 'superclass' ifFalse: [
		self error:
			'Expected key of "superclass," found: ' , superclassEntry key ].
	currentClass superclassName: superclassEntry value text.
	currentClass optionalProperties:
		(self dictionaryFromOrderedMap: propertiesMap)
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> definingClass: astNode [

	currentMethod definingClass: astNode text
]

{ #category : 'private' }
TnFileParser >> dictionaryFromOrderedMap: map [
	"Map is an OrderedCollection of Associations.
	The key of each Association is the desired key,
	the value is an AST node whose text is the desired value.
	Check its ordering and answer an unordered but otherwise
	equivalent Dictionary"

	| dict previousKey |
	dict := Dictionary new.
	previousKey := ''.
	map do: [ :each |
		| currentKey |
		currentKey := each key.
		currentKey > previousKey ifFalse: [
			self error: 'Keys not in canonical order: "' , currentKey
				, '" is not greater than "' , previousKey , '"' ].
		dict at: currentKey put: (self stonUnescape: each value text).
		previousKey := currentKey ].
	^ dict
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> fileInfo: astNode [

	| map fileInfo tonelVersion contentType canonicalName |
	fileInfo := TnFileInfo new.
	map := self mapFromAst: astNode.
	map size < 3 ifTrue: [ self error: 'Incomplete file information map' ].
	tonelVersion := map removeFirst.
	contentType := map removeFirst.
	canonicalName := map removeFirst.
	tonelVersion key = 'tonelVersion' ifFalse: [
		self error: 'Expected key "tonelVersion," found ' , tonelVersion key ].
	tonelVersion value text = '1.0' ifFalse: [
		self error: 'Unsupported Tonel version ' , tonelVersion value text ].
	contentType key = 'contentType' ifFalse: [
		self error: 'Expected key "contentType," found ' , contentType key ].
	canonicalName key = 'name' ifFalse: [
		self error: 'Expected key "name," found ' , canonicalName key ].
	fileInfo
		tonelVersion: tonelVersion value text;
		contentType: contentType value text;
		canonicalName: canonicalName value text;
		optionalFileInfo: (self dictionaryFromOrderedMap: map).
	^ fileInfo
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> isMeta: astNode [
	"This node is only present if it's a class method."

	currentMethod isMeta: true
]

{ #category : 'private' }
TnFileParser >> mapFromAst: astNode [
	"astNode is the root of key/value pairs. Answer an OrderedCollection of 
	Associations representing the key and the value AST node. 
	Order is preserved for verifying ordering in the file."

	| map currentKey |
	map := OrderedCollection new.
	currentKey := nil. "lint"
	astNode children do: [ :child |
		| text |
		text := child text.
		child label = 'key'
			ifTrue: [ currentKey := text ]
			ifFalse: [ map add: currentKey -> child ] ].
	^ map
]

{ #category : 'private' }
TnFileParser >> mapLabeled: expectedLabel fromAst: astNode [
	"astNode is the root of key/value pairs. Answer an OrderedCollection of 
	Associations representing these pairs. Order is preserved for verifying
	ordering in the file."

	astNode label = expectedLabel ifFalse: [
		self error:
			'Expected label "classProperties," found: ' , astNode label ].
	^ self mapFromAst: astNode
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> messagePatternAndWhitespace: astNode [
	"The pattern is the start of the source, but for a squareBracketsMethod, the 
	parser strips out the [ and the newline after it, so to get the source
	offsets right we add here a space (taking the place of the [) and a newline."

	| text sourceStream selectorStream |
	text := astNode text.
	sourceStream := WriteStream on: (String new: text size + 2).
	sourceStream
		<< text;
		space;
		lf.
	currentMethod addSource: sourceStream contents.

	selectorStream := WriteStream on: (String new: text size).
	astNode children do: [ :childAst |
		childAst label = 'selectorPart' ifTrue: [
			selectorStream << childAst text ] ].
	currentMethod selector: selectorStream contents
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> methodBody: astNode [

	currentMethod addSource: astNode text
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> methodProperties: astNode [

	currentMethod properties:
		(self dictionaryFromOrderedMap: (self mapFromAst: astNode))
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> methodSource: astNode [

	self setSourceLocationOf: currentMethod from: astNode.
	self visitChildrenOf: astNode
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> methods: astNode [

	astNode children do: [ :methodAst |
		currentClass addMethod: (self visitAstNode: methodAst) ]
]

{ #category : 'parsing' }
TnFileParser >> parse: sourceString [

	| astRoot |
	astRoot := self parseToAst: sourceString.

	"for now..."
	^ astRoot
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> propertiesMethod: astNode [

	| methodDefinition map currentMapEntry currentValue |
	methodDefinition := TnMethodDefinition new.
	map := self mapFromAst: astNode.
	map size < 4 ifTrue: [
		self error: 'Expected at least four properties, found only '
			, map size printString ].
	currentMapEntry := map removeFirst.
	currentMapEntry key = 'class' ifFalse: [
		self error: 'Expected key "class," found: ' , currentMapEntry key ].
	methodDefinition definingClass: currentMapEntry value text.
	currentMapEntry := map removeFirst.
	currentMapEntry key = 'selector' ifFalse: [
		self error: 'Expected key "selector," found: ' , currentMapEntry key ].
	methodDefinition selector: currentMapEntry value text.
	currentMapEntry := map removeFirst.
	currentMapEntry key = 'isMeta' ifFalse: [
		self error: 'Expected key "class," found: ' , currentMapEntry key ].
	currentValue := currentMapEntry value text.
	currentValue = 'true'
		ifTrue: [ methodDefinition isMeta: true ]
		ifFalse: [
			currentValue = 'false'
				ifTrue: [ methodDefinition isMeta: false ]
				ifFalse: [
					self error:
						'Expected value of "true" or "false," found: ' , currentValue ] ].
	currentMapEntry := map removeFirst.
	currentMapEntry key = 'source' ifFalse: [
		self error: 'Expected key "source," found: ' , currentMapEntry key ].
	self
		setSourceLocationOf: methodDefinition
		from: currentMapEntry value.
	methodDefinition
		addSource: (self stonUnescape: currentMapEntry value text);
		properties: (self dictionaryFromOrderedMap: map).
	^ methodDefinition
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> squareBracketsMethod: astNode [

	| methodDefinition |
	currentMethod := methodDefinition := TnMethodDefinition new.
	astNode children do: [ :child | self visitAstNode: child ].
	currentMethod := nil.
	^ methodDefinition
]

{ #category : 'private' }
TnFileParser >> stonUnescape: inputString [
	"Answer a copy of the inputString with \' and \\ replaced by ' and \"

	| inStream outStream |
	inStream := ReadStream on: inputString.
	outStream := WriteStream on: (String new: inputString size).
	[ inStream atEnd ] whileFalse: [
		| char |
		char := inStream next.
		char == $\ ifTrue: [ "Handle escape"
			inStream atEnd ifTrue: [
				self error:
					'Incomplete escape sequence at end of string: ' , inputString ].
			char := inStream next.
			(char ~~ $' and: [ char ~~ $\ ]) ifTrue: [
				self error:
					'Unrecognized escape sequence: \' , (String with: char) ] ].
		outStream nextPut: char ].
	^ outStream contents
]

{ #category : 'private' }
TnFileParser >> syntaxCoverageRules [

	^ #( ClassDefinitionFile DescribedSmalltalkMethod SquareBracketsMethod Map Comment Whitespace )
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> tonelFile: astNode [

	| typedAstNode fileClass fileNode |
	typedAstNode := astNode onlyChild.
	fileClass := Smalltalk classNamed: typedAstNode label.
	fileClass ifNil: [
		self error: 'Missing file class ' , typedAstNode label ].
	fileNode := fileClass new.
	typedAstNode children do: [ :childAst |
		| selector node |
		node := self visitAstNode: childAst.
		selector := (childAst label , ':') asSymbol.
		fileNode perform: selector with: node ].
	^ fileNode
]

{ #category : 'parsing' }
TnFileParser >> tonelGrammar [

	^ self class tonelGrammar
]

{ #category : 'private' }
TnFileParser >> unDoubleCommentQuotesIn: commentString [
	"The commentString is assumed to be the product of parsing a Tonel file,
	so any double quotes in the string will appear in pairs. 
	Return a string with each pair of double quotes replaced by a single double quote."

	| inStream outStream emitQuote |
	emitQuote := false.
	inStream := ReadStream on: commentString.
	outStream := WriteStream on: (String new: commentString size).
	[ inStream atEnd not ] whileTrue: [
		| thisChar |
		thisChar := inStream next.
		thisChar ~= $"
			ifTrue: [
				emitQuote
					ifTrue: [
					self error: 'Lone double quote within comment: ' , commentString ]
					ifFalse: [ outStream nextPut: thisChar ] ]
			ifFalse: [
				emitQuote
					ifTrue: [
						emitQuote := false.
						outStream nextPut: $" ]
					ifFalse: [ emitQuote := true ] ] ].
	^ outStream contents
]
