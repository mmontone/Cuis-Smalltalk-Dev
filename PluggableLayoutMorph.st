'From Cuis 5.0 [latest update: #4372] on 4 September 2020 at 8:25:23 pm'!
!classDefinition: #PluggableLayoutMorph category: #'Morphic-Views'!
LayoutMorph subclass: #PluggableLayoutMorph
	instanceVariableNames: 'model'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Morphic-Views'!

!PluggableLayoutMorph methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 17:29:19'!
hasModel
	^true! !

!PluggableLayoutMorph methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 17:29:34'!
model 
	^ model! !

!PluggableLayoutMorph methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 17:29:44'!
model: anObject
	"Set my model and make me me a dependent of the given object."

	model ifNotNil: [model removeActionsWithReceiver: self].
	anObject ifNotNil: [anObject addDependent: self].
	model _ anObject! !

!PluggableLayoutMorph methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 17:29:53'!
releaseCachedState
	"Release cached state of the receiver"

	(model ~~ self and: [model respondsTo: #releaseCachedState]) ifTrue:
		[model releaseCachedState].
	super releaseCachedState! !
