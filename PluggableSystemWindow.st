'From Cuis 5.0 [latest update: #4372] on 4 September 2020 at 8:39:05 pm'!
!classDefinition: #PluggableSystemWindow category: #'Morphic-Views'!
PluggableLayoutMorph subclass: #PluggableSystemWindow
	instanceVariableNames: 'labelString adjusters layoutMorph borderWidth'
	classVariableNames: 'TopWindow'
	poolDictionaries: ''
	category: 'Morphic-Views'!
!PluggableSystemWindow commentStamp: 'MM 9/4/2020 20:38:38' prior: 0!
A Pluggable Window wrapper.

Open a rectangle inside a window:

PluggableSystemWindow openOn: RectangleLikeMorph new.

This is an inspector without window:

(InspectorWindow on: (Inspector inspect: 22)) openInWorld.

This is an inspector wrapped in a window:

PluggableSystemWindow openOn: (InspectorWindow on: (Inspector inspect: 22)) label: '22'.

This is the combination of two inspectors side by side:

PluggableSystemWindow openOn: (LayoutMorph newColumn
								addMorph: (InspectorWindow on: (Inspector inspect: 22)) proportionalHeight: 0.5;
								addAdjusterAndMorph: (InspectorWindow on: (Inspector inspect: 33)) proportionalHeight: 0.5;
								yourself) label: 'Two inspectors'!


!PluggableSystemWindow methodsFor: 'GUI building' stamp: 'MM 9/4/2020 17:26:09'!
buttonColor

	^Theme current buttonColorFrom: self windowColor! !

!PluggableSystemWindow methodsFor: 'GUI building' stamp: 'MM 9/4/2020 17:26:09'!
defaultButtonPaneHeight
	"Answer the user's preferred default height for new button panes."

	^ Theme current buttonPaneHeight! !

!PluggableSystemWindow methodsFor: 'GUI building' stamp: 'MM 9/4/2020 17:26:09'!
textBackgroundColor

	^Theme current paneBackgroundFrom: self widgetsColor! !

!PluggableSystemWindow methodsFor: 'GUI building' stamp: 'MM 9/4/2020 17:26:09'!
windowColor
	"Some default"
	^model class windowColor! !


!PluggableSystemWindow methodsFor: 'change reporting' stamp: 'MM 9/4/2020 17:26:09'!
invalidateTitleArea

	"not really pretty... also invalidating the top border, regardless of it being above or below the title area
	(Different themes use various looks, this covers them all)"
	self invalidateLocalRect: (self morphTopLeft extent: extent x @ (self labelHeight + borderWidth))! !


!PluggableSystemWindow methodsFor: 'drawing' stamp: 'MM 9/4/2020 17:26:09'!
addPossiblyUncoveredAreasIn: aRectangle to: aCollection
	"Answer an array of rectangles encompassing those areas in aRectangle not completely
	covered by self. These are the areas that might require further drawing (of morphs below us)
	All areas that might possibly be uncovered must be included."
	 | bounds radious |
	color mightBeTranslucent ifTrue: [
		aCollection add: aRectangle.
		^self ].

	bounds _ self displayBounds.
	bounds ifNil: [
		aCollection add: aRectangle.
		^self ].

	"Solid rectangle.
	This will be the fastest in many cases. So, please disable rounded corners if on slow hardware!!"
	Theme current roundWindowCorners ifFalse: [
		aRectangle areasOutside: bounds do: [ :rect |  aCollection add: rect ].
		^self ].

	"The solid rectangle does not include the corners.
	Report a couple of rows (top and bottom) or columns (left and right) as uncovered areas.
	We could also try to be more careful and answer each rounded corner...
	Right now, report top and bottom rows as uncovered areas"
	radious _ Theme current roundedWindowRadius.
	aRectangle areasOutside: (bounds insetBy: 0@radious) do: [ :rect |  aCollection add: rect ]! !

!PluggableSystemWindow methodsFor: 'drawing' stamp: 'MM 9/4/2020 17:26:09'!
drawClassicFrameOn: aCanvas color: titleColor
	"Window border encompasses title area. No round corners. No title gradient."

	aCanvas fillRectangle: self morphLocalBounds color: color borderWidth: borderWidth borderStyleSymbol: #simple baseColorForBorder: self widgetsColor.

	"A border was drawn at the left, top and right of the title area.
	The look is that the title area is inside the window"
	aCanvas fillRectangle: (borderWidth@borderWidth extent: extent x - (2*borderWidth)@ self labelHeight) color: titleColor! !

!PluggableSystemWindow methodsFor: 'drawing' stamp: 'MM 9/4/2020 17:26:09'!
drawLabelOn: aCanvas

	| x0 y0 f w availableW l |
	f _ Preferences windowTitleFont.
	x0 _  f lineSpacing * 5 + borderWidth.
	y0 _ borderWidth * 6 // 10.
	availableW _ extent x - x0.
	l _ labelString.
	w _ f widthOfString: l.
	[ w > availableW ] whileTrue: [
		l _ l squeezedTo: (1.0 * l size * availableW / w) truncated.
		l isEmpty ifTrue: [ ^self ].
		w _ f widthOfString: l ].
	aCanvas
		drawString: l
		at: x0@y0
		font: f
		color: Theme current windowLabel
		embossed: Theme current embossedTitles! !

