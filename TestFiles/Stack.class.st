TonelFile {
	#tonelVersion : '1.0',
	#contentType : 'classFile',
	#name : 'Stack.class.st',
	#gs_Example : 'This is an optional property'
}

"
I implement a simple ""stack."" #push: adds a new object of any kind on top of the stack. #pop returns the first
""element"" and remove it from the stack. #top answer the first element of the stack without removing it.
"
Class {
	#name : 'Stack',
	#superclass : 'LinkedList',
	#category : 'Collections-Stack'
}

{ #category : 'utilities' }
Stack class >> bogus [
	"Does nothing"
	^ self
]

{ #category : 'removing' }
Stack >> pop [
	"Returns the first element and remove it from the stack."

	^self  removeFirst
]

Stack >> push: anObject [
	"Adds a new object of any kind on top of the stack."
	self addFirst: anObject.
	^ anObject.
]

Method {
	#class : 'Stack',
	#selector : 'top',
	#isMeta : 'false',
	#source : 'top
	"Answer the first element of the stack without removing it."
	<primitive> \'
	{some crazy code in who knows what language with mismatched \\
	braces/square brackets]',
	#category : 'accessing'
}
