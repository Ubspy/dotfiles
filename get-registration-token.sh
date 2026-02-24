#!/bin/bash

# Validate auth token
if [[ -z "${1}" ]]; then
	echo "Provide your access token with ./get-resitration-tokens.sh <token>"
	echo "This token can be found in Element user settings, at the bottom of the about section"
	exit
fi

AUTH="$1"

function ask_delete_tok() {
	# Loop permenantly to ask yes or no delete token
	while true; do
		echo -n "Would you like to delete the token? (y/n) "
		read -p "" ANS < /dev/tty
		case "$ANS" in
			[yY]|[yY][eE][sS])
				echo "Deleting token $1..."
				curl -s -H "Authorization: Bearer $AUTH" -X DELETE -d '{}' "http://localhost:8008/_synapse/admin/v1/registration_tokens/$1"
				echo ""

				# Return 1 to tell above function we deleted the token
				return 1
				;;
			[nN]|[nN][oO])
				echo "Leaving token $1 live..."
				echo ""
				
				# Return 0 to tell above function we didn't delete the token
				return 0
				;;
			*)
				# Repeat question
				;;
		esac
	done
}

# Get cujrrent tokens
echo "FETCHING TOKENS..."
INIT_TOKS=`curl -s -H "Authorization: Bearer $AUTH" -X GET http://localhost:8008/_synapse/admin/v1/registration_tokens`
TOKS_CLEAN=`echo $INIT_TOKS | sed -n 's/.*"registration_tokens":\[\(.*\)\].*/\1/p'`

if [[ -n "$TOKS_CLEAN" ]]; then
	echo "$TOKS_CLEAN" | sed 's/},{/}\n{/g' | while IFS= read -r TOK; do
		# Extract value from uses_allowed key
		# .* 			- any character any amount of times
		# "used_allowed": 	- search for this exact substring
		# \(\)			- escaped group wrapped in parentheses to be addressed later
		# [0-9]*		- a digit from 0 to 9, for as long as there are numbers
		# .*			- any remaining characters in string
		# /\1/p			- turn the whole token string into just the thing wrapped in the 1st group parentheses
		# 			 in this case, the numbers
		USES=`echo $TOK | sed -n 's/.*"uses_allowed":\([0-9]*\).*/\1/p'`

		# Extract value from completed key
		COMPLETE=`echo $TOK | sed -n 's/.*"completed":\([0-9]*\).*/\1/p'`

		# Extract value from token key
		# "\(\)"		- Wrap group in quotes, since we're looking for a token wrapped in quotes
		# [^"]			- Any characters up to a quotation mark
		CUR_TOK=`echo $TOK | sed -n 's/.*"token":"\([^"]*\)".*/\1/p'`

		# Extract value from token key
		# [^"}]			- Any character except an ending quote or a closing curly bracket
		EXPIRY=`echo $TOK | sed -n 's/.*"expiry_time":\([^"}]*\).*/\1/p'`

		if [ "$USES" -eq "$COMPLETE" ]; then
			echo "Dead token found, token key $CUR_TOK has no uses left:"
			echo "    $TOK"	
			ask_delete_tok "$CUR_TOK"

			if [[ "$?" -eq 1 ]]; then
				# Don't check for expiry if we deleted the token
				continue;
			fi
		fi

		if [[ "$EXPIRY" != "null" ]]; then
			if [[ "$EXPIRY" -lt `date '+ %s000'` ]]; then
				echo "Expired token found, token key $CUR_TOK has passed its expiration date:"
				echo "    $TOK"	
				ask_delete_tok "$CUR_TOK"
			fi
		fi
	done
else
	echo "No dead or expired tokens found!!"	
	echo ""
fi

# Check for extra tokens
EXTRA_TOKS=`curl -s -H "Authorization: Bearer $AUTH" -X GET http://localhost:8008/_synapse/admin/v1/registration_tokens`
TOKS_CLEAN=`echo $EXTRA_TOKS | sed -n 's/.*"registration_tokens":\[\(.*\)\].*/\1/p'`

if [[ -n "$TOKS_CLEAN" ]]; then
	echo "$TOKS_CLEAN" | sed 's/},{/}\n{/g' | while IFS= read -r TOK; do
		# Extract value from uses_allowed key
		# .* 			- any character any amount of times
		# "used_allowed": 	- search for this exact substring
		# \(\)			- escaped group wrapped in parentheses to be addressed later
		# [0-9]*		- a digit from 0 to 9, for as long as there are numbers
		# .*			- any remaining characters in string
		# /\1/p			- turn the whole token string into just the thing wrapped in the 1st group parentheses
		# 			 in this case, the numbers
		USES=`echo $TOK | sed -n 's/.*"uses_allowed":\([0-9]*\).*/\1/p'`

		# Extract value from completed key
		COMPLETE=`echo $TOK | sed -n 's/.*"completed":\([0-9]*\).*/\1/p'`

		# Extract value from token key
		# "\(\)"		- Wrap group in quotes, since we're looking for a token wrapped in quotes
		# [^"]			- Any characters up to a quotation mark
		CUR_TOK=`echo $TOK | sed -n 's/.*"token":"\([^"]*\)".*/\1/p'`

		# Extract value from token key
		# [^"}]			- Any character except an ending quote or a closing curly bracket
		EXPIRY=`echo $TOK | sed -n 's/.*"expiry_time":\([^"}]*\).*/\1/p'`

		echo "Extra token $CUR_TOK with $USES left, expires $EXPIRY"
	done

	# Loop permenantly to ask yes or no to make a new token
	while true; do
		echo ""
		echo -n "Extra unused tokens found, still make a new one? (y/n) "
		read -p "" ANS < /dev/tty
		case "$ANS" in
			[yY]|[yY][eE][sS])
				echo "Making new token..."
				TOMORROW=`date '+ %s000' -d 'tomorrow'`
				JSON='{"uses_allowed":1,"expiry_time":'$TOMORROW'}'
				curl -H "Authorization: Bearer $AUTH" -X POST "http://localhost:8008/_synapse/admin/v1/registration_tokens/new" -d "$JSON"
				echo ""
				break
				;;
			[nN]|[nN][oO])
				echo "Goodbye!"
				echo ""
				exit 0
				;;
			*)
				# Repeat question
				;;
		esac
	done
else
	# Make the new token if no lives ones are found	
	echo "Making new token..."
	TOMORROW=`date '+ %s000' -d 'tomorrow'`
	JSON='{"uses_allowed":1,"expiry_time":'$TOMORROW'}'
	curl -H "Authorization: Bearer $AUTH" -X POST "http://localhost:8008/_synapse/admin/v1/registration_tokens/new" -d "$JSON"
	echo ""
fi	
