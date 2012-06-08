#!/bin/sh

# Text color variables
txtred='\e[0;31m'       # red
txtgrn='\e[0;32m'       # green
txtylw='\e[0;33m'       # yellow
txtblu='\e[0;34m'       # blue
txtpur='\e[0;35m'       # purple
txtcyn='\e[0;36m'       # cyan
txtwht='\e[0;37m'       # white
bldred='\e[1;31m'       # red    - Bold
bldgrn='\e[1;32m'       # green
bldylw='\e[1;33m'       # yellow
bldblu='\e[1;34m'       # blue
bldpur='\e[1;35m'       # purple
bldcyn='\e[1;36m'       # cyan
bldwht='\e[1;37m'       # white
txtund=$(tput sgr 0 1)  # Underline
txtbld=$(tput bold)     # Bold
txtrst='\e[0m'          # Text reset

# Feedback indicators
export OK="${bldgrn} [OK] ${txtrst}"
export INFO="${bldwht} [INFO] ${txtrst}"
#export pass=${bldblu}*${txtrst}
export WARN="${bldylw} [WARN] ${txtrst}"
export ERROR="${bldred} [ERROR] ${txtrst}"

# Indicator usage
#echo -e "${INFO}"
#echo -e "${WARN}"



export REMOTE_ADDR="168.7.117.41"
export REMOTE=xl6@cai.cs.rice.edu
export REMOTE_TOP=/home/xl6/project3/project3_grading_instructions/
export PORT=12000

