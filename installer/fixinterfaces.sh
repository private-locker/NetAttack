#!/bin/bash

MAIN_INTERFACE="wlan0"
SECOND_INTERFACE="wlan1"
TEMP_INTERFACE="tmp0"
BOARD_DRIVER="brcmfmac"
ALFA_CARD="rtl88XXau"

function check_driver() {
        ethtool -i $1 | head -n 1 |sed 's@.*: @@'
}
CHECK_MAIN=$(check_driver ${MAIN_INTERFACE})
if [ "${CHECK_MAIN}" != "${BOARD_DRIVER}" ]; then
        echo -e "Board Driver is not ${MAIN_INTERFACE}, Fixing."
        ifconfig ${MAIN_INTERFACE} down
        ifconfig ${SECOND_INTERFACE} down
        ip link set ${SECOND_INTERFACE} name ${TEMP_INTERFACE}
        sleep 2;
        ip link set ${MAIN_INTERFACE} name ${SECOND_INTERFACE}
        sleep 2;
        ip link set ${TEMP_INTERFACE} name ${MAIN_INTERFACE}
        sleep 2;
        ifconfig ${MAIN_INTERFACE} up
		sleep 2;
        ifconfig ${SECOND_INTERFACE} up
		sleep 2;
		echo -e "Checking ${SECOND_INTERFACE}.."
		CHECK_SECOND=$(check_driver ${SECOND_INTERFACE})
		if [ "${CHECK_SECOND}" != "${ALFA_CARD}" ]; then
			echo -e "WARNING: ${SECOND_INTERFACE} is not a ALFA Adapter!"
		elif [ "${CHECK_SECOND}" == "${ALFA_CARD}" ]; then
			echo -e "PASS: ALFA Adapter detected on ${SECOND_INTERFACE}! Continuing."
		elif [ "${CHECK_SECOND}" == "" ]; then
			echo -e "FAILED: No Card/Adapter detected as ${SECOND_INTERFACE}!"
		fi
		echo -e "Restarting Hostapd to make sure AP is accessible."
		systemctl hostapd restart
        echo -e "Done."
elif [ "${CHECK_MAIN}" == "${BOARD_DRIVER}" ]; then
		echo -e "Board Driver is running on ${MAIN_INTERFACE}."
		echo -e "No action taken."
else
		echo -e "Something is wrong.\n"
		echo -e "Vars:"
		echo -e "MAIN_INTERFACE: ${MAIN_INTERFACE}"
		echo -e "SECOND_INTERFACE: ${SECOND_INTERFACE}"
		echo -e "TEMP_INTERFACE: ${TEMP_INTERFACE}"
		echo -e "BOARD_DRIVER: ${BOARD_DRIVER}"
		echo -e "DO_CHECK: ${DO_CHECK}"
		echo -e "\n Report this screenshot to our GitHub.\n\n\n"
fi
