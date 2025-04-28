#!/bin/bash

source ./core/painter.sh
source ./core/checkers.sh
source ./core/preferences.sh
source ./core/utilities.sh

set -euo pipefail


# shellcheck disable=SC2120
create_flutter_application(){
    # Prompt user for output directory input, but default to $OUTPUT_DIR if provided
    read -rp "Enter output directory (default: $OUTPUT_DIR): " USER_INPUT

    # If the user provided an input, use it. Otherwise, keep the default $OUTPUT_DIR
    OUTPUT_DIR="${USER_INPUT:-$OUTPUT_DIR}"
    export PROJECT_PATH="$OUTPUT_DIR/$PROJECT_NAME"

    # Check if the directory exists, if not, create it
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        info "Creating directory: ${UNDER}$OUTPUT_DIR${RESET}"
        mkdir -p "$OUTPUT_DIR"  # Creates the directory and any necessary parent directories
    fi

    # Create the Flutter project
    flutter create \
        --template="$TEMPLATE" \
        --project-name="$PROJECT_NAME" \
        --org="$ORG" \
        --description="$DESCRIPTION" \
        --platforms="$(echo "${PLATFORMS// /,}")" \
        --android-language="$ANDROID_LANG" \
        "$OUTPUT_DIR/$PROJECT_NAME"

    success "Flutter project created at ${GREEN}$OUTPUT_DIR${RESET}"

}

finalize(){
    # 16) Open in VS Code
    if command -v code >/dev/null 2>&1; then
        info "📂 Opening in VS Code..."
        cd "$OUTPUT_DIR/$PROJECT_NAME" && code .
    else
        success "🎉 Done! Run: 'cd $OUTPUT_DIR/$PROJECT_NAME' and open in your favorite IDE!"
    fi

    return 0
}

paint_intro
check_dependencies

take_preferences

create_flutter_application

update_files

finalize