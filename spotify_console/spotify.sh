# Script soll mit Bash ausgeführt werden

#!/bin/bash

# Variablen werden definiert

daemonPID=
sptPID=
daemonEXITSTAT=
sptEXITSTAT=

# FUNCNEST=2 sagt bash, dass sich Funktionen maximal 2 mal selbst callen dürfen 

FUNCNEST=2

# check_spotifyd soll prüfen, ob der spotify daemon gestartet wurde

function check_spotifyd() {
	
	echo "looking for spotifyd"
	
# pgrep -x sucht nach der PID des prozesses mit dem angegebenen Namen.
# Alternativ kann man pidof verwenden, stack overflow sagt aber, das sei nicht so gut.
# Das Script funktioniert mit beiden Varianten nicht :D
	
	daemonPID=$(pgrep -x spotifyd)

# $? steht für den Exitstatus des zuletzt ausgeführten befehls.
# War der Befehl erfolgreicht ist $?=0, andernfalls wird ein anderer code ausgegeben.
	
	daemonEXITSTAT=$?

# In Bash vergleicht man Integer mit -Optionen und Strings mit == Operatoren.
# Warum? Weil fuck you. Darum. -ne steht für "Not Equal".

	if [ $daemonEXITSTAT -ne 0 ] 
	then
		
		echo "spotifyd deamon not running"
		echo "starting spotifyd daemon"
		
		spotifyd &
		
# Den until - do loop hab ich auch von stack overflow. In der spotifyd Version der Funktion
# macht der aber auch keine Probleme. 

# Ein until - loop tut etwas, bis eine Bedingung erfüllt ist. In diesem Fall denke ich
# Die Variable kann nur befüllt werden, wenn pgrep -x eine PID wiedergibt, also wird der Loop
# ausgeführt, bis das Program gestartet wurde und die Variable befüllt wird.
		
		until daemonPID=$(pgrep -x spotifyd)
		do
		
			echo "waiting for spotifyd daemon to start..."
			sleep 1
		
		done
		
# Nachdem spotifyd gestartet wurde callt die funktion sich selbst und sollte nun eigentlich
# zu dem Ergebnis kommen, dass spotifyd läuft.
		
		check_spotifyd
		
# Da spotifyd nun läuft, kann das pgrep -x vom Anfang erfolgreich abschließen und exited daher
# mit dem Exitstatus 0.
		
	elif [ $daemonEXITSTAT -eq 0 ] 
	then
		
		echo "spotifyd daemon is running | PID = $daemonPID"
		
# Ein if wird in Bash mit einem fi beendet.		
		
	fi
	
}

# Die folgende Funktion soll das Selbe tun wie die Vorherige nur mit dem Programm spt.

function check_spt() {

	echo "looking for spt"
	
	sptPID=$(pgrep -x spt)
	sptEXITSTAT=$?
	
	if [ $sptEXITSTAT -ne 0 ] 
	then
	
		echo "spt not running"
		echo "starting spt"
		
		spt &
		
		until sptPID=$(pgrep -x spt)
		do
		
			echo "waiting for spt to start..."
			sleep 1
		
		done
		
		check_spt
	
	elif [ $sptEXITSTAT -eq 0 ] 
	then
	
		echo "spt is running | PID = $sptPID"
	
	fi
	
}

# Hier fängt das eigentliche Porgramm an. Zuerst wird spotifyd gecheckt, dann spt

check_spotifyd
check_spt


echo "spotifyd checked, spt checked." 

# An dieser Stelle soll das Script warten, solange spt ausgeführt wird.

wait $sptPID

echo "spt closed"
echo "ending spotifyd deamon"

# Nachdem spt nicht länger ausgeführt wird, soll es noch den spotifyd daemon beenden
# und anschließend in den exitus gehen.


kill -15 $daemonPID

# Stattdessen startet es einmal spt und bleibt dann aber scheinbar in der check_spt Funktion hängen.
# Den Output was nach dem beenden von spt passiert, siehst du im Screenshot.
# Wenn ich danach in einem anderen Terminal noch einmal spt starte, scheint es den loop zu verlassen und den Rest
# entsprechend auszuführen. Der spotifyd daemon wird dann auf jeden Fall beendet.

echo "spotifyd daemon ended"
echo "exiting script"