!PluggableSystemWindow methodsFor: 'drawing' stamp: 'MM 9/4/2020 17:26:09'!
drawOn: aCanvas

	| titleColor roundCorners |

	titleColor _ self widgetsColor.
	self isTopWindow
		ifTrue: [ titleColor _ titleColor lighter ].

	roundCorners _ Theme current roundWindowCorners.
	roundCorners
		ifTrue: [
			"Round corners. Optional title gradient."
			self drawRoundedFrameOn: aCanvas color: titleColor ]
		ifFalse: [
			"No round corners. No title gradient."
			self drawClassicFrameOn: aCanvas color: titleColor ].
	Theme current minimalWindows
		ifFalse: [
			labelString ifNotNil: [self drawLabelOn: aCanvas]]! !

!PluggableSystemWindow methodsFor: 'drawing' stamp: 'MM 9/4/2020 17:26:09'!
drawRoundedFrameOn: aCanvas color: widgetsColor
	"Title area is not inside window borders"
	| bottomFactor topFactor |
	Theme current useWindowTitleGradient
		ifTrue: [
			topFactor _ Theme current titleGradientTopFactor.
			bottomFactor _ Theme current titleGradientBottomFactor ]
		ifFalse: [
			topFactor _ 1.
			bottomFactor _ 1 ].
	aCanvas
		windowFrame: self morphLocalBounds
		color: widgetsColor * Theme current titleGradientExtraLightness
		radius: Theme current roundedWindowRadius
		border: borderWidth
		labelHeight: self labelHeight + borderWidth
		gradientTop: topFactor
		gradientBottom: bottomFactor
		insideColor: color! !

!PluggableSystemWindow methodsFor: 'drawing' stamp: 'MM 9/4/2020 17:26:09'!
makeMeFullyVisible 

	self world morphExtent > `0@0` ifFalse: [^ self].

	(self morphPosition >= `0@0` and: [ self morphPosition < (self world morphExtent-self morphExtent)]) ifTrue: [
		^ self "OK -- visible"].

	self morphPosition: (RealEstateAgent initialFrameFor: self initialExtent: self morphExtentInWorld world: self world) topLeft! !

!PluggableSystemWindow methodsFor: 'drawing' stamp: 'MM 9/4/2020 17:26:09'!
makeMeVisible 

	self world morphExtent > `0@0` ifFalse: [^ self].

	(self morphPosition >= `0@0` and: [ self morphPosition < (self world morphExtent-self labelHeight)]) ifTrue: [
		^ self "OK -- at least my top left is visible"].

	"window not on screen (probably due to reframe) -- move it now"
	self morphPosition: (RealEstateAgent initialFrameFor: self initialExtent: extent world: self world) topLeft! !

!PluggableSystemWindow methodsFor: 'drawing' stamp: 'MM 9/4/2020 17:26:09'!
visible: aBoolean
	super visible: aBoolean.
	aBoolean ifTrue: [
		self activate ]! !


!PluggableSystemWindow methodsFor: 'events' stamp: 'MM 9/4/2020 17:26:09'!
wantsToBeDroppedInto: aMorph
	"Return true if it's okay to drop the receiver into aMorph"
	^aMorph isWorldMorph or:[Preferences systemWindowEmbedOK]! !


!PluggableSystemWindow methodsFor: 'geometry' stamp: 'MM 9/4/2020 20:12:41'!
borderWidth
	^ borderWidth! !

