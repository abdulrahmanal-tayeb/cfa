#!/bin/bash

source ./core/utilities.sh

if [[ -z "$CHECKERS_SH_SOURCED" ]]; then
    export CHECKERS_SH_SOURCED=true;

    check_dependencies(){
        check_flutter
        check_android_sdk
        check_vscode
    }

    check_flutter() {
        # Check Flutter Existance
        command -v flutter >/dev/null 2>&1 || {
            error 'flutter' not in PATH. Install Flutter first.;
            exit 1; 
        }

        success "⚙️  Flutter detected."
    }


    check_vscode(){
        if ! command -v code >/dev/null 2>&1; then
            info "'code' not in PATH — VS Code opening will be skipped."
        fi
    }


    check_android_sdk() {
        echo "🔍 Checking for Android SDK..."

        local sdk_dir=""
        local common_paths=(
            "$HOME/Android/Sdk"
            "$HOME/Library/Android/sdk"
            "/usr/local/android-sdk"
            "/opt/android-sdk"
        )

        # Check environment variables first
        if [[ -n "${ANDROID_SDK_ROOT:-}" && -d "$ANDROID_SDK_ROOT" ]]; then
            sdk_dir="$ANDROID_SDK_ROOT"
        elif [[ -n "${ANDROID_HOME:-}" && -d "$ANDROID_HOME" ]]; then
            sdk_dir="$ANDROID_HOME"
        else
            # Try common installation paths
            for path in "${common_paths[@]}"; do
                if [[ -d "$path" ]]; then
                    read -rp "Found SDK at '$path'. Use this path? [Y/n]: " response
                    response="${response:-Y}"
                    if [[ "$response" =~ ^[Yy]$ ]]; then
                        sdk_dir="$path"
                        break
                    fi
                fi
            done
        fi

        # If still not found, ask user
        while [[ -z "$sdk_dir" ]]; do
            read -rp "Enter Android SDK path (or export ANDROID_SDK_ROOT): " sdk_dir
            if [[ ! -d "$sdk_dir" ]]; then
                warning "'$sdk_dir' is not a valid directory."
                sdk_dir=""
            fi
        done

        success "Using Android SDK at: $sdk_dir"
        export ANDROID_SDK_ROOT="$sdk_dir"
    }
fi