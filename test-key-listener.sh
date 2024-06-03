#!/bin/bash
 
CONST_GIT_VERSION="1.8.5"
# Function to handle key presses
handle_key_press() {
    echo "press Enter to back to Main menu"
    local options=("1. Listen for key presses" "2. Returning to menu" "3. Quit")
 
    local key
    while true; do
        # Read a single character
        # clear
        read -rsn1 key
        case "$key" in
            "")  # Enter key
                break
                case $current_selection in
                    0)
                        echo "Listening for key presses. Press 'b' to go back to the menu, 'q' to quit."
                        # handle_key_press
                        ;;
                    1)
                        echo "Returning to menu."
                        break
                        ;;
                    2)
                        echo "Quitting."
                        exit 0
                        ;;
                esac
                ;;
        esac
    done
}
 
# Get git version
show_git_version() {
    git --version
    handle_key_press
}
# compare version
compare_version() {
    st=$1
    retval="true"
    IFS='.' read -r -a version1_array <<< "$st"
    IFS='.' read -r -a version2_array <<< "$CONST_GIT_VERSION"
 
    # Compare each component of the version number
    # for (( i=0; i<${#version2_array[@]}; i++ )); do
    #     if (( "${version1_array[i]}" < "${version2_array[i]}" )); then
    #         echo "$st is older than $CONST_GIT_VERSION"
    #         retval="false"
    #         exit 0
    #     elif (( "${version1_array[i]}" > "${version2_array[i]}" )); then
    #         echo "$st is newer than $CONST_GIT_VERSION"
    #         retval="true"
    #         exit 0
    #     fi
    # done
 
    echo "$retval"
}
# get current branch
get_current_branch() {
    # Get Git version
    git_version=$(git --version | sed 's/.* \([0-9.]*\)\..*/\1/')
    retval=$( compare_version git_version )
   
    # Check Git version to determine the appropriate command to get current branch
    if [ "$retval" == "true" ]; then
        current_branch=$( git rev-parse --abbrev-ref HEAD )
    else
        current_branch=$( git symbolic-ref --short HEAD )
    fi
 
    # Print current branch
    echo "<<Current branch>>: $current_branch"
}
 
# Checkout branch
check_base_branch() {
    local base_branch=$1
    retval="false"
    # Check if the base branch already exists
    if git rev-parse --quiet --verify "$base_branch" > /dev/null; then
        retval="true"
    fi
    echo "$retval"
}
 
check_new_branch() {
    new_branch=$1
    retval="false"
    # Check if the new branch already exists
    if ! git rev-parse --quiet --verify "$new_branch" > /dev/null; then
        retval="true"
    fi
    echo "$retval"
}
 
# Loop for input branch
input_branch() {
    base_branch_existed=0
    new_branch_existed=0
    base_branch=""
    new_branch=""
    while [ "$base_branch_existed" -eq 0 ]; do
        read -r -p "Input base branch: " base_branch
        is_branch_exist=$( check_base_branch "$base_branch" )
        if [ "$is_branch_exist" == "true" ]; then
            # echo "yessss"
            base_branch_existed=1
        fi
    done
    # check new branch
    while [ "$new_branch_existed" -eq 0 ]; do
        read -r -p "Input new branch: " new_branch
        is_branch_exist=$( check_new_branch "$new_branch" )
        echo ">>: $is_branch_exist"
        if [ "$is_branch_exist" == "true" ]; then
            echo "yessss"
            new_branch_existed=1            
        fi
    done
    git fetch
    git pull origin
    git checkout -b "$new_branch" "$base_branch"
    git push --set-upstream origin "$new_branch"
    handle_key_press
 
}
 
# Delete existing branch
delete_branch() {
    break_loop="false"
    current_branch=$( git rev-parse --abbrev-ref HEAD )
    # read -r -p "Input branch to be delete: " delete_branch
    while [ "$break_loop" == "false" ]; do
        read -r -p "Input branch to be delete: " delete_branch
        is_branch_exist=$( check_base_branch "$delete_branch" )
        if [ "$is_branch_exist" == "true" ] && [ "$current_branch" != "$delete_branch" ]; then
            git branch -d $delete_branch
            echo "Branch '$delete_branch' deleted successfully."
            break_loop="true"
        else
            echo "Branch '$delete_branch' does not exist."
        fi
    done
    handle_key_press
}
 
# Switch branch
switch_branch() {
    read -r -p "Input branch to be switched: " target_branch
    is_branch_exist=$( check_base_branch "$target_branch" )
    if [ "$is_branch_exist" == "true" ]; then
        git checkout $target_branch
        echo "Branch '$target_branch' switched successfully."
        break_loop="true"
    else
        echo "Branch '$target_branch' does not exist."
    fi
    handle_key_press
}
# Function to display the main menu
show_menu() {
    # cd ../cloud-dev-project-3
    local options=("1. Check git version" "2. Check current branch" "3. Checkout branch" "4. Delete branch" "5. Checkout branch" "6. Quit")
    local current_selection=0
 
    while true; do
        clear
        echo "Main Menu:"
        for i in "${!options[@]}"; do
            if [[ $i -eq $current_selection ]]; then
                echo -e ">> ${options[$i]^^}"
            else
                echo "  ${options[$i]}"
            fi
        done
 
        read -rsn1 key
        case "$key" in
            $'\x1b')  # ESC
                read -rsn2 key
                if [[ $key == "[A" ]]; then
                    ((current_selection--))
                    if [[ $current_selection -lt 0 ]]; then
                        current_selection=$((${#options[@]} - 1))
                    fi
                elif [[ $key == "[B" ]]; then
                    ((current_selection++))
                    if [[ $current_selection -ge ${#options[@]} ]]; then
                        current_selection=0
                    fi
                fi
                ;;
            "")  # Enter key
                case $current_selection in
                    0)
                        clear
                        show_git_version
                        ;;
                    1)
                        echo "Check current branch."
                        clear
                        get_current_branch
                        handle_key_press
                        # exit 0
                        ;;
                    2)
                        echo "Checkout branch."
                        input_branch
                        ;;
                    3)
                        echo "Delete branch."
                        delete_branch
                        # exit 0
                        ;;
                    4)
                        echo "Checkout branch."
                        switch_branch
                        ;;
                    5)
                        echo "Quitting."
                        exit 0
                        ;;
                        esac
                        ;;
        esac
    done
}
 
# Start the script by showing the menu
show_menu