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
outputPath$ = "'directory_output_path$'tone_values.txt"
writeFileLine: outputPath$,
	..."speaker", separator$,
	..."word", separator$,
	..."phoneme", separator$,
	..."min (Hz)", separator$,
	..."min (ERB)", separator$,
	..."max (Hz)", separator$,
	..."max (ERB)", separator$,
	..."duration (ms)", separator$,
	..."max pitch time (ms)", separator$,
	..."%", separator$,
	..."p0 (Hz)", separator$,
	..."p0 (ERB)", separator$,
	..."p10 (Hz)", separator$,
	..."p10 (ERB)", separator$,
	..."p20 (Hz)", separator$,
	..."p20 (ERB)", separator$,
	..."p30 (Hz)", separator$,
	..."p30 (ERB)", separator$,
	..."p40 (Hz)", separator$,
	..."p40 (ERB)", separator$,
	..."p50 (Hz)", separator$,
	..."p50 (ERB)", separator$,
	..."p60 (Hz)", separator$,
	..."p60 (ERB)", separator$,
	..."p70 (Hz)", separator$,
	..."p70 (ERB)", separator$,
	..."p80 (Hz)", separator$,
	..."p80 (ERB)", separator$,
	..."p90 (Hz)", separator$,
	..."p90 (ERB)", separator$,
	..."p100 (Hz)", separator$,
	..."p100 (ERB)"

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

	# check speaker from filename
	if index(file_name$, "F") <> 0
		To Pitch... 0.01 100 500
	elsif index(file_name$, "M") <> 0
    	To Pitch... 0.01 70 300
	else
		appendInfoLine: "Warning: Unknown speaker type for file ", file_name$
		select Sound 'file_name$'
		Remove
		continue
	endif

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

						minPitch = Get minimum... phonemeStartTime phonemeEndTime Hertz Parabolic
						minPitchERB = hertzToErb (minPitch)
						maxPitch = Get maximum... phonemeStartTime phonemeEndTime Hertz Parabolic
						maxPitchERB = hertzToErb (maxPitch)
						maxTime = Get time of maximum... phonemeStartTime phonemeEndTime Hertz Parabolic
						phonemeMaxTime = (maxTime - phonemeStartTime) * 1000
						percentage = ((maxTime - phonemeStartTime) / duration) * 100

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

						p0ERB   = hertzToErb (p0)
						p10ERB  = hertzToErb (p10)
						p20ERB  = hertzToErb (p20)
						p30ERB  = hertzToErb (p30)
						p40ERB  = hertzToErb (p40)
						p50ERB  = hertzToErb (p50)
						p60ERB  = hertzToErb (p60)
						p70ERB  = hertzToErb (p70)
						p80ERB  = hertzToErb (p80)
						p90ERB  = hertzToErb (p90)
						p100ERB = hertzToErb (p100)
					
					    foundWordInterval = 1
					    appendFileLine: outputPath$, 
							...file_name$, separator$,
							...wordLabel$, separator$,
							...phonemeLabel$, separator$,
							...minPitch, separator$,
							...minPitchERB, separator$,
							...maxPitch, separator$,
							...maxPitchERB, separator$,
							...durationMiliseconds, separator$,
							...phonemeMaxTime, separator$,
							...percentage, separator$,
							...p0, separator$,
							...p0ERB, separator$,
							...p10, separator$,
							...p10ERB, separator$,
							...p20, separator$,
							...p20ERB, separator$,
							...p30, separator$,
							...p30ERB, separator$,
							...p40, separator$,
							...p40ERB, separator$,
							...p50, separator$,
							...p50ERB, separator$,
							...p60, separator$,
							...p60ERB, separator$,
							...p70, separator$,
							...p70ERB, separator$,
							...p80, separator$,
							...p80ERB, separator$,
							...p90, separator$,
							...p90ERB, separator$,
							...p100, separator$,
							...p100ERB

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