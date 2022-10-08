#!/usr/bin/env bash

# June 2020

# nr colors; nr places; nr attempts without duplicates; nr attempts with duplicates
levels=( \
    5 3 4 5 \
    6 3 5 5 \
    7 3 6 6 \
    8 3 6 6 \
    4 4 5 5 \
    5 4 5 5 \
    6 4 6 6 \
    7 4 6 6 \
    8 4 6 7 \
    5 5 6 6 \
    6 5 6 6 \
    7 5 7 7 \
    8 5 7 7 \
    6 6 7 7 \
    7 6 7 7 \
    8 6 8 8 \
    7 7 8 8 \
    8 7 8 8 \
    8 8 8 8 )
nconfigs=4 # number of configuration items (columns) in levels variable
nrlevels=$((${#levels[@]}/nconfigs))

pieces=( '\e[1;31mR' '\e[1;32mG' '\e[1;33mY' '\e[1;34mB' '\e[1;35mM' '\e[1;36mC' '\e[1;97mW' '\e[1;90mD' )
empty='\e[1;37m.'

level=0; score=0; duplicates=0; congratmessage=1

yoffset=9

function newgame(){

    local i piece pad border
    local ny=( 'N' 'Y' )

    unset code selection start

    clear

    nrpieces=${levels[nconfigs*level]}
    nrplaces=${levels[nconfigs*level+1]}
    nrattempts=$(( duplicates?${levels[nconfigs*level+3]}:${levels[nconfigs*level+2]} ))
    column=0; attempt=0; status=1

    for ((i=0;i<nrplaces;i++)); do
        while :; do
            piece=${pieces[RANDOM%nrpieces]}
            (( duplicates )) || [[ ! " ${code[@]} " =~ " $piece " ]] && break
        done
        code[i]=$piece; selection[i]=$empty
    done

    padding=$(( nrplaces-nrpieces+2 )); padding=$(( padding>0?padding:0 ))
    pad=''; for ((i=0;i<padding;i++)); do pad+=' '; done
    border='\e[0m+'; for ((i=0;i<nrpieces;i++)); do border+='-+'; done
    piecesstring="$pad$border\n$pad|"
    for ((i=0;i<nrpieces;i++)); do piecesstring+="${pieces[i]}\e[0m|"; done
    piecesstring+="\n$pad$border"

    echo -e "\e[1;93m>> BASHTERMIND <<\e[0m"
    echo -e "rgybmcwd#:place"
    echo -e ".:remove enter:submit"
    echo -e "x:restart q:quit"
    echo -e "\e[1;35mlvl:$((level+1)) score:$score"
    echo -e "duplicates:${ny[duplicates]}"
    echo -e "$piecesstring"
    for ((i=0;i<nrattempts;i++)); do echo -e "\e[0m  \e[1;40m ${selection[@]} "; done
    tput 'cup' $((yoffset+attempt)) 0; echo -e '\e[0m>>'

}

function selectmode(){

    local choices=( '\e[1m  Yes  [No] \e[0m' '\e[1m [Yes]  No  \e[0m' )

    clear

    echo -e "\e[1;93m>> BASHTERMIND <<\e[0m\n\nallow duplicates?"
    while :; do
        tput 'cup' 3 0; echo -e "${choices[duplicates]}"
        read -s -n 1 action
        case "$action" in
            'h'|'l'|'D'|'C') duplicates=$((duplicates?0:1)) ;;
            'y') duplicates=1; break ;;
            'n') duplicates=0; break ;;
            '') break ;;
            'q') nrattempts=0; yoffset=5; exit ;;
        esac
    done

}

function putpiece(){

    local piece i j

    [ "$start" ] || start=$(date +%s)

    if [[ $1 =~ ^[1-8]$ ]]; then
        (( $1>nrpieces )) && return
        j=$(($1-1))
        piece=${pieces[j]}
    else
        for piece in "${pieces[@]}"; do [[ ${piece,,} =~ $1$ ]] && break; done
        for ((j=0;j<nrpieces;j++)); do [[ "${pieces[j]}" == "$piece" ]] && break; done
        (( j>=nrpieces )) && return
    fi

    if [ ${selection[column]} == $piece ]; then
        if (( duplicates==0 )); then
            tput 'cup' $((yoffset-2)) $((2*j+1+padding)); echo -e "\e[0m$piece"
        fi
        selection[column]=$empty
    else
        if (( duplicates==0 )); then
            tput 'cup' $((yoffset-2)) $((2*j+1+padding)); echo -e "\e[0m "
            removepiece
            for ((i=0;i<nrplaces;i++)); do
                if [ ${selection[i]} == $piece ]; then
                    selection[i]=$empty
                    tput 'cup' $((yoffset+attempt)) $((2*i+3)); echo -e "\e[40m$empty"
                    break
                fi
            done
        fi
        selection[column]=$piece
    fi

}

