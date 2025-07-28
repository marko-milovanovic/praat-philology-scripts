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

# vowels
vowels$[1] = "a"
vowels$[2] = "e"
vowels$[3] = "i"
vowels$[4] = "o"
vowels$[5] = "u"
numberOfVowels = 5

columnNames$ = " " + separator$ + "DS" + separator$ + "DU" + separator$ + "KS" + separator$ + "KU" + separator$ + "PRED" + separator$ + "POST.Z" + separator$ + "POST.O"
numberOfColumns = 7

phonemeMap$[1,1] = "a162 a163"
phonemeMap$[1,2] = "a262 a263 a263d"
phonemeMap$[1,3] = "a362 a363"
phonemeMap$[1,4] = "a462 a463 a463d"
phonemeMap$[1,5] = "a723 a743"
phonemeMap$[1,6] = "a62_1z a63_1z a62_2z a63_2z a63d_2z a62_3z a63_3z a62_4z a63_4z a63d_4z"
phonemeMap$[1,7] = "a62_1o a63_1o a62_2o a63_2o a63d_2o a62_3o a63_3o a62_4o a63_4o a63d_4o"

phonemeMap$[2,1] = "e162 e163"
phonemeMap$[2,2] = "e262 e263 e263d"
phonemeMap$[2,3] = "e362 e363"
phonemeMap$[2,4] = "e462 e463 e463d"
phonemeMap$[2,5] = "e723 e743"
phonemeMap$[2,6] = "e62_1z e63_1z e62_2z e63_2z e63d_2z e62_3z e63_3z e62_4z e63_4z e63d_4z"
phonemeMap$[2,7] = "e62_1o e63_1o a62_2o e63_2o e63d_2o e62_3o e63_3o e62_4o e63_4o e63d_4o"

phonemeMap$[3,1] = "i162 i163"
phonemeMap$[3,2] = "i262 i263 i263d"
phonemeMap$[3,3] = "i362 i363"
phonemeMap$[3,4] = "i462 i463 i463d"
phonemeMap$[3,5] = "i723 i743"
phonemeMap$[3,6] = "i62_1z i63_1z i62_2z i63_2z i63d_2z i62_3z i63_3z i62_4z i63_4z i63d_4z"
phonemeMap$[3,7] = "i62_1o i63_1o i62_2o i63_2o i63d_2o i62_3o i63_3o i62_4o i63_4o i63d_4o"

phonemeMap$[4,1] = "o162 o163"
phonemeMap$[4,2] = "o262 o263 o263d"
phonemeMap$[4,3] = "o362 o363"
phonemeMap$[4,4] = "o462 o463 o463d"
phonemeMap$[4,5] = "o723 o743"
phonemeMap$[4,5] = "o723 o743"
phonemeMap$[4,6] = "o62_1z o63_1z o62_2z o63_2z o63d_2z o62_3z o63_3z o62_4z o63_4z o63d_4z"
phonemeMap$[4,7] = "o62_1o o63_1o o62_2o o63_2o o63d_2o o62_3o o63_3o o62_4o o63_4o o63d_4o"

phonemeMap$[5,1] = "u162 u163"
phonemeMap$[5,2] = "u262 u263 u263d"
phonemeMap$[5,3] = "u362 u363"
phonemeMap$[5,4] = "u462 u463 u463d"
phonemeMap$[5,5] = "u723 u743"
phonemeMap$[5,6] = "u62_1z u63_1z u62_2z u63_2z u63d_2z u62_3z u63_3z u62_4z u63_4z u63d_4z"
phonemeMap$[5,7] = "u62_1o u63_1o u62_2o u63_2o u63d_2o u62_3o u63_3o u62_4o u63_4o u63d_4o"

# get wav files from provided directory
Create Strings as file list...  list 'directory_input_path$'*.wav
number_of_files = Get number of strings

