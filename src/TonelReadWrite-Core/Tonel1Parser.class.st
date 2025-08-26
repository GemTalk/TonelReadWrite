"
Parser for Tonel version 1 files, according to the draft Tonel version 1 format specified at https://github.com:GemTalk/TonelSpec.

Uses the Pika parser (a PEG parser) to do the parsing into an object structure that reflects the structure of the file.
"
Class {
	#name : 'Tonel1Parser',
	#superclass : 'Object',
	#instVars : [
		'memoTable'
	],
	#classInstVars : [
		'tonelGrammar'
	],
	#category : 'TonelReadWrite-Core',
	#package : 'TonelReadWrite-Core'
}

{ #category : 'initialization' }
Tonel1Parser class >> initializeTonelGrammar [
	"self initializeTonelGrammar"

	^ tonelGrammar := PikaMetaGrammar parse: self tonelGrammarSource
]

{ #category : 'support' }
Tonel1Parser class >> tonelGrammarSource [
	"PEG grammar source code, which gets compiled to an actual Tonel grammar and cached in the 
	tonelGrammar class instance variable.
	This grammar is strict, since it is intended to test the spec and read mostly files that
	are machine-written, not hand-edited. In the future, this may be factored into a strict
	grammar for testing and a permissive grammar for reading and correcting hand-edited files."

	^ '
	TonelFileObject <- "TonelFile" WsBlank Map;
	PackagePropertiesObject <- "Package" WsBlank Map;
	ClassPropertiesObject <- "Class" WsBlank Map;
	TonelClassExtensionObject <- "Extension" WsBlank Map;
	TonelMethodDescriptor <- Map;
	Map <- SingleEntryMap / MultipleEntryMap;
	SingleEntryMap <- "{" WsBlank Association WsBlank "}" WsNl;
	MultipleEntryMap <- "{" WsNl AssociationLines "}" WsNl;
	AssociationLines <- NotLastAssociationLine+ LastAssociationLine;
	NotLastAssociationLine <- WsTab Association "," WsNl;
	LastAssociationLine <- WsTab Association WsNl;
	Association <- SimpleSymbol WsBlank ":" WsBlank (String / List);
	List <- "[" WsNl ListElements WsTab "]" WsNl;
	ListElements <- (ListElement WsNl) / (ListElement "," WsNl ListElements);
	ListElement <- WsTabTab String;
	String <- "\''" StringChars "\''";
	StringChars <- (StringChar / StringEscape)*;
	StringChar <- !"\''" !"\\" .;
	StringEscape <- "\\\\" / "\\\''";
	SimpleSymbol <- "#" SimpleSymbolChar+;
	SimpleSymbolChar <- [A-Z] / [a-z] / [0-9] / "-" / "_" / "." / "/";

	Comment <- "\"" ((!"\"" .) / "\"\"")* "\"" WsNl WsNl;
	
	DescribedSmalltalkMethod <- TonelMethodDescriptor? SquareBracketsMethod?;

	SquareBracketsMethod <- MethodIdentification WsBlank "[" WsNl SmalltalkCode WsNl "]" WsNl;
	MethodIdentification <- ClassIdentifier WsBlank ">>" WsBlank MethodPattern;
	ClassIdentifier <- ClassName (WsBlank "class")?;
	ClassName <- (!Whitespace .)+;
	MethodPattern <- (!(WsBlank "[") .)+;
	SmalltalkCode <- (SmalltalkStringLiteral / SmalltalkComment / SmalltalkCharacterLiteral / SmalltalkBlock / OtherSmalltalkCode)*;
	SmalltalkStringLiteral <- "\''" (!"\''" .)* "\''";
	SmalltalkComment <- "\"" ( !"\"" . )* "\"";
	SmalltalkCharacterLiteral <- "$" .;
	SmalltalkBlock <- "[" SmalltalkCode "]";
	OtherSmalltalkCode <- (!("\"" / "\''" / "$" / "[") .)+;
		
	ClassProperties <- Comment? ClassPropertiesObject;
	PackageProperties <- Comment? PackagePropertiesObject;
	PackagePropertiesFile <- TonelFileObject WsNl PackageProperties;
	ClassDefinitionPropertiesFile <- TonelFileObject WsNl ClassProperties;
	ClassExtensionPropertiesFile <- TonelFileObject WsNl TonelClassExtensionObject;
	TonelMethodFile <- TonelFileObject WsNl DescribedSmalltalkMethod;
	ClassDefinitionFile <- TonelFileObject WsNl ClassDefinition;
	ClassDefinition <- ClassProperties (WsNl SmalltalkMethods)?;
	SmalltalkMethods <- (DescribedSmalltalkMethod WsNl SmalltalkMethods) / DescribedSmalltalkMethod;
	ClassExtensionFile <- TonelFileObject WsNl ClassExtension;
	ClassExtension <- TonelClassExtensionObject WsNl SmalltalkMethods;
	PackageFile <- TonelFileObject WsNl PackageProperties WsNl PackageContents;
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
