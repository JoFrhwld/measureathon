clearinfo

printline Thank you for starting the eVoweluate experiment. Please read this consent form.
printline
printline We estimate that it will take between and hour and an hour and a half to complete the experiment.
printline You can pause the experiment at any point, and restart it at a later time (see the README for directions).
printline
printline Your responses will be assigned a random ID number, which will not be associated with your contact info.
printline The data you provide will never be distributed with personally identifying information.
printline You may choose, if you wish, to be thanked and acknowledged by name in public presentations and papers based on this study
printline
printline The data you provide will be used to:
printline 'tab$'-evaluate the quality of the measurements provided by the FAVE suite.
printline 'tab$'-estimate the degree of agreement between experts on vowel measurements.
printline 
printline This Praat script will capture multiple pieces of information about your vowel measurement, including
printline 'tab$'-the formant settings
printline 'tab$'-how zoomed in or out the editor window is
printline 'tab$'-whether or not pulses, intensity and pitch are displayed
printline 'tab$'-F1, F2 and F2, and time point of measurement.
printline Please consult the README.pdf document for additional information.
printline
printline Your participation is voluntary.
printline You may choose to withdraw your consent and end your participation at any time, without any penalty.
printline
printline
printline By clicking on "Begin Experiment", you are confirming that:
printline 'tab$'-You are at least 18 years old.
printline 'tab$'-You have read this consent form.
printline 'tab$'-You want to participate in this experiment.

beginPause("Start Experiment")

experiment = endPause("Cancel","Begin Experiment",2)

if experiment == 1
state$ = "nogo"
goto cleanup
endif



directory$ = "./"
wav_directory$ = directory$+"WavFiles/"
tg_directory$ = directory$+"TextGrids/"
results_directory$ = directory$+"Results/"

Create Strings as file list... results_list 'results_directory$'*.txt
To WordList

Read Table from tab-separated file... 'directory$'selector.txt

n_items = Get number of rows

state$ = "measuring"


number_of_formants = 5
maximum_formant = 5500
window_length = 0.025
dynamic_range = 30.0

for i from 1 to n_items
	select Table selector
	file$ = Get value... i File
	base_name$ = replace$ (file$, ".txt", "", 0)

	order$ = Get value... i Order
	vowel$ = Get value... i VClass
	word$ = Get value... i Word
	
	name$ = file$
	

	check_result$ = name$+".txt"
	select WordList results_list
	done = Has word... 'check_result$'

	if done == 0
		Read from file... 'wav_directory$''name$'.wav
		start = Get start time
		end = Get end time
		
		Read from file... 'tg_directory$''name$'.TextGrid
		

		select Sound 'name$'
		plus TextGrid 'name$'

		View & Edit
		editor TextGrid 'name$'

		Formant settings... maximum_formant number_of_formants window_length dynamic_range 1
		
		Select... start end
		Play window
		Select... start start

		start_time$ = date$ ()
		n_replay = 0
		
		coded = 0 
		while coded == 0
		beginPause ("Instructions ('i'/'n_items')")
			comment ("Measure the vowel /"+vowel$+"/ in the word "+word$)
			comment ("Formant Settings")

			real ("Maximum formant", maximum_formant)
			real ("Number of formants", number_of_formants)
			real ("Window length", window_length)
			real ("Dynamic range", dynamic_range)
						
		clicked = endPause ("Replay", "Apply", "Measure", "Break", 2, 1)

		if clicked == 1
			Play window
			n_replay = n_replay + 1
		elsif clicked == 4
			coded = 1
			state$ = "breaking"
			endeditor
			goto cleanup
		elsif clicked == 2
			Formant settings... maximum_formant number_of_formants window_length dynamic_range 1
		elsif clicked == 3
			select_start = Get start of selection
			select_end = Get end of selection

			if select_start == start
				beginPause("Full selection")
					comment ("You haven't moved the cursor.")
					comment ("Are you sure you want to measure here?")
				sure = endPause("Yes", "No", 2, 1)
			else
				sure = 1
			endif
			
			if sure == 1
			
				end_time$ = date$ ()
				coded = 1
				settings$ = Editor info
			
				window_start = extractNumber (settings$, "Window start:")
				window_end = extractNumber (settings$, "Window end:")
				spect_from = extractNumber (settings$, "Spectrogram view from:")
				spect_to = extractNumber (settings$, "Spectrogram view to:")
				max_formant = extractNumber (settings$, "Formant maximum formant:")
				n_poles = extractNumber (settings$, "Formant number of poles:")
				window_length = extractNumber (settings$, "Formant window length:")
				dynamic_range = extractNumber (settings$, "Formant dynamic range:")
				pre_emph = extractNumber (settings$, "Formant pre-emphasis from:")

				pitch$ = extractWord$ (settings$, "Pitch show:")
				intensity$ = extractWord$ (settings$, "Intensity show:")
				pulses$ = extractWord$ (settings$, "Pulses show:")

				endeditor

				nformants = n_poles/2

				select Sound 'name$'
				To Formant (burg)... 0 nformants max_formant window_length pre_emph

				if select_start == select_end
					f1 = Get value at time... 1 select_start Hertz Linear
					f2 = Get value at time... 2 select_start Hertz Linear
				else 
					f1 = Get mean... 1 select_start select_end Hertz
					f2 = Get mean... 1 select_start select_end Hertz
				endif

				outfile$ = directory$+"Results/"+name$+".txt"
				fileappend 'outfile$' Item	VClass	Word	F1	F2	Select_start	Select_end	Max_formant	Poles	Window_length	Dynamic_range Pre_emph	Pre_emph	Window_start	Window_end	Spect_from	Spect_to	Pitch	Intensity	Pulses	Replay	Start_time	End_time'newline$'
				fileappend 'outfile$' 'name$'	'vowel$'	'word$'	'f1:1'	'f2:1'	'select_start:5'	'select_end:5'	'max_formant:1'	'n_poles:0'	'window_length:5'	'dynamic_range:5'	'pre_emph:1'	'window_start:5'	'window_end:5'	'spect_from:1'	'spect_to:1'	'pitch$'	'intensity$'	'pulses$'	'n_replay:0'	'start_time$'	'end_time$''newline$'

				select Formant 'name$'
				Remove
				select Sound 'name$'
				Remove
				select TextGrid 'name$'
				Remove
			endif
		endif
		endwhile
	endif
