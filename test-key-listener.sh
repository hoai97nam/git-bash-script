#!/bin/bash

CONST_GIT_VERSION="1.8.5"
# Function to handle key presses
handle_key_press() {
    echo "press b and back to Main menu"
    local key
    while true; do
        # Read a single character
        read -rsn1 key
        case "$key" in
            a)
                echo "You pressed 'a'. Performing action A."
                ;;
            b)
                echo "Returning to menu."
                break
                ;;
            q)
                echo "You pressed 'q'. Quitting."
                exit 0
                ;;
            *)
                echo "You pressed '$key'. No action assigned."
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
    #     if (( "${version1_array[i]}" < "${version2_array[i]}" )); then
    #         echo "$st is older than $CONST_GIT_VERSION"
    #         retval="false"
    #         exit 0
    #     elif (( "${version1_array[i]}" > "${version2_array[i]}" )); then
    #         echo "$st is newer than $CONST_GIT_VERSION"
    #         retval="true"
    #         exit 0
    #     fi
    # done

    echo "$retval"
}
# get current branch
get_current_branch() {
    # Get Git version
    git_version=$(git --version | sed 's/.* \([0-9.]*\)\..*/\1/')
    retval=$( compare_version git_version )
    
    cd ../cloud-dev-project-3
    # Check Git version to determine the appropriate command to get current branch
    if [ "$retval" == "true" ]; then
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        if ! "$current_branch" > /dev/null; then
            echo "Error: Find your .git directory"
        fi
    else
        current_branch=$(git symbolic-ref --short HEAD)
    fi

    # Print current branch
    echo "Current branch: $current_branch"
}

# Checkout branch
check_base_branch() {
    local base_branch=$1
    retval="false"

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
        # echo ">>: $base_branch"
        is_branch_exist=$( check_base_branch "$base_branch" )
        echo ">>: $is_branch_exist"
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
    git checkout -b "$new_branch" "$base_branch"
    git push --set-upstream origin "$new_branch"

}
# Function to display the main menu
show_menu() {
    cd ../cloud-dev-project-3

    while true; do
        echo "Main Menu:"
        echo "1. Check git version"
        echo "2. Check current branch"
        echo "3. Checkout branch"
        echo "4. Checkout new branch"
        echo "5. Quit"
        echo "Enter your choice: "
        read -r choice
        case "$choice" in
            1)
                # echo "git version: "
                # handle_key_press
                clear
                show_git_version
                ;;
            2)
                echo "Check current branch."
                clear
                get_current_branch
                # exit 0
                ;;
            3)
                echo "Checkout branch."
                input_branch
                ;;
            4)
                echo "Checkout new branch."
                
                # exit 0
                ;;
            5)
                echo "Quitting."
                exit 0
                ;;
            *)
                echo "Invalid choice. Please try again."
                ;;
        esac
    done
}

# Start the script by showing the menu
show_menu
