'From Cuis 5.0 [latest update: #4372] on 5 September 2020 at 12:39:04 am'!
!classDefinition: #WindowAreaMorph category: #'Morphic-Views'!
PluggableLayoutMorph subclass: #WindowAreaMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Morphic-Views'!

!WindowAreaMorph methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 17:41:39'!
borderWidth
	^ 0! !

!WindowAreaMorph methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 17:40:05'!
buttonColor

	^Theme current buttonColorFrom: self windowColor! !

!WindowAreaMorph methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 17:49:17'!
defaultButtonPaneHeight
	"Answer the user's preferred default height for new button panes."

	^ Theme current buttonPaneHeight! !

!WindowAreaMorph methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 17:38:32'!
layoutMorph
	^ self! !

!WindowAreaMorph methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 17:49:48'!
setLabel: aString
	"do  nothing"! !

!WindowAreaMorph methodsFor: 'as yet unclassified' stamp: 'MM 9/5/2020 00:38:01'!
textBackgroundColor

	^Theme current paneBackgroundFrom: self widgetsColor! !

!WindowAreaMorph methodsFor: 'as yet unclassified' stamp: 'MM 9/5/2020 00:38:25'!
widgetsColor
	^ Color lightGray! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'WindowAreaMorph class' category: #'Morphic-Views'!
WindowAreaMorph class
	instanceVariableNames: ''!

!WindowAreaMorph class methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 18:04:55'!
editText: aTextModel label: labelString wrap: aBoolean
	| window |
	window _ self newColumn model: aTextModel.
	window setLabel: labelString.
	window layoutMorph
		addMorph: ((TextModelMorph withModel: aTextModel)
			wrapFlag: aBoolean)
		proportionalHeight: 1.
	^ window openInWorld! !

!WindowAreaMorph class methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 17:54:50'!
initialExtent
	^ RealEstateAgent standardWindowExtent! !

!WindowAreaMorph class methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 18:07:33'!
new
	^ self newColumn! !

!WindowAreaMorph class methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 20:21:09'!
on: model

	|  window |
	window _ self new.
	window
		model: model;
		buildMorphicWindow.
	^window! !

!WindowAreaMorph class methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 17:46:10'!
open: model

	^self open: model label: nil! !

!WindowAreaMorph class methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 18:07:19'!
open: model label: aString

	|  window |
	window _ self new.
	window
		model: model;
		buildMorphicWindow.
	aString ifNotNil: [ window setLabel: aString ].
	window openInWorld.
	^window! !
