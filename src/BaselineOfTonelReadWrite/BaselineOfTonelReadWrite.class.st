Class {
	#name : 'BaselineOfTonelReadWrite',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfTonelReadWrite',
	#package : 'BaselineOfTonelReadWrite'
}

{ #category : 'baselines' }
BaselineOfTonelReadWrite >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			package: 'TonelReadWrite-Core' with: [ spec requires: #( 'PikaParser' ) ];
			package: 'TonelReadWrite-Tests' with: [ spec requires: #( 'TonelReadWrite-Core' ) ].
		spec
			group: 'default' with: #( 'Dev' );
			group: 'Dev' with: #( 'Core' 'Tests' );
			group: 'Core' with: #( 'TonelReadWrite-Core' );
			group: 'Tests' with: #( 'TonelReadWrite-Tests' ).
		spec
			baseline: 'PikaParser'
			with: [ spec repository: self pikaUrl ] ]
]

{ #category : 'support' }
BaselineOfTonelReadWrite >> pikaUrl [

	^ self urlForProject: 'PikaParser'
]

{ #category : 'support' }
BaselineOfTonelReadWrite >> urlForProject: projectName [

	| projectsHome path |
	projectsHome := OSEnvironment current
		                at: 'ROWAN_PROJECTS_HOME'
		                ifAbsent: [
			                ^ self error:
				                  'ROWAN_PROJECTS_HOME must be set to find local projects' ].
	path := Path / projectsHome / projectName / 'src'.
	^ path asFileReference exists
		  ifFalse: [ self error: 'Cannot find ' , path ]
		  ifTrue: [ 'gitlocal://' , path pathString ]
]
