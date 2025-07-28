clearinfo

form Read all files from directory
    sentence directory_input_path _Input/
    sentence directory_output_path _Output/
endform

appendInfoLine: "Start ..."

# separator
separator$ = "	"

# tiers
wordTier = 1
phonemeTier = 2

# get wav files from provided directory
Create Strings as file list...  list 'directory_input_path$'*.wav
number_of_files = Get number of strings

# output file
outputPath$ = "'directory_output_path$'normalization_values.txt"
writeFileLine: outputPath$,
	..."speaker", separator$,
	..."phoneme", separator$,
	..."context", separator$,
	..."F1", separator$,
	..."F2", separator$,
	..."F3", separator$,
	..."glF1", separator$,
	..."glF2", separator$,
	..."glF3"

for file_index to number_of_files
	select Strings list
	
	# open .wav and .TextGrid files
	file_sound_name$ = Get string... file_index
    file_name$ = replace$ (file_sound_name$, ".wav", "", 0)
	file_grid_name$ = "'file_name$'.TextGrid"
	Read from file... 'directory_input_path$''file_sound_name$'
	Read from file... 'directory_input_path$''file_grid_name$'

	appendInfoLine: "Working on: 'file_name$'"

    # sound data
    select Sound 'file_name$'
    To Formant (burg)... 0 5 5000 0.025 50

    # grid data
    select TextGrid 'file_name$'
    numberOfWords = Get number of intervals: wordTier
    numberOfPhonemes = Get number of intervals: phonemeTier

    # go through each phoneme
    for phonemeIndex from 1 to numberOfPhonemes
	    # phoneme info
	    phonemeLabel$ = Get label of interval: phonemeTier, phonemeIndex
	    @strip: phonemeLabel$
	    phonemeLabel$ = strip.stripped$

        # check if or unwanted pause and continue
		unwantedPhonemes$ = "a8 e8 o8 i8 u8 g8"
        if phonemeLabel$ <> "" and index (unwantedPhonemes$, phonemeLabel$) == 0
		    phonemeStartTime = Get start time of interval: phonemeTier, phonemeIndex
		    phonemeEndTime = Get end time of interval: phonemeTier, phonemeIndex
		    foundWordInterval = 0

            # find corresponding word
		    for wordIndex from 1 to numberOfWords
                wordLabel$ = Get label of interval: wordTier, wordIndex
	    		@strip: wordLabel$
	    		wordLabel$ = strip.stripped$

                # check if pause and continue
			    if foundWordInterval == 0 and wordLabel$ <> ""
				    wordStartTime = Get start time of interval: wordTier, wordIndex
				    wordEndTime = Get end time of interval: wordTier, wordIndex
        
				    # check if the phoneme falls within the word's time range
				    if phonemeStartTime >= wordStartTime - 0.1 and phonemeEndTime <= wordEndTime + 0.1
					    # find the midpoint.
					    phonemeStartTime = Get start point: phonemeTier, phonemeIndex
					    phonemeEndTime = Get end point: phonemeTier, phonemeIndex
					    duration = phonemeEndTime - phonemeStartTime
					    midpoint = phonemeStartTime + duration / 2
					    outputDuration = duration * 1000

					    # extract formant measurements
					    select Formant 'file_name$'
					    f1 = Get value at time... 1 midpoint Hertz Linear
					    f2 = Get value at time... 2 midpoint Hertz Linear
					    f3 = Get value at time... 3 midpoint Hertz Linear

						# format formant measurements
						f1 = round (f1)
						f2 = round (f2)
						f3 = round (f3)
					
					    foundWordInterval = 1
					    appendFileLine: outputPath$, 
							...file_name$, separator$,
							...phonemeLabel$, separator$,
							...wordLabel$, separator$,
							...f1, separator$,
							...f2, separator$,
							...f3, separator$, separator$, separator$
					    select TextGrid 'file_name$'
				    endif
                endif
            endfor

            # phonemes word has not been found
		    if foundWordInterval == 0
			    appendInfoLine: "Error - no word for: ", phonemeLabel$
		    endif
        endif
    endfor

	# remove temporary objects
	select Sound 'file_name$'
	plus TextGrid 'file_name$'
	plus Formant 'file_name$'
	Remove
endfor

# remove temporary objects - strings
select Strings list
Remove

appendInfoLine: "Finished ..."

procedure strip: .text$
	.length = length(.text$)
	.lIndex = index_regex(.text$, "[^\r\n\t\f\v ]")
	.lStripped$ = right$(.text$, .length - .lIndex + 1)
	.rIndex = index_regex(.lStripped$, "[\r\n\t\f\v ]*$")
	.stripped$ = left$(.lStripped$, .rIndex-1)
endproc