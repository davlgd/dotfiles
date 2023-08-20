gi() {

    # Check if required tools are available
    check "git" quiet || return
    check "whiptail" quiet || return

    # Check if the current directory is a git repository
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo -n "The current directory is not a git repository. Do you want to initialize it? (Y/n) "
        read choice

        case $choice in
            [YyoO]* )
                git init
                echo "Git repository initialized."
                echo
                ;;
            [Nn]* )
                echo "Operation cancelled."
                return
                ;;
            * )
                echo "Unrecognized response."
                return
                ;;
        esac
    fi
    
    # Define your identities
    local IDENTITIES=("Jean Dupont,jean.dupont@example.com"
                      "Marie Durand,marie.durand@example.net"
                      "Pierre Martin,pierre.martin@example.org")

    # Dynamically generate the whiptail menu
    local MENU_OPTIONS=()
    local INDEX=1
    for IDENTITY in "${IDENTITIES[@]}"; do
        MENU_OPTIONS+=("$INDEX" "${IDENTITY/,/ <}>")
        INDEX=$((INDEX+1))
    done

    local CHOICE=$(whiptail --title "Identity Selection" --menu "Choose an identity" 20 78 10 \
    "${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3)

    # Determine shell offset for array indexing
    local SHELL_OFFSET=0
    local CURRENT_SHELL=$(ps -p $$ -ocomm=)
    if [[ "$CURRENT_SHELL" == "zsh" ]]; then
        SHELL_OFFSET=1
    fi

    # Adjust CHOICE based on the shell offset
    CHOICE=$((CHOICE - 1 + SHELL_OFFSET))

    # Exit if the user cancels
    if [ $? != 0 ]; then
        echo "Selection cancelled."
        return
    fi

    # Extract the name and email from the chosen identity
    local CHOSEN_IDENTITY="${IDENTITIES[$CHOICE]}"
    local NAME=$(echo "$CHOSEN_IDENTITY" | cut -d"," -f1)
    local EMAIL=$(echo "$CHOSEN_IDENTITY" | cut -d"," -f2)

    # Configure git with the chosen identity
    git config user.name "$NAME"
    git config user.email "$EMAIL"

    echo "Identity configured for git:"
    echo "- Name: $NAME"
    echo "- Email: $EMAIL"
}