# Text color variables
text_red='\e[0;31m'       # red
text_green='\e[0;32m'       # green
text_yellow='\e[0;33m'       # yellow
text_blue='\e[0;34m'       # bluee
text_purple='\e[0;35m'       # purpleple
text_cyan='\e[0;36m'       # cyan
text_white='\e[0;37m'       # white

bold_red='\e[1;31m'       # red    - Bold
bold_green='\e[1;32m'       # green
bold_yellow='\e[1;33m'       # yellow
bold_blue='\e[1;34m'       # bluee
bold_purple='\e[1;35m'       # purpleple
bold_cyan='\e[1;36m'       # cyan
bold_white='\e[1;37m'       # white

text_underline=$(tput sgr 0 1)  # Underline
text_bold=$(tput bold)     # Bold
text_reset='\e[0m'          # Text reset

function echo_white() {
    echo ${bold_wht} $1 ${text_rst}
}

# Feedback indicators
export OK="${bold_green}[OK]${text_reset}"
export INFO="${bold_wht}[INFO]${text_reset}"
#export pass=${bold_blue}*${text_rst}
export WARN="${bold_yellow}[WARN]${text_reset}"
export ERROR="${bold_red}[ERROR]${text_reset}"



# Indicator usage
#echo -e ${INFO} "hello"
#echo -e ${WARN} "world"