endfor

label cleanup

if state$ == "measuring"
	select all
	Remove
	clearinfo
	printline That's all of the measurements! Thank you so much!
	printline Some additional information may be useful for analyzing the data you've provided, including
	printline 'tab$'-your level experience with vowel measurement,
	printline 'tab$'-where you received your training in vowel analysis,
	printline 'tab$'-and your familiarity with the FAVE suite.
	printline I would also like to collect some feedback on the experiment itself.
	printline If you you are willing to answer some of these questions, please click on 'Take the Survey'
	printline You may choose the skip the survey at any time, and none of your responses will be recorded.
	beginPause("Exit Survey")
	take_survey = endPause("Skip the Survey", "Take the Survey", 2, 1)
	if take_survey == 2
		state$ = "taking"
		goto survey
	else 
		state$ = "skipping"
		goto skipping
	endif
	#echo That's all of them! Thanks so much! You're a champ.
elsif state$ == "breaking"
	select all
	Remove
	echo Thanks! Go get a coffee or a water. You deserve it. Come back soon!
endif



label survey

if state$ == "taking"
	deleteFile(results_directory$ + "survey.txt")
	beginPause("Survey (1 of 2)")
		comment ("Where did you receive your primary training in vowel analysis?")
		sentence ("Training", "Rather not say.")

		comment ("On a scale of 1 to 5, what is your expertise in vowel analysis?")
		comment ("1 = I do mostly other research")
		comment ("5 = I've done a large-scale research project on vowel measurements.")
		
		choice ("Expertise", 3)
			option ("1")
			option ("2")
			option ("3")
			option ("4")
			option ("5")

		comment ("How familiar are you with the FAVE suite's measurement techniques.")
		comment ("1 = I was previously unfamiliar with FAVE.")
		comment ("3 = I have read the FAVE website / used the FAVE suite.")
		comment ("5 = I know in detail how FAVE selects measurement points/formant settings.")

		choice ("Familiarity", 3)
			option ("1")
			option ("2")
			option ("3")
			option ("4")
			option ("5")

	continue_survey = endPause("Skip Survey", "Next", 2, 1)
	if continue_survey == 2
		beginPause("Survey (2 of 2)")
			comment ("How easy did you find it to run and participate in this experiment.")
			comment ("1 = Trivially Easy")
			comment ("5 = There were significant difficulties")

			choice ("Difficulty", 3)
				option ("1")
				option ("2")
				option ("3")
				option ("4")
				option ("5")

			comment ("How confident are you in the measurements you made.")
			comment ("1 = Not confident at all.")
			comment ("5 = I doubt there are any errors.")

			choice ("Confidence", 3)
				option ("1")
				option ("2")
				option ("3")
				option ("4")
				option ("5")

			comment ("Any brief thoughts?")
			sentence ("Comments", "")
		finish_survey = endPause("Skip Survey", "Finish", 2, 1)
		if finish_survey == 2
			fileappend 'results_directory$'survey.txt Training	Expertise	Familiarity	Difficulty	Confidence	Comments'newline$'
			fileappend 'results_directory$'survey.txt 'training$'	'expertise'	'familiarity'	'difficulty'	'confidence'	'comments$''newline$'

			beginPause("Acknowledgement")
				comment("How would you like to be thanked and acknowledged")
				comment("in public presentations and publications based on this study?")
				sentence("Acknowledge me as", "Anonymous participant")
			acknowledge = endPause("Finish", 1)
			deleteFile(results_directory$ + "acknowledgement.txt")
			fileappend 'results_directory$'acknowledgement.txt 'acknowledge_me_as$'


			clearinfo
			printline Thank you! Your survey responses have been recorded.
			printline If you change your mind about responding to the survey, you can simply delete 'survey.txt' in the Results directory.
			printline
			printline In public presentations and papers based on this study, 
			printline you will be thanked and acknowleded as "'acknowledge_me_as$'"
			printline
			printline Please compress the Results directory, and e-mail it to eVoweluate@gmail.com
			printline Thank you for participating!

		else
			state$ = "skipping"
			goto skipping
		endif
	else
		state$ = "skipping"
		goto skipping
	endif
endif

label skipping
if state$ == "skipping"
	beginPause("Acknowledgement")
		comment("How would you like to be thanked and acknowledged")
		comment("in public presentations and publications based on this study?")
		sentence("Acknowledge me as", "Anonymous participant")
	acknowledge = endPause("Finish", 1)
	deleteFile(results_directory$ + "acknowledgement.txt")
	fileappend 'results_directory$'acknowledgement.txt 'acknowledge_me_as$'


	clearinfo
	printline No survey responses have been recorded for you.
	printline If you change your mind, you can take the survey by rerunning the script (the experiment will not repeat).
	printline
	printline In public presentations and papers based on this study, 
	printline you will be thanked and acknowleded as "'acknowledge_me_as$'"
	printline
	printline Please compress the Results directory, and e-mail it to eVoweluate@gmail.com
	printline Thank you for participating!
endif

if state$ == "nogo"
clearinfo
printline Ok. If you change your mind about participating, simply rerun this script.
endif



