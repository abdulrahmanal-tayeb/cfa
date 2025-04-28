#!/bin/bash

source ./core/utilities.sh
source ./core/validators.sh
source ./core/defaults.sh

if [[ -z "$PREFERENCES_SH_SOURCED" ]]; then 
    export PREFERENCES_SH_SOURCED=true;
    
    take_preferences(){
        # User Input
        project_name
        project_display_name
        project_reverse_dns
        project_description

        # Selectable
        select_project_template
        select_project_platforms
        select_project_native_languages
        select_project_ndk
        select_project_jdk
        select_project_gradle
    }

    update_files(){
        update_project_android_manifest
        update_project_build_gradle
        update_project_gradle_properties
        update_project_grandle_wrapper
        update_project_info_plist
    }


    project_name(){
        while :; do
            read -rp "Project name [$DEFAULT_NAME]: " NAME
            NAME=${NAME:-$DEFAULT_NAME}
            if [[ ! $NAME =~ ^[a-z_][a-z0-9_]*$ ]]; then
                error "Use [a-z0-9_], start with letter/_." 0; continue
            fi
            if is_reserved "$NAME"; then
                error "'$NAME' is reserved." 0; continue
            fi
            export PROJECT_NAME="$NAME"; break
        done

        # Update Display Name
        export DEFAULT_DISP="$(echo "$PROJECT_NAME" \
        | sed -E 's/_/ /g; s/(^| )([a-z])/\1\U\2/g')"
    }

    project_display_name(){
        read -rp "Display name [$DEFAULT_DISP]: " DISPLAY_NAME
        export DISPLAY_NAME=${DISPLAY_NAME:-$DEFAULT_DISP}
    }

    project_reverse_dns(){
        # Org & desc
        read -rp "Organization (reverse-DNS) [com.example]: " ORG
        export ORG=${ORG:-com.example}
    }

    project_description(){
        read -rp "Description [A new Flutter project.]: " DESCRIPTION
        export DESCRIPTION=${DESCRIPTION:-A new Flutter project.}
    }

    select_project_template(){
        # 4) Template
        echo; TEMPLATES=(app module package plugin)
        info "Select Your Project's Template:"
        select TEMPLATE in "${TEMPLATES[@]}"; do
            [[ -n $TEMPLATE ]] && break
            echo "→ Choose 1-${#TEMPLATES[@]}."
        done

        export TEMPLATE="${TEMPLATE}";
    }

    select_project_platforms(){
        # 5) Platforms
        echo; PLATTS=(android ios web linux macos windows)
        echo "Select platforms (space-separated numbers, e.g. 1 2):"
        for i in "${!PLATTS[@]}"; do printf "  %2d) %s\n" $((i+1)) "${PLATTS[i]}"; done
        read -rp "Platforms [1 2]: " -a IDX

        LIST=()
        for i in "${IDX[@]}"; do
        ((i>=1&&i<=${#PLATTS[@]})) && LIST+=("${PLATTS[i-1]}")
        done

        # Defaults to Android and IOS (Mobile only)
        [ ${#LIST[@]} -eq 0 ] && LIST=(android ios)

        export PLATFORMS="${LIST[*]}"
    }

    select_project_native_languages(){

        read -rp "Android language [kotlin]: " ANDROID_LANG
        export ANDROID_LANG=${ANDROID_LANG:-kotlin}

        # Deperecated (Always Swift)
        # read -rp "IOS language [swift]: " IOS_LANG
        # export IOS_LANG=${IOS_LANG:-swift}

    }

    select_project_ndk() {
        # 7) NDK Selection (default = first available)
        NDK_BASE="$ANDROID_SDK_ROOT/ndk"

        # Check if NDK base directory exists
        if [[ ! -d $NDK_BASE ]]; then
            error "$NDK_BASE missing."
        fi

        # Get list of available NDK versions
        NDK_VERSIONS=( "$NDK_BASE"/* )

        # Display available NDK versions
        echo
        info "NDK versions:"
        for idx in "${!NDK_VERSIONS[@]}"; do
            printf "  %2d) %s\n" $((idx + 1)) "${NDK_VERSIONS[idx]##*/}"
        done

        # Prompt for NDK selection
        read -rp "Select NDK [1]: " selection
        selection=${selection:-1}

        # Ensure selection is valid
        if ((selection < 1 || selection > ${#NDK_VERSIONS[@]})); then
            selection=1
        fi

        # Set the selected NDK version
        export SELECTED_NDK="${NDK_VERSIONS[selection - 1]##*/}"
        info "→ Selected NDK: $SELECTED_NDK"
    }

    select_project_jdk() {
        # 8) JDK Selection (default = JAVA_HOME or first available)
        JVM_DIR="/usr/lib/jvm"
        
        # Check if JVM directory exists
        if [[ ! -d $JVM_DIR ]]; then
            error "$JVM_DIR missing."
        fi

        # Get list of available JDK versions
        JDK_VERSIONS=( "$JVM_DIR"/* )

        # Display available JDK versions
        echo
        info "JDK versions:"
        for idx in "${!JDK_VERSIONS[@]}"; do
            printf "  %2d) %s\n" $((idx + 1)) "${JDK_VERSIONS[idx]##*/}"
        done

        # Find default JDK index based on JAVA_HOME
        default_jdk=1
        if [[ -n "${JAVA_HOME:-}" ]]; then
            for idx in "${!JDK_VERSIONS[@]}"; do
                if [[ "${JDK_VERSIONS[idx]}" == "$JAVA_HOME" ]]; then
                    default_jdk=$((idx + 1))
                    break
                fi
            done
        fi

        # Prompt for JDK selection
        read -rp "Select JDK [$default_jdk]: " selection
        selection=${selection:-$default_jdk}

        # Ensure selection is valid
        if ((selection < 1 || selection > ${#JDK_VERSIONS[@]})); then
            selection=$default_jdk
        fi

        # Set the selected JDK version
        export SELECTED_JDK="${JDK_VERSIONS[selection - 1]}"
        info "→ Selected JDK: $SELECTED_JDK"
    }

    select_project_gradle() {
        # 9) Gradle Selection (from ~/.gradle/wrapper/dists or fallback list)

        # Get the list of available Gradle distributions
        GRADLE_DISTS=( ~/.gradle/wrapper/dists/gradle-*-all )
        DIST_LIST=()

        # Filter out valid directories and add to DIST_LIST
        for dist in "${GRADLE_DISTS[@]}"; do
            if [[ -d $dist ]]; then
                DIST_LIST+=("$(basename "$dist")")
            fi
        done

        # If no distributions found, fall back to default list
        if [[ ${#DIST_LIST[@]} -eq 0 ]]; then
            DIST_LIST=( gradle-8.3-all gradle-8.2-all gradle-8.1.1-all gradle-8.10.2-all )
        fi

        # Display available Gradle distributions
        echo
        info "Gradle distributions:"
        for idx in "${!DIST_LIST[@]}"; do
            printf "  %2d) %s\n" $((idx + 1)) "${DIST_LIST[idx]}"
        done

        # Prompt for Gradle selection with default as 1
        read -rp "Select Gradle [1]: " gradle_selection
        gradle_selection=${gradle_selection:-1}

        # Ensure the selected index is valid
        if ((gradle_selection < 1 || gradle_selection > ${#DIST_LIST[@]})); then
            gradle_selection=1
        fi

        # Set the selected Gradle distribution
        export SELECTED_GRADLE="${DIST_LIST[gradle_selection - 1]}"
        info "→ Selected Gradle: $SELECTED_GRADLE"
    }

    # Function to update gradle.properties file
    update_project_gradle_properties() {
        GP="$PROJECT_NAME/android/gradle.properties"
        if [[ -f $GP ]]; then
            # Update NDK version in gradle.properties
            update_property "$GP" "android.ndkVersion" "$SELECTED_NDK"
            
            # Update JDK home in gradle.properties
            update_property "$GP" "org.gradle.java.home" "$SELECTED_JDK"
            
            echo "✅ gradle.properties updated."
        else
            echo "⚠️  Missing gradle.properties; set NDK/JDK manually."
        fi
    }

    # Function to update gradle-wrapper.properties file
    update_project_grandle_wrapper() {
        GW="$PROJECT_NAME/android/gradle/wrapper/gradle-wrapper.properties"
        if [[ -f $GW ]]; then
            sed -i "s|^distributionUrl=.*|distributionUrl=https\\://services.gradle.org/distributions/$SELECTED_GRADLE.zip|" "$GW"
            echo "✅ gradle-wrapper.properties set to $SELECTED_GRADLE."
        fi
    }

    # Function to update build.gradle file
    update_project_build_gradle() {
        BG="$PROJECT_NAME/android/app/build.gradle"
        if [[ -f $BG ]]; then
            # Parse major version from JDK basename
            JV=$(basename "$SELECTED_JDK")
            [[ $JV =~ ([0-9]+) ]] && JVNUM=${BASH_REMATCH[1]} || JVNUM=8
            
            # Set the correct Java version compatibility
            SC="JavaVersion.VERSION_$JVNUM"
            sed -i "s|sourceCompatibility = .*|sourceCompatibility = $SC|" "$BG"
            sed -i "s|targetCompatibility = .*|targetCompatibility = $SC|" "$BG"
            sed -i "s|jvmTarget = .*|jvmTarget = $SC|" "$BG"

            # Update NDK version in build.gradle
            if grep -q 'ndkVersion' "$BG"; then
                sed -i "s|ndkVersion.*|ndkVersion \"$SELECTED_NDK\"|" "$BG"
            else
                sed -i "/defaultConfig {/a \        ndkVersion \"$SELECTED_NDK\"" "$BG"
            fi

            echo "✅ build.gradle updated (Java $JVNUM, NDK)."
        fi
    }

    # Function to update AndroidManifest.xml file
    update_project_android_manifest() {
        AM="$PROJECT_NAME/android/app/src/main/AndroidManifest.xml"
        if [[ -f $AM ]]; then
            sed -i "s|\(android:label=\)\"[^\"]*\"|\1\"$DISPLAY_NAME\"|" "$AM"
            echo "✅ Android label → $DISPLAY_NAME."
        fi
    }

    # Function to update Info.plist file
    update_project_info_plist() {
        PL="$PROJECT_NAME/ios/Runner/Info.plist"
        if [[ -f $PL ]]; then
            if grep -q '<key>CFBundleDisplayName</key>' "$PL"; then
                sed -i "/<key>CFBundleDisplayName<\/key>/{n; s|<string>.*|<string>$DISPLAY_NAME</string>|}" "$PL"
            else
                sed -i "/<key>CFBundleName<\/key>/a\\
                <key>CFBundleDisplayName<\/key>\\
                <string>$DISPLAY_NAME<\/string>" "$PL"
            fi
            echo "✅ iOS Display Name → $DISPLAY_NAME."
        fi
    }
fi