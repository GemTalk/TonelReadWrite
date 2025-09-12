"
Parser for Tonel version 1 files, according to the draft Tonel version 1 format specified at https://github.com:GemTalk/TonelSpec.

Uses the Pika parser (a PEG parser) to do the parsing into an object structure that reflects the structure of the file.
"
Class {
	#name : 'TnParser',
	#superclass : 'PikaParser',
	#category : 'TonelReadWrite-Core-Parser',
	#package : 'TonelReadWrite-Core',
	#tag : 'Parser'
}

{ #category : 'support' }
TnParser class >> grammarSource [
	"self initializeGrammar"

	"PEG grammar source code, which gets compiled to an actual Tonel grammar and cached in the 
	tonelGrammar class instance variable.
	This grammar is strict, since it is intended to test the spec and read mostly files that
	are machine-written, not hand-edited. In the future, this may be factored into a strict
	grammar for testing and a permissive grammar for reading and correcting hand-edited files."

	^ '
	TonelFile <- tonelFile:(TnClassDefinitionFile:ClassDefinitionFile / TnClassExtensionFile:ClassExtensionFile /
		TnPackagePropertiesFile:PackagePropertiesFile / TnClassDefinitionPropertiesFile:ClassDefinitionPropertiesFile /
		TnClassExtensionPropertiesFile:ClassExtensionPropertiesFile / TnMethodFile:TonelMethodFile / TnPackageFile:PackageFile);
	TonelFileObject <- "TonelFile" WsBlank fileInfo:Map;
	PackagePropertiesObject <- "Package" WsBlank packageInfo:Map;
	ClassPropertiesObject <- "Class" WsBlank Map;
	TonelClassExtensionObject <- "Extension" WsBlank classExtension:Map;
	TonelMethodDescriptor <- methodProperties:Map;
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
	SimpleSymbolChar <- [A-Z] / [a-z] / [0-9] / "-" / "_" / "." / "/";

	Comment <- "\"" ((!"\"" .) / "\"\"")* "\"" WsNl;
	
	DescribedSmalltalkMethod <- squareBracketsMethod:(TonelMethodDescriptor? SquareBracketsMethod) / 
		propertiesMethod:PropertiesMethod;

	SquareBracketsMethod <- ClassIdentification WsBlank methodSource:MethodSource WsNl "]" WsNl;
	PropertiesMethod <- "Method " TonelMethodDescriptor;
	ClassIdentification <- ClassIdentifier WsBlank ">>";
	MethodSource <- MethodPattern WsBlank "[" WsNl SmalltalkCode;
	ClassIdentifier <- className:ClassName (WsBlank isMeta:"class")?;
	ClassName <- (!Whitespace .)+;
	MethodPattern <- (!(WsBlank "[") .)+;
	SmalltalkCode <- (SmalltalkStringLiteral / SmalltalkComment / SmalltalkCharacterLiteral / SmalltalkBlock / OtherSmalltalkCode)*;
	SmalltalkStringLiteral <- "\''" (!"\''" .)* "\''";
	SmalltalkComment <- "\"" ( !"\"" . )* "\"";
	SmalltalkCharacterLiteral <- "$" .;
	SmalltalkBlock <- "[" SmalltalkCode "]";
	OtherSmalltalkCode <- (!("\"" / "\''" / "$" / "[" / (WsNl "]")) .)+;
		
	ClassProperties <- Comment? ClassPropertiesObject;
	PackageProperties <- Comment? PackagePropertiesObject;
	PackagePropertiesFile <- TonelFileObject WsNl PackageProperties !.;
	ClassDefinitionPropertiesFile <- TonelFileObject WsNl ClassProperties !.;
	ClassExtensionPropertiesFile <- TonelFileObject WsNl TonelClassExtensionObject !.;
	TonelMethodFile <- TonelFileObject WsNl DescribedSmalltalkMethod !.;
	ClassDefinitionFile <- TonelFileObject WsNl classDefinition:ClassDefinition !.;
	ClassDefinition <- classProperties:ClassProperties (WsNl methods:SmalltalkMethods)?;
	SmalltalkMethods <- (DescribedSmalltalkMethod WsNl SmalltalkMethods) / DescribedSmalltalkMethod;
	ClassExtensionFile <- TonelFileObject WsNl ClassExtension !.;
	ClassExtension <- TonelClassExtensionObject WsNl SmalltalkMethods;
	PackageFile <- TonelFileObject WsNl PackageProperties WsNl PackageContents !.;
	PackageContents <- (ClassDefinitions WsNl ClassExtensions) / ClassDefinitions / ClassExtensions;
	ClassDefinitions <- (ClassDefinition WsNl ClassDefinitions) / ClassDefinition;
	ClassExtensions <- (ClassExtension WsNl ClassExtensions) / ClassExtension;


	WsBlank <- " ";
	WsNl <- "\n" / "\r\n";
	WsTab <- "\t";
	WsTabTab <- WsTab WsTab;
	Whitespace <- (WsBlank / WsTab / WsNl)+; 

	'
]

{ #category : 'private - astNodeLabels' }
TnParser >> classDefinition: astNode [

	| classDefinition propertiesMap nameEntry superclassEntry methodsAst |
	classDefinition := TnClassDefinition new.
	propertiesMap := self
		                 mapLabeled: 'classProperties'
		                 fromAst: astNode firstChild.
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
	methodsAst := astNode secondChild.
	methodsAst label = 'methods' ifFalse: [
		self error: 'Expected label "methods," found: ' , methodsAst label ].
	methodsAst children do: [ :methodAst |
		classDefinition addMethod: (self visitAstNode: methodAst) ].
	^ classDefinition
]

{ #category : 'private - astNodeLabels' }
TnParser >> classProperties: astNode [

	^ self mapFromAst: astNode
]

{ #category : 'private' }
TnParser >> dictionaryFromOrderedMap: map [
	"Map is an OrderedCollection of Associations.
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
		dict add: each.
		previousKey := currentKey ].
	^ dict
]

{ #category : 'private - astNodeLabels' }
TnParser >> fileInfo: astNode [

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
TnParser >> mapFromAst: astNode [
	"astNode is the root of key/value pairs. Answer an OrderedCollection of 
	Associations representing these pairs. Order is preserved for verifying
	ordering in the file."

	| map currentKey |
	map := OrderedCollection new.
	currentKey := nil. "lint"
	astNode children do: [ :child |
		| text |
		text := child text.
		child label = 'key'
			ifTrue: [ currentKey := text ]
			ifFalse: [ map add: currentKey -> text ] ].
	^ map
]

{ #category : 'private' }
TnParser >> mapLabeled: expectedLabel fromAst: astNode [
	"astNode is the root of key/value pairs. Answer an OrderedCollection of 
	Associations representing these pairs. Order is preserved for verifying
	ordering in the file."

	astNode label = expectedLabel ifFalse: [
		self error:
			'Expected label "classProperties," found: ' , astNode label ].
	^ self mapFromAst: astNode
]

{ #category : 'parsing' }
TnParser >> parse: sourceString [

	| astRoot |
	astRoot := self parseToAst: sourceString.

	"for now..."
	^ astRoot
]

{ #category : 'private - astNodeLabels' }
TnParser >> squareBracketsMethod: astNode [

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
	methodDefinition source: methodSourceAst text.
	^ methodDefinition
]

{ #category : 'private' }
TnParser >> syntaxCoverageRules [

	^ #( ClassDefinitionFile DescribedSmalltalkMethod SquareBracketsMethod Map Comment Whitespace )
]

{ #category : 'private - astNodeLabels' }
TnParser >> tonelFile: astNode [

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
		fileNode perform: selector with: node ]
]

{ #category : 'parsing' }
TnParser >> tonelGrammar [

	^ self class tonelGrammar
]
