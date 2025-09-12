Class {
	#name : 'TnClassDefinition',
	#superclass : 'TnNode',
	#instVars : [
		'superclassName',
		'optionalProperties',
		'instanceMethods',
		'classMethods',
		'name'
	],
	#category : 'TonelReadWrite-Core-Model',
	#package : 'TonelReadWrite-Core',
	#tag : 'Model'
}

{ #category : 'accessing' }
TnClassDefinition >> addMethod: methodDefinition [

	| dict |
	methodDefinition definingClass = name ifFalse: [
		self error: 'Method should belong to class "' , name
			, '," but says it is defined in: ' , methodDefinition definingClass ].
	dict := methodDefinition isMeta
		        ifTrue: [ classMethods ]
		        ifFalse: [ instanceMethods ].
	dict
		at: methodDefinition selector
		ifPresent: [
			self error:
				'Duplicate method selector in class: #'
				, methodDefinition selector ]
		ifAbsentPut: [ methodDefinition ]
]

{ #category : 'accessing' }
TnClassDefinition >> classMethods [

	^ classMethods
]

{ #category : 'accessing' }
TnClassDefinition >> classMethods: anObject [

	classMethods := anObject
]

{ #category : 'initializing' }
TnClassDefinition >> initialize [

	super initialize.
	classMethods := Dictionary new.
	instanceMethods := Dictionary new
]

{ #category : 'accessing' }
TnClassDefinition >> instanceMethods [

	^ instanceMethods
]

{ #category : 'accessing' }
TnClassDefinition >> instanceMethods: anObject [

	instanceMethods := anObject
]

{ #category : 'accessing' }
TnClassDefinition >> name [

	^ name
]

{ #category : 'accessing' }
TnClassDefinition >> name: aString [

	name := aString
]

{ #category : 'accessing' }
TnClassDefinition >> optionalProperties [

	^ optionalProperties
]

{ #category : 'accessing' }
TnClassDefinition >> optionalProperties: anObject [

	optionalProperties := anObject
]

{ #category : 'accessing' }
TnClassDefinition >> superclassName [

	^ superclassName
]

{ #category : 'accessing' }
TnClassDefinition >> superclassName: anObject [

	superclassName := anObject
]
