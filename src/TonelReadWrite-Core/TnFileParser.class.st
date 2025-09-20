"
Parser for Tonel version 1 files, according to the draft Tonel version 1 format specified at https://github.com:GemTalk/TonelSpec.

Uses the Pika parser (a PEG parser) to do the parsing into an object structure that reflects the structure of the file.
"
Class {
	#name : 'TnFileParser',
	#superclass : 'TnParser',
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

	PackageProperties <- Comment? PackagePropertiesObject;
	ClassProperties <- Comment? classProperties:ClassPropertiesObject;			
	Comment <- "\"" WsNl comment:(!(WsNl "\"" WsNl) .)* WsNl "\"" WsNl;
	
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
	ClassIdentifier <- className:Identifier (WsBlank isMeta:"class")?;
	MessagePattern <- 
		patternAndWhitespace:((KeywordAndArg (Whitespace KeywordAndArg)*
			/ selectorPart:BinarySelector Whitespace arg:Identifier 
			/ selectorPart:Identifier) 
		postPatternWhitespace:TrailingWhitespace?);
	KeywordAndArg <- selectorPart:Keyword Whitespace arg:Identifier;
	Keyword <- Identifier ":";
	BinarySelector <- BinaryCharacter+;
	Identifier <- Letter (Letter / Digit)*;
	BinaryCharacter <- [+/\\*~<>=@%|&?!\-,];
	Letter <- [A-Za-z_];
	Digit <- [0-9];
	Whitespace <- [ \n\t]+;
	TrailingWhitespace <- [ \t]+;
	SmalltalkCode <- (SmalltalkStringLiteral / SmalltalkComment / 
	SmalltalkCharacterLiteral / SmalltalkBlock / OtherSmalltalkCode)*;
	SmalltalkStringLiteral <- "\''''" (!"\''''" .)* "\''''";
	SmalltalkComment <- "\"" ( !"\"" . )* "\"";
	SmalltalkCharacterLiteral <- "$" .;
	SmalltalkBlock <- "[" SmalltalkCode "]";
	OtherSmalltalkCode <- (!("\"" / "\''''" / "$" / "[" / (WsNl "]")) .)+;

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
	WsNl <- "\n" / "\r\n";



'
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> classDefinition: astNode [

	| classDefinition propertiesAst propertiesMap nameEntry superclassEntry methodsAst |
	classDefinition := TnClassDefinition new.
	astNode firstChild label = 'comment'
		ifTrue: [
			propertiesAst := astNode secondChild.
			methodsAst := astNode thirdChild.
			classDefinition comment:
				(self unDoubleCommentQuotesIn: astNode firstChild text) ]
		ifFalse: [
			propertiesAst := astNode firstChild.
			methodsAst := astNode secondChild ].
	propertiesMap := self
		                 mapLabeled: 'classProperties'
		                 fromAst: propertiesAst.
	nameEntry := propertiesMap removeFirst.
	nameEntry key = 'name' ifFalse: [
		self error: 'Expected key oflabel "name," found: ' , nameEntry key ].
	classDefinition name: nameEntry value.
	superclassEntry := propertiesMap removeFirst.
	superclassEntry key = 'superclass' ifFalse: [
		self error:
			'Expected key of "superclass," found: ' , superclassEntry key ].
	classDefinition superclassName: superclassEntry value.
	classDefinition optionalProperties:
		(self dictionaryFromOrderedMap: propertiesMap).
	methodsAst label = 'methods' ifFalse: [
		self error: 'Expected label "methods," found: ' , methodsAst label ].
	methodsAst children do: [ :methodAst |
		classDefinition addMethod: (self visitAstNode: methodAst) ].
	^ classDefinition
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> classProperties: astNode [

	^ self mapFromAst: astNode
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
	tonelVersion value = '1.0' ifFalse: [
		self error: 'Unsupported Tonel version ' , tonelVersion value ].
	contentType key = 'contentType' ifFalse: [
		self error: 'Expected key "contentType," found ' , contentType key ].
	canonicalName key = 'name' ifFalse: [
		self error: 'Expected key "name," found ' , canonicalName key ].
	fileInfo
		tonelVersion: tonelVersion value;
		contentType: contentType value;
		canonicalName: canonicalName value;
		optionalFileInfo: (self dictionaryFromOrderedMap: map).
	^ fileInfo
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

{ #category : 'parsing' }
TnFileParser >> parse: sourceString [

	| astRoot |
	astRoot := self parseToAst: sourceString.

	"for now..."
	^ astRoot
]

{ #category : 'private' }
TnFileParser >> parsePattern: patternString [

	| parser |
	parser := TnMessagePatternParser new.
	^ parser parse: patternString
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> propertiesMethod: astNode [

	| methodDefinition map currentMapEntry currentValue |
	methodDefinition := TnMethodDefinition new.
	map := self mapFromAst: astNode onlyChild.
	map size < 4 ifTrue: [
		self error: 'Expected at least four properties, found only '
			, map size printString ].
	currentMapEntry := map removeFirst.
	currentMapEntry key = 'class' ifFalse: [
		self error: 'Expected key "class," found: ' , currentMapEntry key ].
	methodDefinition definingClass: currentMapEntry value.
	currentMapEntry := map removeFirst.
	currentMapEntry key = 'selector' ifFalse: [
		self error: 'Expected key "selector," found: ' , currentMapEntry key ].
	methodDefinition selector: currentMapEntry value.
	currentMapEntry := map removeFirst.
	currentMapEntry key = 'isMeta' ifFalse: [
		self error: 'Expected key "class," found: ' , currentMapEntry key ].
	currentValue := currentMapEntry value.
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
	methodDefinition source: currentMapEntry value;
		properties: (self dictionaryFromOrderedMap: map).
	^ methodDefinition
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> squareBracketsMethod: astNode [

	| method |
	method := TnMethodDefinition new.
	method
		lineTable: lineTable;
		fileReference: fileReference;
		initializeFromSquareBracketsAst: astNode.
	^ method
]

{ #category : 'private - astNodeLabels' }
TnFileParser >> squareBracketsMethodOld: astNode [

	| methodDefinition propertiesAst classNameAst isMetaAst methodSourceAst |
	methodDefinition := TnMethodDefinition new.
	"squareBracketsNode can have up to four children. isMeta only appears 
	when it's a class method, and the properties are optional."
	propertiesAst := classNameAst := isMetaAst := methodSourceAst := nil. "lint"
	astNode children do: [ :childAst |
		| label |
		label := childAst label.
		label = 'methodProperties'
			ifTrue: [ propertiesAst := childAst ]
			ifFalse: [
				label = 'className'
					ifTrue: [ classNameAst := childAst ]
					ifFalse: [
						label = 'isMeta'
							ifTrue: [ isMetaAst := childAst ]
							ifFalse: [
								label = 'methodSource'
									ifTrue: [ methodSourceAst := childAst ]
									ifFalse: [ self error: 'Unexpected method label: ' , label ] ] ] ] ].
	propertiesAst ifNotNil: [
		methodDefinition properties:
			(self dictionaryFromOrderedMap: (self mapFromAst: propertiesAst)) ].
	methodDefinition definingClass: classNameAst text.
	isMetaAst ifNotNil: [ methodDefinition isMeta: true ].
	methodDefinition
		source: methodSourceAst text;
		selector: (self parsePattern: methodSourceAst onlyChild text).
	^ methodDefinition
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
