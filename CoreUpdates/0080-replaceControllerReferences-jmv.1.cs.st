'From Squeak3.7 of ''4 September 2004'' [latest update: #5989] on 6 November 2008 at 8:29:29 am'!
	"Install an editor for my paragraph.  This constitutes 'hasFocus'.
	If priorEditor is not nil, then initialize the new editor from its state.
	We may want to rework this so it actually uses the prior editor."

	| stateArray |
	priorEditor ifNotNil: [stateArray := priorEditor stateArray].
	editor := TextEditor new morph: self.
	editor changeParagraph: self paragraph.
	priorEditor ifNotNil: [editor stateArrayPut: stateArray].
	self selectionChanged.
	^editor! !
	"Answer a MethodNode for the argument, sourceStream, that is the root of 
        a parse tree. Parsing is done with respect to the argument, class, to find 
        instance, class, and pool variables; and with respect to the argument, 
        ctxt, to find temporary variables. Errors in parsing are reported to the 
        argument, req, if not nil; otherwise aBlock is evaluated. The argument 
        noPattern is a Boolean that is true if the the sourceStream does not 
        contain a method header (i.e., for DoIts)."

	| methNode repeatNeeded myStream s p |
	myStream := sourceStream.
	
	[repeatNeeded := false.
	p := myStream position.
	s := myStream upToEnd.
	myStream position: p.
	self 
		init: myStream
		notifying: req
		failBlock: [^aBlock value].
	doitFlag := noPattern.
	failBlock := aBlock.
	
	[methNode := self 
				method: noPattern
				context: ctxt
				encoder: (Encoder new 
						init: class
						context: ctxt
						notifying: self)] 
			on: ParserRemovedUnusedTemps
			do: 
				[:ex | 
				repeatNeeded := (requestor isKindOf: TextEditor) not.
				myStream := ReadStream on: requestor text string.
				ex resume].
	repeatNeeded] 
			whileTrue.
	encoder := failBlock := requestor := parseNode := nil.	"break cycles & mitigate refct overflow"
	methNode sourceText: s.
	^methNode! !