# go through each vowel
for vowelIndex from 1 to numberOfVowels
	for columnIndex from 1 to numberOfColumns
    	sumDuration[vowelIndex,columnIndex] = 0
    	count[vowelIndex,columnIndex] = 0
		durations[vowelIndex,columnIndex] = undefined
    	minDuration[vowelIndex,columnIndex] = 1e9
    	maxDuration[vowelIndex,columnIndex] = 0
	endfor
endfor

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

    # grid data
    select TextGrid 'file_name$'
    numberOfPhonemes = Get number of intervals: phonemeTier

	# go through each vowel
	for vowelIndex from 1 to numberOfVowels

		# go through each phoneme
		for phonemeIndex from 1 to numberOfPhonemes
			# phoneme info
			phonemeLabel$ = Get label of interval: phonemeTier, phonemeIndex
			@strip: phonemeLabel$
			phonemeLabel$ = strip.stripped$

			# check if pause or unwanted and continue
			unwantedPhonemes$ = "a8 e8 o8 i8 u8 g8"
			if phonemeLabel$ <> "" and index (" " + unwantedPhonemes$ + " ", " " + phonemeLabel$ + " ") == 0
				phonemeStartTime = Get start time of interval: phonemeTier, phonemeIndex
				phonemeEndTime = Get end time of interval: phonemeTier, phonemeIndex

				# find duration
				duration = phonemeEndTime - phonemeStartTime
				durationMiliseconds = duration * 1000

				for columnIndex from 1 to numberOfColumns
					if index (" " + phonemeMap$[vowelIndex,columnIndex] + " ", " " + phonemeLabel$ + " ") > 0
						sumDuration[vowelIndex,columnIndex] += durationMiliseconds
						count[vowelIndex,columnIndex] += 1
						durationIndex = (columnIndex - 1) * 100 + count[vowelIndex,columnIndex]
						durations[vowelIndex,durationIndex] = durationMiliseconds
						if durationMiliseconds < minDuration[vowelIndex,columnIndex]
							minDuration[vowelIndex,columnIndex] = durationMiliseconds
						endif
						if durationMiliseconds > maxDuration[vowelIndex,columnIndex]
							maxDuration[vowelIndex,columnIndex] = durationMiliseconds
						endif
					endif
				endfor
			endif
		endfor
	endfor

	# remove temporary objects
	select Sound 'file_name$'
	plus TextGrid 'file_name$'
	Remove
endfor

for vowelIndex from 1 to numberOfVowels
	vowel$ = vowels$[vowelIndex]

	outputPath$ = "'directory_output_path$'combined_'vowel$'.txt"
	header$ = columnNames$
	writeFileLine: outputPath$, header$

	averageDurationLine$ = "prosek"
	standardDeviationLine$ = "SD"
	minDurationLine$ = "min"
	maxDurationLine$ = "max"

	for columnIndex from 1 to numberOfColumns
		averageDuration = sumDuration[vowelIndex,columnIndex] / count[vowelIndex,columnIndex]

		standardDeviation = 0
		for index from 1 to count[vowelIndex,columnIndex]
			durationIndex = (columnIndex - 1) * 100 + index
			standardDeviation += (durations[vowelIndex,durationIndex] - averageDuration)^2
		endfor
		standardDeviation = sqrt(standardDeviation / (count[vowelIndex,columnIndex] - 1))

		averageDurationLine$ = averageDurationLine$ + separator$ + string$(averageDuration)
		standardDeviationLine$ = standardDeviationLine$ + separator$ + string$(standardDeviation)
		minDurationLine$ = minDurationLine$ + separator$ + string$(minDuration[vowelIndex,columnIndex])
		maxDurationLine$ = maxDurationLine$ + separator$ + string$(maxDuration[vowelIndex,columnIndex])
	endfor
				
	appendFileLine: outputPath$, averageDurationLine$
	appendFileLine: outputPath$, standardDeviationLine$
	appendFileLine: outputPath$, minDurationLine$
	appendFileLine: outputPath$, maxDurationLine$
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