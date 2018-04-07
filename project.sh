#!/bin/bash
# gra "Wisielec"

GREEN='\033[01;32m'
RED='\033[01;31m'
CYAN='\033[01;36m'
NONE='\033[00m'

BASE=$(pwd)

declare filename;
declare hangedManArray;
declare hiddenPasswordArray;

declare passwords;
declare password;

declare mistakesNum;
declare maxHP;
declare healthPoints;

declare letter;
declare guessed;
declare choice;


cd $(dirname $0)

# DIR1=$( dirname "${BASH_SOURCE[0]}")
# DIR2="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

help() {
    clear
    echo -e "####################################################### ";
    echo -e "#####################  WISIELEC ####################### ";
    echo -e "#######################################################\n\n";
    echo -e " Gra polega na odgadywaniu losowego hasla"
    echo -e " poprzez podawanie pojedynczych liter.\n"
    echo -e " Lista przykladowych hasel " 
    echo -e " z kategorii PRZEDMIOTY SZKOLNE " 
    echo -e " znajduje sie w pliku password.txt," 
    echo -e " ktory musi znajdowac sie w tym samym katalogu"
    echo -e " co program glowny.\n\n"
    exit	
}

for var in "$@"
do
	if [ $var == "-h" ] || [ $var == "--help" ];then
		help
	fi
done

#  pokazuje ukryte haslo: _ _ _ _ _
showPasswordArray() {
    for (( i=0; i<${#password}; i++ ));
    do
        echo -n "${hiddenPasswordArray[$i]} "
    done
    echo ""
}

# rysuje wisielca
drawHangedMan() {
    for i in {0..7}
    do
        echo -e "${RED} ${hangedManArray[$i]} ${NONE}"
    done
}

# aktualizuje rysunek wisielca
changeArrWhenBad() {
    ((mistakesNum++))
    healthPoints=$((maxHP-mistakesNum));

    echo -e "\n${RED}# Tracisz zycie!${NONE}"

    if [ $mistakesNum == 1 ]; then
        hangedManArray[7]="________\n";

    elif [ $mistakesNum == 2 ]; then
        for i in {0..6}
        do
            if [[ $i == 0 ]]; then
                hangedManArray[$i]="\n |";
            else
                hangedManArray[$i]="|";
            fi
        done
        hangedManArray[7]="|________\n";

    elif [ $mistakesNum == 3 ]; then
        hangedManArray[0]="\n ______";

    elif [ $mistakesNum == 4 ]; then
        hangedManArray[1]="|   ||";
        hangedManArray[2]="|   ||";

    elif [ $mistakesNum == 5 ]; then
        hangedManArray[3]="|   /\\";
        hangedManArray[4]="|   \/";

    elif [ $mistakesNum == 6 ]; then
        hangedManArray[5]="|   ||";

    elif [ $mistakesNum == 7 ]; then
        hangedManArray[5]="|  /||\\";

    elif [ $mistakesNum == 8 ]; then
        hangedManArray[0]=" ______"
        hangedManArray[1]="|   ||"
        hangedManArray[2]="|   ||"
        hangedManArray[3]="|   /\ "
        hangedManArray[4]="|   \/"
        hangedManArray[5]="|  /||\\ "
        hangedManArray[6]="|   /\ "
        hangedManArray[7]="|________\n"

        echo -e "${RED}\n###################### ";
        echo -e "###### GAME OVER #####";
        echo -e "######################\n${NONE}";

        drawHangedMan
        echo -e "Haslo: ${password}"
    else
        echo "Bad mistake number: ${mistakesNum}";
    fi
    
}

# wybor litery
chooseLetter() {
    # clear

    drawHangedMan
    echo -e "${CYAN}PUNKTY ZYCIA: ${healthPoints} ************${NONE}\n"
    
    showPasswordArray
    echo "";
    read -p 'Wybieram... ' letter;

    letter="$(tr [A-Z] [a-z] <<< "$letter")"
    

    if [[ $letter == [a-zA-Z] ]]; then
        local correct=0;
        for (( i=0; i<${#password}; i++ )); do
            if [[ $letter == ${password:$i:1} ]]; then
                correct=$((correct+=1));
            fi
        done

        if [[ $correct -gt 0 ]]; then
            # echo -e "\n\tZnaleziono ${letter}"
            echo -e "${GREEN}\n# DOBRZE !!!${NONE}";
            updateHiddenPassword $letter
            checkIfWin
        else
            changeArrWhenBad
        fi
        correct=0;

    else
        echo -e "\n${RED}# ${letter} to nie litera!${NONE}\n"
    fi
}

# update w przypadku odgadniecia litery
updateHiddenPassword() {
    local letter=$1

    for (( i=0; i<${#password}; i++ )); do

        if [[ $letter == ${password:$i:1} ]]; then
            hiddenPasswordArray[$i]=${letter};
        fi
    done
}

checkIfWin() {
    local finish=1

    for (( i=0; i<${#password}; i++ )); do
        if [[ ${hiddenPasswordArray[$i]} == "_" ]]; then
            finish=0
        fi
    done

    if [[ $finish -eq 1 ]]; then
        guessed=1

        echo -e "${GREEN}\n#################### ";
        echo -e "###### WYGRANA #####";
        echo -e "####################\n${NONE}";

        echo -e "HASLO: ${password}\n"

    fi
}

init() {
    ((mistakesNum=0))
    ((maxHP=8))
    ((healthPoints=$maxHP))
    ((guessed=0))

    for i in {0..7}
    do
        hangedManArray[$i]="";
    done

    loadPasswords

    if [[ ${#passwords[@]} != 0 ]]; then

        randomindex=$[ ( $RANDOM % ${#passwords[@]})]

        password=${passwords[$randomindex]}
        password="$(tr [A-Z] [a-z] <<< "$password")";

        for (( i=0; i<${#password}; i++ ));
        do


            if [[ ${password:$i:1} == " " ]]; then
                hiddenPasswordArray[$i]=" ";
            else
                hiddenPasswordArray[$i]="_";
            fi

            
            # echo -n "${hiddenPasswordArray[$i]} "
        done
    fi
}

newGame() {
    clear

    init

    while [[ "$healthPoints" -gt 0 && "$guessed" -eq 0 ]]
    do
        chooseLetter
    done

    echo -e -n "\n\tJeszcze raz? \nTAK -> t, \nNIE -> enter:\t"
    read choice;

    choice="$(tr [A-Z] [a-z] <<< "$choice")"

    if [[ $choice == "t" ]]; then
        newGame
    else
        exit
    fi
}

# check it!
loadPasswords() {

    # 
    #   plik z haslami
    # 
    filename="passwords.txt"
 

    local i=0

    if [ ! -f ${filename} ]; then
        echo -e "\nNie odnaleziono pliku ${filename}"
        exit
    else
        while read -r line
        do
            passwords[$i]="$line"
            ((i++))
        done < "$filename"
      
    fi
}

newGame