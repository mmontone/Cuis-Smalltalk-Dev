'From Squeak3.7 of ''4 September 2004'' [latest update: #5989] on 8 December 2008 at 3:11:30 pm'!
	"SystemDictionary initialize"

	| oldList |
	oldList := StartUpList.
	StartUpList := OrderedCollection new.
	"These get processed from the top down..."
	#(
		do: [ :clsName | 
			Smalltalk at: clsName ifPresent: [:cls | Smalltalk addToStartUpList: cls]].
	oldList ifNotNil: [
		oldList do: [ :className | 
	#(
			Smalltalk at: clsName ifPresent: [:cls | Smalltalk addToStartUpList: cls]].
	oldList := ShutDownList.
	ShutDownList := OrderedCollection new.
	"These get processed from the bottom up..."
	#(
		do: [ :clsName | 
			Smalltalk at: clsName ifPresent: [:cls | Smalltalk addToShutDownList: cls]].
	oldList ifNotNil: [
				ifPresent: [:theClass | Smalltalk addToShutDownList: theClass]]]! !