function removepiece(){

    local j

    if [ ${selection[column]} != $empty ]; then
        for ((j=0;j<nrpieces;j++)); do [ ${pieces[j]} == ${selection[column]} ] && break; done
        if (( duplicates==0 )); then
            tput 'cup' $((yoffset-2)) $((2*j+1+padding)); echo -e "\e[0m${pieces[j]}"
        fi
        selection[column]=$empty
    fi

}

function submit(){

    local i j
    local correctplace correctcolor codecopy piece

    [[ "${selection[@]}" =~ "$empty" ]] && return

    codecopy=(${code[@]})
    correctplace=0; correctcolor=0
    for ((i=nrplaces-1;i>=0;i--)); do
        if [ "${selection[i]}" == "${code[i]}" ]; then
            (( correctplace++ ))
            unset selection[i] codecopy[i]
        fi
    done
    for piece in "${selection[@]}"; do
        for ((j=0;j<nrplaces;j++)); do
            if [ "${codecopy[j]}" == "$piece" ]; then
                (( correctcolor++ ))
                unset codecopy[j]
                break
            fi
        done
    done
    tput 'cup' $((yoffset+attempt)) $((2*nrplaces+4)); echo -e "\e[1;97;42m $correctplace \e[104m $correctcolor \e[0m"
    
    if (( correctplace==nrplaces )); then
        success
    elif (( attempt==nrattempts-1 )); then
        failed
    else
        for ((i=0;i<nrplaces;i++)); do selection[i]=$empty; done
        if (( duplicates==0 )); then
            tput 'cup' $((yoffset-3)) 0; echo -e "$piecesstring"
        fi
        tput 'cup' $((yoffset+attempt)) 0; echo -e "\e[0m  "
        column=0
        (( attempt++ ))
        tput 'cup' $((yoffset+attempt)) 0; echo -e "\e[0m>>"
    fi

}

function success(){

    local points pad congrats i

    points=$((nrattempts-attempt))
    pad=''; for ((i=0;i<12-${#score}-${#points};i++)); do pad+=' '; done
    tput 'cup' 1 0
    echo -e "\e[0;1;32m+---------------------+"
    if ((attempt>1)); then echo -e "|  :D Success! ...    |"; else echo -e "|  ;) Lucky bastard!  |"; fi
    echo -e "|  time:$(date -d@$(($(date +%s) - $start)) -u +%Hh%Mm%Ss)     |"
    echo -e "|  score:$score+$points$pad|"
    echo -e "|  \e[4mn\e[0;1;32m:next   s:select  |"
    echo -e "|  x:replay z:random  |"
    echo -e "|  q:quit             |"
    echo -e "+---------------------+"
    (( score+=points ))

    completed[nrlevels*duplicates+level]=1
    if ((congratmessage)) && [[ ! "${completed[@]}" =~ 0 ]]; then
        pad='    '
        congrats="\e[1;5;33m     () () () ()\e[25m      $pad\n    "
        for ((i=0;i<4;i++)); do congrats+="\e[21;34m_\e[0;1m||"; done; congrats+="\e[21;34m_     $pad\n"
        congrats+="   \e[21;34m/\e[36m~~~~~~~~~~~~~\e[21;34m\    $pad\n  "
        for ((i=0;i<8;i++)); do congrats+="\e[34m@\e[32m#"; done; congrats+="\e[34m@   $pad\n  \e[36m{"
        for ((i=0;i<7;i++)); do congrats+="\e[34m'\e[36m-"; done; congrats+="\e[34m'\e[36m}   $pad\n"
        for ((i=0;i<10;i++)); do congrats+="\e[32mo\e[36m~"; done;
        congrats+="\e[32mo $pad\n\e[36m)   \e[33m*     *     *   \e[36m( $pad\n"
        congrats+="\e[36m) \e[1;5mCONGRATULATIONS!! \e[25;36m( $pad\n"
        congrats+="\e[36m)   \e[33m*     *     *   \e[36m( $pad\n"
        congrats+="\e[0;1m===================== $pad\n"
        congrats+="      _)_____(_       $pad\n"
        congrats+="     /_________\      \e[1;33m$pad\n"
        congrats+="all levels completed!!$pad\n\e[35mscore:\e[5m$score\e[0m$pad$pad$pad$pad$pad"
        echo -e "$congrats"
        ((congratmessage--))
        nrattempts=14 # trick for proper prompt placement upon quit
    fi

    status=0
    while :; do
        read -s -n 1 action
        case "$action" in
            'x') newgame; break ;;
            's') selectlevel; break ;;
            'n'|'') if ((level==nrlevels-1)); then if ((duplicates==0)); then duplicates=1; level=0; fi; else ((level++)); fi; newgame; break ;;
            'z') level=$((RANDOM%nrlevels)); duplicates=$((RANDOM%2)); newgame; break ;;
            'q') break ;;
        esac
    done

}