!PluggableSystemWindow methodsFor: 'geometry' stamp: 'MM 9/4/2020 17:26:09'!
fontPreferenceChanged

	super fontPreferenceChanged.
	self rescaleButtons.
	self model ifNotNil: [ :m | m changed: #actualContents ].
	self redrawNeeded.
! !

!PluggableSystemWindow methodsFor: 'geometry' stamp: 'MM 9/4/2020 17:26:09'!
justDroppedInto: newOwnerMorph event: anEvent

	TopWindow ~~ self ifTrue: [ self activate ].
	^super justDroppedInto: newOwnerMorph event: anEvent! !

!PluggableSystemWindow methodsFor: 'geometry' stamp: 'MM 9/4/2020 20:17:24'!
layoutMorph
	^ layoutMorph! !

!PluggableSystemWindow methodsFor: 'geometry' stamp: 'MM 9/4/2020 17:26:09'!
minimumExtent

	^layoutMorph minimumExtent + (borderWidth * 2) + (0@self labelHeight) max: self titleBarButtonsExtent x * 6 @ 0! !

!PluggableSystemWindow methodsFor: 'geometry' stamp: 'MM 9/4/2020 17:26:09'!
rescaleButtons
	"boxExtent changed.  Update my buttons."
	| buttonPos buttonExtent  buttonDelta|
	buttonExtent := self titleBarButtonsExtent.
	buttonPos _ self labelHeight + borderWidth - buttonExtent // 2 * (1@1).
	buttonDelta _ buttonExtent x *14//10.
	self submorphsReverseDo: [ :aMorph |
		(aMorph is: #PluggableButtonMorph) 
		  ifTrue: [ 
				aMorph morphExtent: buttonExtent. 
				aMorph morphPosition: buttonPos.
				buttonPos _ buttonPos + (buttonDelta@0).
		].
	]! !


!PluggableSystemWindow methodsFor: 'initialization' stamp: 'MM 9/4/2020 17:26:09'!
createCloseButton
	^ (PluggableButtonMorph model: self action: #closeBoxHit)
		icon: Theme current closeIcon;
		iconName: #drawCloseIcon;
		setBalloonText: 'close this window';
		morphExtent: self titleBarButtonsExtent! !

!PluggableSystemWindow methodsFor: 'initialization' stamp: 'MM 9/4/2020 17:26:09'!
createCollapseButton
	^(PluggableButtonMorph model: self action: #collapse)
		icon: Theme current collapseIcon;
		iconName: #drawCollapseIcon;
		setBalloonText: 'collapse this window';
		morphExtent: self titleBarButtonsExtent! !

!PluggableSystemWindow methodsFor: 'initialization' stamp: 'MM 9/4/2020 17:26:09'!
createExpandButton
	^ (PluggableButtonMorph model: self action: #expandBoxHit)
		icon: Theme current expandIcon;
		iconName: #drawExpandIcon;
		setBalloonText: 'expand to full screen';
		morphExtent: self titleBarButtonsExtent! !

!PluggableSystemWindow methodsFor: 'initialization' stamp: 'MM 9/4/2020 17:26:09'!
createMenuButton
	^ (PluggableButtonMorph model: self action: #offerWindowMenu)
		icon: Theme current windowMenuIcon;
		iconName: #drawMenuIcon;
		setBalloonText: 'window menu';
		morphExtent: self titleBarButtonsExtent! !

!PluggableSystemWindow methodsFor: 'initialization' stamp: 'MM 9/4/2020 17:26:09'!
defaultBorderWidth
	"answer the default border width for the receiver"
	^Preferences systemWindowBorderSize! !

!PluggableSystemWindow methodsFor: 'initialization' stamp: 'MM 9/4/2020 17:26:09'!
defaultColor
	"answer the default color/fill style for the receiver"
	^ `Color white`! !

!PluggableSystemWindow methodsFor: 'initialization' stamp: 'MM 9/4/2020 20:19:22'!
initialize: aMorph
	"Initialize a system window. Add label, stripes, etc., if desired"

	labelString ifNil: [ labelString _ 'Untitled Window'].
	borderWidth _ 2.
	
	self initializeLabelArea.
	extent _ `300 @ 200`.
	

	adjusters _ Dictionary new.
	adjusters at: #topAdjuster put: WindowEdgeAdjustingMorph forTop.
	adjusters at: #bottomAdjuster put: WindowEdgeAdjustingMorph forBottom.
	adjusters at: #leftAdjuster put: WindowEdgeAdjustingMorph forLeft.
	adjusters at: #rightAdjuster put: WindowEdgeAdjustingMorph forRight.
	adjusters at: #topLeftAdjuster put: WindowEdgeAdjustingMorph forTopLeft.
	adjusters at: #bottomLeftAdjuster put: WindowEdgeAdjustingMorph forBottomLeft.
	adjusters at: #topRightAdjuster put: WindowEdgeAdjustingMorph forTopRight.
	adjusters at: #bottomRightAdjuster put: WindowEdgeAdjustingMorph forBottomRight.
	adjusters do: [ :m |
		self addMorphFront: m ].

	"by default"
	self beColumn.
	self addMorph: aMorph layoutSpec: LayoutSpec useAll.! !

!PluggableSystemWindow methodsFor: 'initialization' stamp: 'MM 9/4/2020 17:26:09'!
initializeLabelArea
	"Initialize the label area (titlebar) for the window."

	| topLeft spacing |
	topLeft _ (self labelHeight + borderWidth - self titleBarButtonsExtent / 2) ceiling asPoint.
	spacing _ self titleBarButtonsExtent x *14//10.
	self addMorph: self createCloseButton position: topLeft.
	self addMorph: self createCollapseButton position: spacing@0 + topLeft.
	self addMorph: self createExpandButton position: spacing*2@0 + topLeft.
	self addMorph: self createMenuButton position: spacing*3@0 + topLeft! !

!PluggableSystemWindow methodsFor: 'initialization' stamp: 'MM 9/4/2020 17:26:09'!
openInWorld
	"Ensure all widgets have proper colors before opening"
	self widgetsColor: self windowColor.
	super openInWorld! !

!PluggableSystemWindow methodsFor: 'initialization' stamp: 'MM 9/4/2020 17:26:09'!
titleBarButtonsExtent
	"answer the extent to use for close & other title bar buttons. 
	 
	the label height is used to be proportional to the fonts preferences"
	| e |
	Theme current minimalWindows ifTrue: [^`0@0`].
	e _ Preferences windowTitleFont pointSize * 13 // 10.
	^e@e! !


!PluggableSystemWindow methodsFor: 'label' stamp: 'MM 9/4/2020 17:26:09'!
label
	^ labelString! !

!PluggableSystemWindow methodsFor: 'label' stamp: 'MM 9/4/2020 17:26:09'!
labelHeight
	"Answer the height for the window label."
	Theme current minimalWindows ifTrue: [^ 0].
	^ Preferences windowTitleFont lineSpacing+1! !

!PluggableSystemWindow methodsFor: 'label' stamp: 'MM 9/4/2020 17:26:09'!
relabel
	self request: 'New title for this window' initialAnswer: labelString verifying: [:aString| aString notEmpty] do: [:aString| self setLabel: aString]! !

!PluggableSystemWindow methodsFor: 'label' stamp: 'MM 9/4/2020 17:26:09'!
setLabel: aString

	labelString _ aString.
	self invalidateTitleArea! !

!PluggableSystemWindow methodsFor: 'label' stamp: 'MM 9/4/2020 17:26:09'!
update: aSymbol
	super update: aSymbol.
	aSymbol == #relabel
		ifTrue: [ model ifNotNil: [ self setLabel: model labelString ]]! !


!PluggableSystemWindow methodsFor: 'layout' stamp: 'MM 9/4/2020 17:26:09'!
beColumn
	layoutMorph
		ifNotNil: [ layoutMorph beColumn ]
		ifNil: [
			layoutMorph _ LayoutMorph newColumn.
			self addMorphFront: layoutMorph ]! !

!PluggableSystemWindow methodsFor: 'layout' stamp: 'MM 9/4/2020 17:26:09'!
beRow
	layoutMorph
		ifNotNil: [ layoutMorph beRow ]
		ifNil: [
			layoutMorph _ LayoutMorph newRow.
			self addMorphFront: layoutMorph ]! !

!PluggableSystemWindow methodsFor: 'layout' stamp: 'MM 9/4/2020 17:26:09'!
layoutSubmorphs
	"Compute a new layout of submorphs based on the given layout bounds."

	| h thickness w cornerExtent wh ww pos |
	thickness _ self defaultBorderWidth.
	cornerExtent _ thickness * 5.
	ww _ extent x.
	wh _ extent y.
	w _ ww - cornerExtent - cornerExtent.
	h _ wh - cornerExtent - cornerExtent.
	(adjusters at: #topAdjuster) morphPosition: cornerExtent@0 extent: w@thickness.
	(adjusters at: #bottomAdjuster) morphPosition: cornerExtent@(wh-thickness) extent: w@thickness.
	(adjusters at: #leftAdjuster) morphPosition: 0@cornerExtent extent: thickness@h.
	(adjusters at: #rightAdjuster) morphPosition: ww-thickness@cornerExtent extent: thickness@h.
	(adjusters at: #topLeftAdjuster) morphPosition: `0@0` extent: cornerExtent@cornerExtent.
	(adjusters at: #bottomLeftAdjuster) morphPosition: 0@(wh-cornerExtent) extent: cornerExtent@cornerExtent.
	(adjusters at: #topRightAdjuster) morphPosition: ww-cornerExtent@0 extent: cornerExtent@cornerExtent.
	(adjusters at: #bottomRightAdjuster) morphPosition: ww@wh-cornerExtent extent: cornerExtent@cornerExtent.

	layoutMorph ifNotNil: [
		pos _ borderWidth @ (borderWidth + self labelHeight).
		layoutMorph
			morphPosition: pos
			extent: extent - pos - borderWidth ].

	self layoutNeeded: false.! !


!PluggableSystemWindow methodsFor: 'menu' stamp: 'MM 9/4/2020 17:26:09'!
addCustomMenuItems: aCustomMenu hand: aHandMorph
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
"template..."
	aCustomMenu addLine.
	aCustomMenu add: 'edit label...' action: #relabel.
! !

!PluggableSystemWindow methodsFor: 'menu' stamp: 'MM 9/4/2020 17:26:09'!
addTileResizerMenuTo: aMenu
	"We can look at preferences here to decide what too do"
	(Preferences tileResizerInWindowMenu) ifFalse: [
		aMenu add: 'resize full' 		action: #resizeFull icon: #resizeFullIcon;
		add: 'resize top' 				action: #resizeTop icon: #resizeTopIcon;
		add: 'resize left' 				action: #resizeLeft icon: #resizeLeftIcon;
		add: 'resize bottom' 			action: #resizeBottom icon: #resizeBottomIcon;
		add: 'resize right' 				action: #resizeRight icon: #resizeRightIcon;
		add: 'resize top left' 			action: #resizeTopLeft icon: #resizeTopLeftIcon;
		add: 'resize top right' 		action: #resizeTopRight icon: #resizeTopRightIcon;
		add: 'resize bottom left' 		action: #resizeBottomLeft icon: #resizeBottomLeftIcon;
		add: 'resize bottom right' 	action: #resizeBottomRight icon: #resizeBottomRightIcon]
	ifTrue: [ |resizeMorph|
		"Use embedded resize morph"
		resizeMorph _ TileResizeMorph new
							selectionColor: (self widgetsColor adjustSaturation: -0.2 brightness: 0.25) ;
							action: [:resize | |resizeMsg|
								resizeMsg _ ('resize', resize asString capitalized) asSymbol.
								self perform: resizeMsg.
								aMenu delete];
							yourself.
		aMenu addMorphBack: resizeMorph].
	^aMenu.! !

!PluggableSystemWindow methodsFor: 'menu' stamp: 'MM 9/4/2020 17:26:09'!
addWindowControlTo: aMenu

	aMenu
		add: 'send to back' 				action: #sendToBack 				icon: #goBottomIcon;
		add: 'make next-to-topmost' 	action: #makeSecondTopmost 	icon: #goUpIcon;
		addLine;
		add: (self isSticky ifTrue: [ 'make draggable' ] ifFalse: [ 'make undraggable' ])
											action: #toggleStickiness 			icon: (self isSticky ifFalse: [#pushPinIcon]);
		addLine;
		add: 'close' 						action: #delete 						icon: #closeIcon;
		add: 'collapse' 					action: #collapse 					icon: #collapseIcon;
		add: 'expand / contract' 		action: #expandBoxHit 				icon: #expandIcon;
		addLine;
		add: 'resize...' 					action: #resize.
		
	^aMenu! !

!PluggableSystemWindow methodsFor: 'menu' stamp: 'MM 9/4/2020 17:26:09'!
buildWindowMenu

	| aMenu |

	aMenu _ MenuMorph new defaultTarget: self.

	aMenu 
		add: 'change title...' 			action: #relabel 						icon: #saveAsIcon;
		add: 'window color...' 			action: #setWindowColor 			icon: #graphicsIcon.
	
	self hasSaveAs
		ifTrue: [ aMenu add: 'Save as ...' action: #saveContents icon: #saveAsIcon ].
		
	aMenu
		addLine.
		
	self addWindowControlTo: aMenu.
	self addTileResizerMenuTo: aMenu.

	^ aMenu! !

!PluggableSystemWindow methodsFor: 'menu' stamp: 'MM 9/4/2020 17:26:09'!
changeColor
	"Change the color of the receiver -- triggered, e.g. from a menu.  This variant allows the recolor triggered from the window's halo recolor handle to have the same result as choosing change-window-color from the window-title menu"

	"ColorPickerMorph new
		choseModalityFromPreference;
		sourceHand: self world activeHand;
		target: self;
		selector: #setWindowColor:;
		originalColor: self color;
		putUpFor: self near: self morphFullBoundsInWorld"
	self flag: #jmvVer2.
	self showBalloon: 'Interactive color change is currently disabled. Please use #color:'! !

!PluggableSystemWindow methodsFor: 'menu' stamp: 'MM 9/4/2020 17:26:09'!
fullScreen
	"Zoom Window to Full World size with possible DeskMargins"

	"SystemWindow fullScreen"

	| left right possibleBounds |
	(self hasProperty: #originalBounds)
		ifFalse: [ "Expand"
			self setProperty: #originalBounds toValue: self displayBounds.
			left := right := 0.
			possibleBounds := (RealEstateAgent maximumUsableAreaInWorld: self world) 
				insetBy: (left @ 0 corner: right @ 0).
			possibleBounds := possibleBounds insetBy: Theme current fullScreenDeskMargin
		] 
		ifTrue: [ "Contract"
			possibleBounds := self valueOfProperty: #originalBounds.
			self removeProperty: #originalBounds.
		].
	self morphPosition: possibleBounds topLeft extent: possibleBounds extent! !

!PluggableSystemWindow methodsFor: 'menu' stamp: 'MM 9/4/2020 17:26:09'!
makeSecondTopmost
	| thisWorld |
	thisWorld _ self world.
	(SystemWindow noteTopWindowIn: thisWorld but: self)
		ifNotNil: [ :nextWindow |
			thisWorld addMorph: self behind: nextWindow ]! !

!PluggableSystemWindow methodsFor: 'menu' stamp: 'MM 9/4/2020 17:26:09'!
offerWindowMenu

	self buildWindowMenu popUpInWorld: self world! !

!PluggableSystemWindow methodsFor: 'menu' stamp: 'MM 9/4/2020 17:26:09'!
sendToBack
	| thisWorld |
	thisWorld _ self world.
	(SystemWindow noteTopWindowIn: thisWorld but: self)
		ifNotNil: [ :nextWindow |
			thisWorld addMorphBack: self ]! !

!PluggableSystemWindow methodsFor: 'menu' stamp: 'MM 9/4/2020 17:26:09'!
setWindowColor
	"Allow the user to select a new basic color for the window"

	"ColorPickerMorph new
		choseModalityFromPreference;
		sourceHand: self world activeHand;
		target: self;
		selector: #setWindowColor:;
		originalColor: self widgetsColor;
		putUpFor: self near: self morphFullBoundsInWorld"! !

!PluggableSystemWindow methodsFor: 'menu' stamp: 'MM 9/4/2020 17:26:09'!
setWindowColor: incomingColor
	| existingColor aColor |
	incomingColor ifNil: [^ self].  "it happens"
	aColor _ incomingColor asNontranslucentColor.
	aColor = `Color black` ifTrue: [^ self].
	existingColor _ self widgetsColor.
	existingColor ifNil: [^ Smalltalk beep].
	self widgetsColor: aColor.
	self redrawNeeded! !


!PluggableSystemWindow methodsFor: 'open/close' stamp: 'MM 9/4/2020 17:26:09'!
closeBoxHit
	"The user clicked on the close-box control in the window title.  For Mac users only, the Mac convention of option-click-on-close-box is obeyed if the mac option key is down."

	Preferences dismissAllOnOptionClose ifTrue:
		[Sensor rawMacOptionKeyPressed ifTrue:
			[^ self world closeUnchangedWindows]].
	self delete
! !

!PluggableSystemWindow methodsFor: 'open/close' stamp: 'MM 9/4/2020 17:26:09'!
delete
	| thisWorld |
	self okToChange ifFalse: [^self].
	thisWorld _ self world.
	SystemWindow noteTopWindowIn: thisWorld but: self.
	self sendToBack.
	self removeHalo.
	super delete.
	self model: nil! !

!PluggableSystemWindow methodsFor: 'open/close' stamp: 'MM 9/4/2020 17:26:09'!
initialExtent
	^ RealEstateAgent standardWindowExtent! !

!PluggableSystemWindow methodsFor: 'open/close' stamp: 'MM 9/4/2020 17:26:09'!
initialFrameIn: aWorld
	^RealEstateAgent initialFrameFor: self world: aWorld! !

!PluggableSystemWindow methodsFor: 'open/close' stamp: 'MM 9/4/2020 17:26:09'!
openInWorld: aWorld
	"This msg and its callees result in the window being activeOnlyOnTop"
	| frameRect |
	frameRect _ self initialFrameIn: aWorld.
	self morphExtent: frameRect extent.
	aWorld addMorph: self position: frameRect topLeft.
	"Do it deferred. Was needed for text cursor to start blinking if (Preferences disable: #focusFollowsMouse) "
	UISupervisor whenUIinSafeState: [ self activate ]! !


!PluggableSystemWindow methodsFor: 'panes' stamp: 'MM 9/4/2020 17:26:09'!
widgetsColor

	^borderColor! !

!PluggableSystemWindow methodsFor: 'panes' stamp: 'MM 9/4/2020 17:26:09'!
widgetsColor: aColor
	"aColor will be used for titles, borders, etc.
	A variation of it, #paneColorFrom:, will be used for panes background"

	borderColor _ aColor.
	self color: self textBackgroundColor.
	self adoptWidgetsColor: borderColor! !


!PluggableSystemWindow methodsFor: 'printing' stamp: 'MM 9/4/2020 17:26:09'!
printOn: aStream 
	aStream nextPutAll: labelString asString! !


!PluggableSystemWindow methodsFor: 'resize/collapse' stamp: 'MM 9/4/2020 17:26:09'!
expandBoxHit
	"The full screen expand box has been hit"

	self fullScreen! !

!PluggableSystemWindow methodsFor: 'resize/collapse' stamp: 'MM 9/4/2020 17:26:09'!
resize
	| resizeMorph |
	resizeMorph _ ResizeMorph new morphExtent: `200@150`.
	resizeMorph action: [self resize: (resizeMorph selectionRectangle: Display extent)].
	resizeMorph morphPosition: self world activeHand morphPosition.
	resizeMorph openInWorld! !

!PluggableSystemWindow methodsFor: 'resize/collapse' stamp: 'MM 9/4/2020 17:26:09'!
resize: boundingBox
	(self hasProperty: #originalBounds) ifFalse: [
		self setProperty: #originalBounds toValue: self displayBounds].
	self morphPosition: boundingBox origin extent: boundingBox extent! !

!PluggableSystemWindow methodsFor: 'resize/collapse' stamp: 'MM 9/4/2020 17:26:09'!
resizeBottom
	self resize: (Display boundingBox top: Display height // 2)! !

!PluggableSystemWindow methodsFor: 'resize/collapse' stamp: 'MM 9/4/2020 17:26:09'!
resizeBottomLeft
	self resize: (Display boundingBox leftCenter corner: Display boundingBox bottomCenter)! !

!PluggableSystemWindow methodsFor: 'resize/collapse' stamp: 'MM 9/4/2020 17:26:09'!
resizeBottomRight
	self resize: (Display boundingBox center corner: Display boundingBox corner)! !

!PluggableSystemWindow methodsFor: 'resize/collapse' stamp: 'MM 9/4/2020 17:26:09'!
resizeFull
	self resize: Display boundingBox! !

!PluggableSystemWindow methodsFor: 'resize/collapse' stamp: 'MM 9/4/2020 17:26:09'!
resizeLeft
	self resize: (Display boundingBox right: Display width // 2)! !

!PluggableSystemWindow methodsFor: 'resize/collapse' stamp: 'MM 9/4/2020 17:26:09'!
resizeRight
	self resize: (Display boundingBox left: Display width // 2)! !

!PluggableSystemWindow methodsFor: 'resize/collapse' stamp: 'MM 9/4/2020 17:26:09'!
resizeTop
	self resize: (Display boundingBox bottom: Display height // 2)! !

!PluggableSystemWindow methodsFor: 'resize/collapse' stamp: 'MM 9/4/2020 17:26:09'!
resizeTopLeft
	self resize: (Display boundingBox origin corner: Display boundingBox center)! !

!PluggableSystemWindow methodsFor: 'resize/collapse' stamp: 'MM 9/4/2020 17:26:09'!
resizeTopRight
	self resize: (Display boundingBox topCenter corner: Display boundingBox rightCenter)! !


!PluggableSystemWindow methodsFor: 'resizing' stamp: 'MM 9/4/2020 17:26:09'!
windowBottom: aNumber
	"aNumber is an Y coordinate in the owner's coordinate system"

	self morphHeight: aNumber - self morphPosition y! !

!PluggableSystemWindow methodsFor: 'resizing' stamp: 'MM 9/4/2020 17:26:09'!
windowBottomLeft: aPoint
	"aPoint is an X@Y coordinate pair in the owner's coordinate system"

	| e newP p |
	p _ self morphPosition.
	newP _ aPoint x @ p y.
	e _ extent x + p x - aPoint x @ (aPoint y - self morphPosition y).
	self morphPosition: newP extent: e! !

!PluggableSystemWindow methodsFor: 'resizing' stamp: 'MM 9/4/2020 17:26:09'!
windowBottomRight: aPoint
	"aPoint is an X@Y coordinate pair in the owner's coordinate system"

	self morphExtent: aPoint - self morphPosition! !

!PluggableSystemWindow methodsFor: 'resizing' stamp: 'MM 9/4/2020 17:26:09'!
windowLeft: aNumber
	"aNumber is an X coordinate in the owner's coordinate system"

	| e newP p |
	p _ self morphPosition.
	newP _ aNumber @ p y.
	e _ extent x + p x - aNumber @ extent y.
	self morphPosition: newP extent: e! !

!PluggableSystemWindow methodsFor: 'resizing' stamp: 'MM 9/4/2020 17:26:09'!
windowRight: aNumber
	"aNumber is an X coordinate in the owner's coordinate system"

	self morphWidth: aNumber - self morphPosition x! !

!PluggableSystemWindow methodsFor: 'resizing' stamp: 'MM 9/4/2020 17:26:09'!
windowTop: aNumber
	"aNumber is an X coordinate in the owner's coordinate system"

	| e newP p |
	p _ self morphPosition.
	newP _ p x @ aNumber.
	e _ extent x @ (extent y + p y - aNumber).
	self morphPosition: newP extent: e! !

!PluggableSystemWindow methodsFor: 'resizing' stamp: 'MM 9/4/2020 17:26:09'!
windowTopLeft: newPosition
	"aPoint is an X@Y coordinate pair in the owner's coordinate system"

	| e |
	e _ extent + self morphPosition - newPosition.
	self morphPosition: newPosition extent: e! !

!PluggableSystemWindow methodsFor: 'resizing' stamp: 'MM 9/4/2020 17:26:09'!
windowTopRight: aPoint
	"aPoint is an X@Y coordinate pair in the owner's coordinate system"

	| e newP p |
	p _ self morphPosition.
	newP _ p x @ aPoint y.
	e _ (aPoint x - self morphPosition x) @ (extent y + p y - aPoint y).
	self morphPosition: newP extent: e! !


!PluggableSystemWindow methodsFor: 'stepping' stamp: 'MM 9/4/2020 17:26:09'!
stepAt: millisecondSinceLast
	"If the receiver is not collapsed, step it, after first stepping the model."

	(self isCollapsed not or: [ self wantsStepsWhenCollapsed ]) ifTrue: [
		model ifNotNil: [ model stepAt: millisecondSinceLast ].
		super stepAt: millisecondSinceLast ]! !

!PluggableSystemWindow methodsFor: 'stepping' stamp: 'MM 9/4/2020 17:26:09'!
stepTime
	^ 200 "milliseconds"! !

!PluggableSystemWindow methodsFor: 'stepping' stamp: 'MM 9/4/2020 17:26:09'!
wantsSteps
	"Return true if the model wants its view to be stepped.  For an open system window, we give the model to offer an opinion"

	^ model wantsSteps! !

!PluggableSystemWindow methodsFor: 'stepping' stamp: 'MM 9/4/2020 17:26:09'!
wantsStepsWhenCollapsed
	"Default is not to bother updating collapsed windows"

	^ false! !


!PluggableSystemWindow methodsFor: 'structure' stamp: 'MM 9/4/2020 17:26:09'!
owningWindow
	"Return the first enclosing morph that is a kind of Window, or nil if none"

	^ self! !



!PluggableSystemWindow methodsFor: 'testing' stamp: 'MM 9/4/2020 17:26:09'!
is: aSymbol
	^ aSymbol == #SystemWindow or: [ super is: aSymbol ]! !


!PluggableSystemWindow methodsFor: 'top window' stamp: 'MM 9/4/2020 17:26:09'!
activate
	"Bring me to the front and make me able to respond to mouse and keyboard"

	self activateAndSendTopToBack: false! !

!PluggableSystemWindow methodsFor: 'top window' stamp: 'MM 9/4/2020 17:26:09'!
activateAndForceLabelToShow
	self activate.
	self morphPosition y < 0 ifTrue: [
		self morphPosition: (self morphPosition x @ 0)]! !

!PluggableSystemWindow methodsFor: 'top window' stamp: 'MM 9/4/2020 17:26:09'!
activateAndSendTopToBack: aBoolean
	"Bring me to the front and make me able to respond to mouse and keyboard"

	| oldTop |
	owner 
		ifNil: [^self	"avoid spurious activate when drop in trash"].
	
	self isTopWindow ifTrue: [
		self comeToFront.
		^self ].

	oldTop _ TopWindow.
	TopWindow _ self.
	self redrawNeeded.

	oldTop ifNotNil: [
		oldTop redrawNeeded.
		aBoolean ifTrue: [
			| bottomWindow |
			bottomWindow _ oldTop owner submorphs reverse detect: [:one | one is: #SystemWindow].
			oldTop owner addMorph: oldTop behind: bottomWindow]].

	self comeToFront.

	"Set keyboard focus"
	self world ifNotNil: [ :w |
		w activeHand newKeyboardFocus: self submorphToFocusKeyboard ]! !

!PluggableSystemWindow methodsFor: 'top window' stamp: 'MM 9/4/2020 17:26:09'!
isTopWindow

	^ self == TopWindow! !

!PluggableSystemWindow methodsFor: 'top window' stamp: 'MM 9/4/2020 17:26:09'!
submorphToFocusKeyboard

	"Might answer nil"
	^self nextMorphThat: [ :m |  m handlesKeyboard and: [ m isReallyVisible ]]! !


!PluggableSystemWindow methodsFor: 'user interface' stamp: 'MM 9/4/2020 17:26:09'!
canDiscardEditsOf: aMorphWithChanges 

	| okToLooseChanges |
	
	aMorphWithChanges canDiscardEdits ifTrue: [ ^true ].
	
	okToLooseChanges _ self isItOkToLooseChanges.
	okToLooseChanges ifTrue: [ aMorphWithChanges disregardUnacceptedEdits ].
	
	^okToLooseChanges

		! !

!PluggableSystemWindow methodsFor: 'user interface' stamp: 'MM 9/4/2020 17:26:09'!
hasSaveAs
	"Returns true if the window has a model which can be saved to a file"
	^model is: #canSaveContents! !

!PluggableSystemWindow methodsFor: 'user interface' stamp: 'MM 9/4/2020 17:26:09'!
isItOkToLooseChanges
	
	^ self confirm:
'Changes have not been saved.
Is it OK to cancel those changes?'.! !

!PluggableSystemWindow methodsFor: 'user interface' stamp: 'MM 9/4/2020 17:26:09'!
notifyUserWith: message
	"Notifies the user with a message and an 'ok' button"
	| morph |
	morph _ MenuMorph new.
	morph addTitle: message.
	morph add: 'Ok' action: nil.
	morph openInWorld.! !

!PluggableSystemWindow methodsFor: 'user interface' stamp: 'MM 9/4/2020 17:26:09'!
okToChange

	^self canDiscardEditsOf: self! !

!PluggableSystemWindow methodsFor: 'user interface' stamp: 'MM 9/4/2020 17:26:09'!
okToChangeDueTo: aMorph
	
	^self okToChange! !

!PluggableSystemWindow methodsFor: 'user interface' stamp: 'MM 9/4/2020 17:26:09'!
saveContents
	"Prompts the user for a file name and saves the contents to the file"
	self hasSaveAs ifFalse: [^self].
	self request: 'Enter file name' initialAnswer: '' verifying: [:aString| aString notEmpty] do: [:fileName| self saveContentsTo: fileName]! !

!PluggableSystemWindow methodsFor: 'user interface' stamp: 'MM 9/4/2020 17:26:09'!
saveContentsTo: fileName
	"Saves the contents to the given filename"
	| stream |
	self hasSaveAs ifFalse: [^self].
	
	stream _ StandardFileStream new.
	stream open: fileName forWrite: true.
	
	model saveOn: stream as: 'text/plain'.
	
	stream closed ifFalse: [stream close].
	self notifyUserWith: 'Contents saved'.! !


!PluggableSystemWindow methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 20:18:16'!
addMorph: aMorph 
	"Add a submorph to our client area."

	layoutMorph addMorph: aMorph! !

!PluggableSystemWindow methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 20:18:41'!
addMorph: aMorph layoutSpec: aLayoutSpec
	"Add a submorph to our client area."

	layoutMorph addMorph: aMorph layoutSpec: aLayoutSpec! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'PluggableSystemWindow class' category: #'Morphic-Views'!
PluggableSystemWindow class
	instanceVariableNames: ''!

!PluggableSystemWindow class methodsFor: 'top window' stamp: 'MM 9/4/2020 17:26:09'!
closeTopWindow
	"Try to close the top window.  It may of course decline"

	TopWindow ifNotNil:
		[TopWindow delete]! !

!PluggableSystemWindow class methodsFor: 'top window' stamp: 'MM 9/4/2020 17:26:09'!
noteTopWindowIn: aWorld but: aWindow
	| newTop |
	"TopWindow must be nil or point to the top window in this project."
	TopWindow _ nil.
	aWorld ifNil: [^ nil].
	newTop := aWorld submorphs 
				detect: [:m | (m is: #SystemWindow) and: [m visible and: [m ~~ aWindow]]]
				ifNone: [^nil].
	newTop activate.
	^newTop! !

!PluggableSystemWindow class methodsFor: 'top window' stamp: 'MM 9/4/2020 17:26:09'!
releaseClassCachedState
	TopWindow _ nil! !

!PluggableSystemWindow class methodsFor: 'top window' stamp: 'MM 9/4/2020 17:26:09'!
sendTopWindowToBack
	"Send the top window of the world to the back, activating the one just beneath it"

	TopWindow ifNotNil:
		[TopWindow sendToBack]! !

!PluggableSystemWindow class methodsFor: 'top window' stamp: 'MM 9/4/2020 17:26:09'!
topWindow

	^TopWindow! !

!PluggableSystemWindow class methodsFor: 'top window' stamp: 'MM 9/4/2020 17:26:09'!
windowsIn: aWorld satisfying: windowBlock
	| windows |
	windows _ OrderedCollection new.
	aWorld submorphs do: [ :m |
		((m is: #SystemWindow) and: [ windowBlock value: m ]) ifTrue: [ windows addLast: m ]].
	^ windows! !


!PluggableSystemWindow class methodsFor: 'instance creation' stamp: 'MM 9/4/2020 17:26:09'!
editText: aTextModel label: labelString wrap: aBoolean
	| window |
	window _ self new model: aTextModel.
	window setLabel: labelString.
	window layoutMorph
		addMorph: ((TextModelMorph withModel: aTextModel)
			wrapFlag: aBoolean)
		proportionalHeight: 1.
	^ window openInWorld! !

!PluggableSystemWindow class methodsFor: 'instance creation' stamp: 'MM 9/4/2020 17:26:09'!
open: model

	^self open: model label: nil! !

!PluggableSystemWindow class methodsFor: 'instance creation' stamp: 'MM 9/4/2020 17:26:09'!
open: model label: aString

	|  window |
	window _ self new.
	window
		model: model;
		buildMorphicWindow.
	aString ifNotNil: [ window setLabel: aString ].
	window openInWorld.
	^window! !

!PluggableSystemWindow class methodsFor: 'instance creation' stamp: 'MM 9/4/2020 20:02:55'!
openOn: aMorph

	^self openOn: aMorph label: nil! !

!PluggableSystemWindow class methodsFor: 'instance creation' stamp: 'MM 9/4/2020 20:11:19'!
openOn: aMorph label: aString

	|  window |
	window _ self new initialize: aMorph.
	aString ifNotNil: [ window setLabel: aString ].
	window openInWorld.
	^window! !


!PluggableSystemWindow class methodsFor: 'as yet unclassified' stamp: 'MM 9/4/2020 20:08:09'!
new
	^ self newColumn! !
