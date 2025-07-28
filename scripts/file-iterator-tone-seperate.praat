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
    To Pitch... 0.01 75 300

    # grid data
    select TextGrid 'file_name$'
    numberOfWords = Get number of intervals: wordTier
    numberOfPhonemes = Get number of intervals: phonemeTier

    # output file
    outputPath$ = "'directory_output_path$''file_name$'_pitch.txt"
    writeFileLine: outputPath$,
		..."speaker", separator$,
		..."word", separator$,
		..."phoneme", separator$,
		..."duration (ms)", separator$,
		..."p0", separator$,
		..."p10", separator$,
		..."p20", separator$,
		..."p30", separator$,
		..."p40", separator$,
		..."p50", separator$,
		..."p60", separator$,
		..."p70", separator$,
		..."p80", separator$,
		..."p90", separator$,
		..."p100"

    # go through each phoneme
    for phonemeIndex from 1 to numberOfPhonemes
	    # phoneme info
	    phonemeLabel$ = Get label of interval: phonemeTier, phonemeIndex
	    @strip: phonemeLabel$
	    phonemeLabel$ = strip.stripped$

        # check if pause or unwanted and continue
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
					    # find duration
					    duration = phonemeEndTime - phonemeStartTime
					    durationMiliseconds = duration * 1000
						
						# extract pitch at 0–100% in 10% steps
						select Pitch 'file_name$'

						p0_time   = phonemeStartTime + duration * 0.0
						p10_time  = phonemeStartTime + duration * 0.1
						p20_time  = phonemeStartTime + duration * 0.2
						p30_time  = phonemeStartTime + duration * 0.3
						p40_time  = phonemeStartTime + duration * 0.4
						p50_time  = phonemeStartTime + duration * 0.5
						p60_time  = phonemeStartTime + duration * 0.6
						p70_time  = phonemeStartTime + duration * 0.7
						p80_time  = phonemeStartTime + duration * 0.8
						p90_time  = phonemeStartTime + duration * 0.9
						p100_time = phonemeStartTime + duration * 1.0

						p0   = Get value at time... p0_time Hertz Linear
						p10  = Get value at time... p10_time Hertz Linear
						p20  = Get value at time... p20_time Hertz Linear
						p30  = Get value at time... p30_time Hertz Linear
						p40  = Get value at time... p40_time Hertz Linear
						p50  = Get value at time... p50_time Hertz Linear
						p60  = Get value at time... p60_time Hertz Linear
						p70  = Get value at time... p70_time Hertz Linear
						p80  = Get value at time... p80_time Hertz Linear
						p90  = Get value at time... p90_time Hertz Linear
						p100 = Get value at time... p100_time Hertz Linear
					
					    foundWordInterval = 1
					    appendFileLine: outputPath$, 
							...file_name$, separator$,
							...wordLabel$, separator$,
							...phonemeLabel$, separator$,
							...durationMiliseconds, separator$,
							...p0, separator$,
							...p10, separator$,
							...p20, separator$,
							...p30, separator$,
							...p40, separator$,
							...p50, separator$,
							...p60, separator$,
							...p70, separator$,
							...p80, separator$,
							...p90, separator$,
							...p100
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
	plus Pitch 'file_name$'
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