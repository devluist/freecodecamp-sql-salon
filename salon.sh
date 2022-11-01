#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"
SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services")
SERVICES_COUNT=$($PSQL "SELECT count(*) FROM services")

echo -e "\n~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you?\n"

MENU () {
  FN_SERVICES
  FN_INFO
  FN_TIME
}

FN_SERVICES () {
    echo "$SERVICES_LIST" | while IFS="|" read ID NAME
    do
        echo -e "$ID) $NAME";
    done
    read SERVICE_ID_SELECTED
    if [[ ! "$SERVICE_ID_SELECTED" == [1-$SERVICES_COUNT] ]]; then
        echo -e "\nI could not find that service. What would you like today?"
        FN_SERVICES
    else
        SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    fi
}


FN_INFO () {
	echo -e "\nWhat's your phone number?"
	read CUSTOMER_PHONE # get customer phone
	if [[ -z $CUSTOMER_PHONE ]] # check if enter empty phone 
	then
		echo "I don't have a record for that phone number, what's your name?"
		FN_INFO 
	else
		CHECKED_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
		CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE' AND name IS NULL")
		if [[ -z $CHECKED_PHONE ]] # if not in DB
		then # insert user info into the DB
			echo -e "\nWhat's your name?"
			read CUSTOMER_NAME
			if [[ -z $CUSTOMER_NAME ]]
			then
				echo "Name can't be empty"
				FN_INFO 
			else
				INSERT_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
			fi
		else # insert name if phone in DB
			if [[ ! -z $CUSTOMER_NAME ]]
			then
				echo -e "\nWhat's your name?"
				read CUSTOMER_NAME
				INSERT_CUSTOMER_NAME=$($PSQL "UPDATE customers SET name='$CUSTOMER_NAME' WHERE phone='$CUSTOMER_PHONE'")
			fi
		fi
	fi
}


FN_TIME () {
	echo -e "\nPlease input time what you want to get service (hh:mm)"
	read SERVICE_TIME
	if [[ -z $SERVICE_TIME ]]
	then
		echo "Please input valid time hh:mm"
		FN_TIME 
	else
		CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
		if [[ -z $CUSTOMER_NAME ]]
		then
			CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
		else
			$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")

			echo -e "\nI have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME.\n"
		fi
	fi
}


MENU
