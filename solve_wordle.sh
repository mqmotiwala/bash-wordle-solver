#!/bin/bash

# read and print wordle art
while IFS='' read -r ART
do
  echo "$ART"
done < "./wordle_art.txt"

# color declarations
RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[0m'
YELLOW='\033[0;33m'

# options variable
OPTIONS="\n
Options:\n
1) Add letters to be ${RED}excluded${WHITE} from final word\n
2) Specify a ${GREEN}green${WHITE} letter and its location\n
3) Specify a ${YELLOW}yellow${WHITE} letter and its location\n
4) Show list of potential words\n
5) Exit\n" # update While loop exit condition!

# load full words list in array
readarray -t WORDS <"./words_list.txt"
echo "${#WORDS[@]} words ready to be checked."

# set vars to empty
INCLUDE=""
EXCLUDE=""
SELECTION=0

while [ $SELECTION -ne 5 ]
do
	# get user input on what filter to apply
	echo -e $OPTIONS
	read SELECTION
	
	case $SELECTION in
		1) 
			read -p "Enter letters to exclude: "
			EXCLUDE="$REPLY$EXCLUDE"
			echo -e "The following letters are being ${RED}excluded${WHITE}: $EXCLUDE\n"
			
			# filter words list
			COUNT=0
			WORDS_TOTAL=${#WORDS[@]}
			for (( W=0; W<$WORDS_TOTAL; W++ ))
			do
				WORD=${WORDS[$W]}
								
				for (( i=0; i<${#WORD}; i++ ))
				do
					for (( j=0; j<${#EXCLUDE}; j++ ))
					do
						if [ "${WORD:$i:1}" = "${EXCLUDE:$j:1}" ]
						then
							echo "$WORD excluded (contains ${EXCLUDE:$j:1})"
							unset WORDS[$W]
							
							(( COUNT++ ))
							break 2
						fi
					done
				done
			done
			;;
		
		2)
			read -p "Specify the green letter: " LETTER
			read -p "Specify its position: " POS_HUMAN
		
			#0-index POS
			let POS=$POS_HUMAN-1 
			
			# filter array
			COUNT=0
			WORDS_TOTAL=${#WORDS[@]}
			for (( W=0; W<$WORDS_TOTAL; W++ ))
			do
				WORD=${WORDS[$W]}
				
				if [ "${WORD:$POS:1}" != "$LETTER" ]
				then
					echo "$WORD excluded (missing $LETTER in Position $POS_HUMAN)"
					unset WORDS[$W]

					(( COUNT++ ))
				fi
			done
			;;
		
		3)
			read -p "Specify the yellow letter: " LETTER
			read -p "Specify its position: " POS_HUMAN
		
			#0-index POS
			let POS=$POS_HUMAN-1
			
			# filter array
			KEEP=0
			COUNT=0
			WORDS_TOTAL=${#WORDS[@]}
			for (( W=0; W<$WORDS_TOTAL; W++ ))
			do
				WORD=${WORDS[$W]}
				
				# remove all words with yellow letter in given position
				if [ "${WORD:$POS:1}" == "$LETTER" ]
				then
					echo "$WORD excluded ($LETTER in Position $POS_HUMAN)"
					unset WORDS[$W]

					(( COUNT++ ))
				else
					# for words without yellow letter in given position;
					#	check that the yellow letter appears at least once
					
					for (( i=0; i<${#WORD}; i++ ))
					do
						if [ "${WORD:$i:1}" = "$LETTER" ]
						then
							(( KEEP++ ))
							break
						fi
					done
					
					if [ $KEEP -eq 0 ]
					then
						echo "$WORD excluded (does not contain $LETTER)"
						unset WORDS[$W]

						(( COUNT++ ))
					fi
				fi
				
				# reset KEEP for next word
				KEEP=0
			done
			;;
			
		4)
			for WORD in "${WORDS[@]}"
			do
				echo $WORD
			done
			continue
			;;
		
		5) 
			echo -e "\nGoodbye!\n" 
			exit;;
		
		*) 
			echo "Invalid selection." 
			SELECTION=0
			continue
			;;
	esac
	
	WORDS=( "${WORDS[@]}" )
	echo -e "\nExcluded $COUNT words based on given information."
	echo "${#WORDS[@]} potential solutions remaining."
done

 