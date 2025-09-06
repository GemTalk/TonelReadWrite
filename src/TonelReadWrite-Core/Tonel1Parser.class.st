"
Parser for Tonel version 1 files, according to the draft Tonel version 1 format specified at https://github.com:GemTalk/TonelSpec.

Uses the Pika parser (a PEG parser) to do the parsing into an object structure that reflects the structure of the file.
"
Class {
	#name : 'Tonel1Parser',
	#superclass : 'PikaParser',
	#category : 'TonelReadWrite-Core-Parser',
	#package : 'TonelReadWrite-Core',
	#tag : 'Parser'
}

{ #category : 'support' }
Tonel1Parser class >> tonelGrammarSource [
	"PEG grammar source code, which gets compiled to an actual Tonel grammar and cached in the 
	tonelGrammar class instance variable.
	This grammar is strict, since it is intended to test the spec and read mostly files that
	are machine-written, not hand-edited. In the future, this may be factored into a strict
	grammar for testing and a permissive grammar for reading and correcting hand-edited files."

	^ '
	TonelFile <- tonelFile:(classDefinitionFile:ClassDefinitionFile / classExtensionFile:ClassExtensionFile / packagePropertiesFile:PackagePropertiesFile / 
		classDefinitionPropertiesFile:ClassDefinitionPropertiesFile / classExtensionPropertiesFile:ClassExtensionPropertiesFile / 
		tonelMethodFile:TonelMethodFile / packageFile:PackageFile);
	TonelFileObject <- "TonelFile" WsBlank fileInfo:Map;
	PackagePropertiesObject <- "Package" WsBlank packageInfo:Map;
	ClassPropertiesObject <- "Class" WsBlank classDefinition:Map;
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
	
	DescribedSmalltalkMethod <- TonelMethodDescriptor SquareBracketsMethod / TonelMethodDescriptor / SquareBracketsMethod;

	SquareBracketsMethod <- MethodIdentification WsBlank "[" WsNl methodBody:SmalltalkCode WsNl "]" WsNl;
	MethodIdentification <- classIdentifier:ClassIdentifier WsBlank ">>" WsBlank pattern:MethodPattern;
	ClassIdentifier <- ClassName (WsBlank "class")?;
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
	ClassDefinitionFile <- TonelFileObject WsNl ClassDefinition !.;
	ClassDefinition <- ClassProperties (WsNl SmalltalkMethods)?;
	SmalltalkMethods <- (method:DescribedSmalltalkMethod WsNl SmalltalkMethods) / method:DescribedSmalltalkMethod;
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

{ #category : 'parsing' }
Tonel1Parser >> parse: sourceString [

	| astRoot |
	astRoot := self parseToAst: sourceString.

	"for now..."
	^ astRoot
]

{ #category : 'private' }
Tonel1Parser >> syntaxCoverageRules [

	^ #( ClassDefinitionFile DescribedSmalltalkMethod SquareBracketsMethod Map Comment Whitespace )
]

{ #category : 'parsing' }
Tonel1Parser >> tonelGrammar [

	^ self class tonelGrammar
]
