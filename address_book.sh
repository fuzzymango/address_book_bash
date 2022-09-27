#!/bin/sh
# address book 
# isaac spiegel

LOG="./address_book.txt"

# -----------------------------------------------------------------
# READ_LOG
# 
# converts a contact stored in the address_book.txt file from
# 'last,first' to 'first last'.
# -----------------------------------------------------------------
read_log()
{
	READ_FIRST=`echo $1 | cut -d',' -f2`
	READ_LAST=`echo $1 | cut -d',' -f1`
	READ_OUT="$READ_FIRST $READ_LAST"
}

# -----------------------------------------------------------------
# ADD
# 
# prompts the user for a first and last name then adds the contact
# to the specified address book txt file
# -----------------------------------------------------------------
add()
{
	echo "${LAST},${FIRST}" >> address_book.txt
	read -p "Contact added! (ENTER to continue)"
}

# -----------------------------------------------------------------
# VIEW
#
# echos every contact from the address book to the terminal
# -----------------------------------------------------------------
view()
{
	echo "ALL CONTACTS"
	while read -r line
	do
		read_log $line
		echo $READ_OUT
	done < $LOG
}

# -----------------------------------------------------------------
# SEARCH
# 
# searches for a given contact in the address book and prints any
# matches found
# -----------------------------------------------------------------
search()
{
	while read -r line
	do
		read_log $line
		echo "$line" | grep $1
	done < $LOG
}

# -----------------------------------------------------------------
# DELETE
# 
# deletes a user-specified contact from the list
# -----------------------------------------------------------------
delete()
{
	declare -a MATCHES
	while read -r line
	do
		read_log $line
		MATCH=`echo "$line" | grep $1`
		MATCHES+=($MATCH)
	done < $LOG

	if [ -z ${MATCHES} ]; then
		echo "No matches found."
		return 
	fi

	for m in ${!MATCHES[@]}
	do
		echo "$m : ${MATCHES[$m]}"
	done

	echo "Enter the index of the contact to be deleted:"
	read INPUT_STRING
	
	while [ $INPUT_STRING -gt `expr ${#MATCHES[@]} - 1` ]
	do
		echo "Index out of range, try again:"
		read INPUT_STRING
	done

	echo "Really delete ${MATCHES[$INPUT_STRING]}? (y/n)"
	read CONFIRM
	case $CONFIRM in
		y)
			echo "${MATCHES[$INPUT_STRING]} deleted."
			TO_DEL=${MATCHES[$INPUT_STRING]}
			sed -i '' -e "/$TO_DEL/d" $LOG
			;;
		n)
			echo "cancelling..."
			;;
		*)
			echo "failed to understand input."
			;;
	esac
}

# -----------------------------------------------------------------
# MAIN
# 
# the driver function for the address book, manages the 
# main menu. Takes in user input and calls the relevant function
# ----------------------------------------------------------------- 
main()
{
	echo "Welcome to your address book!"
	while :
	do 
		echo "-----------------------------"
		echo "type \"add\" to add a contact"
		echo "type \"view\" to see all contacts"
		echo "type \"search\" to find a contact"
		echo "type \"del\" to delete a contact"
		echo "type \"q\" to exit"
		echo "-----------------------------"

		read INPUT_STRING
		case $INPUT_STRING in 
			add)
				echo "Contact first name: (ENTER to continue)"
				read FIRST
				echo "Contact last name: (ENTER to continue)"
				read LAST
				echo "Add ${LAST}, ${FIRST}? (y/n)"
				read RESPONSE
				case $RESPONSE in
					y)
						add $FIRST $LAST
						;;
					n)
						echo "cancelled"
						;;
					*) 
						echo "unknown command"
						;;
				esac
				;;
			view)
				view
				read -p "(ENTER to continue)"
				;;
			search)
				echo "Enter contact's name:"
				read INPUT_STRING
				search $INPUT_STRING
				read -p "(ENTER to continue)"
				;;
			q)
				echo "see you soon!"
				break
				;;
			del)
				echo "Enter a name:"
				read INPUT_STRING
				delete $INPUT_STRING
				read -p "(ENTER to continue)"
				;;
			*)
				echo "uknown input"
				;;
		esac
	done

}


#################################
#### MAIN SCRIPT STARTS HERE ####
#################################
# CHECK THE LOG FILEPATH AT THE TOP OF THE SCRIPT
main