function failed(){

    local i placestring

    tput 'cup' 1 0
    echo -e "\e[0;1;31m+------------------+ "
    echo -e "|                  | "
    echo -e "|  :'( Failed ...  | "
    echo -e "|                  | "
    echo -e "|  \e[4mx\e[0;1;31m:retry q:quit  | "
    echo -e "|                  | "
    echo -e "+------------------+ "
    echo -e "                     "

    showcode

    while :; do
        read -s -n 1 action
        case "$action" in
            'x'|'') newgame; break ;;
            'q') ((status--)); ((yoffset+=3)); break ;;
        esac
    done

}

function showcode(){

    border='\e[0m  +'; for ((i=0;i<nrplaces;i++)); do border+='-+'; done
    placestring="$border\n>>|"
    for ((i=0;i<nrplaces;i++)); do placestring+="${code[i]}\e[0m|"; done
    placestring+="\n$border"

    tput 'cup' $((yoffset+attempt)) 0; echo -e "\e[0m  "
    tput 'cup' $((yoffset+nrattempts)) 0; echo -e "$placestring"

}

function selectlevel(){

    tput 'cup' $((yoffset-4)) 0
    echo -e "\e[0;1;32m+-------------------+"
    echo -e "|  select level:    |"
    echo -e "|  >>               |"
    echo -e "+-------------------+"

    int='^[1-9][0-9]*$'
    tput cnorm
    stty echo
    while :; do
        tput 'cup' $((yoffset-2)) 0
        echo -e "\e[0;1;32m|  >>               |"
        tput 'cup' $((yoffset-2)) 6
        read level
        if [[ "$level" =~ $int ]]; then
            ((level>nrlevels)) && level=$((nrlevels))
            ((level--))
            break
        fi
    done
    tput civis
    stty -echo

    newgame

}

function cleanup(){

    if (( status==0 )); then
        tput 'cup' $((yoffset+nrattempts)) 0; echo -n $'\e[0m'
    else
        tput 'cup' $((yoffset+attempt)) 0; echo -e "\e[0m  "
        tput 'cup' $((yoffset+attempt)) $((2*column+2)); echo -e "\e[1;40m ${selection[column]} \e[0m"
        tput 'cup' $((yoffset+nrattempts)) 0; echo -n $'\e[0m'
        if (( attempt>0 )) || [[ ${selection[@]} =~ [RGYBMCWD] ]]; then
            showcode
        fi
    fi
    stty echo
    tput cnorm
    exit

}

# main loop

trap cleanup EXIT INT

stty -echo
tput civis

for ((i=0;i<2*nrlevels;i++)); do completed[i]=0; done
selectmode
newgame

while ((status)); do

    tput 'cup' $((yoffset+attempt)) $((2*column+2))
    echo -e "\e[1;40;97m[${selection[column]}\e[1;40;97m]"

    read -s -n 1 action

    tput 'cup' $((yoffset+attempt)) $((2*column+2))
    echo -e " ${selection[column]} \e[0m"

    case "$action" in
        'h'|'D') (( column>0?column--:0 )) ;;
        'l'|'C') (( column<nrplaces-1?column++:nrplaces-1 )) ;;
        'r'|'g'|'y'|'b'|'m'|'c'|'w'|'d'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8') putpiece $action ;;
        '.'|',') removepiece ;;
        '') submit ;;
        'x') newgame ;;
        's') selectlevel ;;
        'z') level=$((RANDOM%nrlevels)); duplicates=$((RANDOM%2)); newgame ;;
        'q') break ;;
    esac

done

