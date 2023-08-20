reload() {
    local C_SHELL=$(ps -p $$ -o comm=)

    if [ "$C_SHELL" = "bash" ]; then
        exec bash
    elif [ "$C_SHELL" = "zsh" ]; then
        exec zsh
    else
        echo "Shell not recognized"
    fi
}

mkcd() {
    mkdir -p $1
    cd $1
}

# Helper function to check if a command is available
# $1 is the name of the application to check
# $2 is an optional parameter. If set to `quiet`, no message will be shown if the application is found
check() {
    if command -v '$1' >/dev/null 2>&1; then
        if [ '$2' != 'quiet' ]; then
            echo '$1 is installed on the system.'
        fi
        return 0
    else
        echo 'Error: $1 is not installed on the system.'
        return 1
    fi
}

checksite() {
    if curl --output /dev/null --silent --head --fail '$1'; then
        echo 'Le site $1 est en ligne'
    else
        echo 'Le site $1 est hors ligne'
    fi
}

weather() {
    if [[ '$2' == '--full' ]]; then
        curl 'wttr.in/$1'
    else
        curl 'wttr.in/$1?format=2'
    fi
}

snapclean() {
    sudo snap list --all | awk '/désactivé/{print $1, $3}' | while read snapname revision; do sudo snap remove '$snapname' --revision='$revision'; done
}

pg() {
    length=32

    # If an argument is provided and it's a number between 12 and 128, use it as the password length
    if [ "$1" -ge 12 ] && [ "$1" -le 128 ] 2>/dev/null; then
        length=$1
    fi

    # Generate a random password of the specified length
    password=$(gpg --gen-random --armor 2 $length | head -c $length)

    # Check if xclip or gpate are installed and use it to copy the password to the clipboard
    if command -v xclip > /dev/null 2>&1; then
        echo $password | xclip -selection clipboard
        echo -e "\033[32m✓\033[0m Password copied to clipboard"
    elif command -v gpaste-client > /dev/null 2>&1; then
        echo $password | gpaste-client
        echo -e "\033[32m✓\033[0m Password copied to clipboard"
    else
        echo "Neither xclip nor gpaste are installed."
    fi
}

bigapt() {
    dpkg-query -W --showformat='${Installed-Size}\t${Package}\t${Status}\n' | grep "install ok installed" | \
    sort -n | awk 'BEGIN { split("K M G", unit); mult=1024; } { size=$1; u=1; while(size>mult) { size/=mult; u++ } printf("%.2f%sB\t%s\n", size, unit[u], $2); }' | \
    tail -n 20 | tac
}
