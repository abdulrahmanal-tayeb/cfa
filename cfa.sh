#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# cfa.sh
# • Linux/macOS/WSL/Git-Bash
# • Validates names, robust SDK detection,
#   select menus for template/platforms/NDK/JDK/Gradle,
#   updates all required files.
# -----------------------------------------------------------------------------

# 1) Pre-flight
command -v flutter >/dev/null 2>&1 || {
  echo "❌ Error: 'flutter' not in PATH. Install Flutter first."; exit 1; }
echo "⚙️  Flutter detected."
if ! command -v code >/dev/null 2>&1; then
  echo "⚠️  'code' not in PATH—VS Code opening will be skipped."
fi

# 2) Android SDK detection
SDK_DIR=""
if [[ -n "${ANDROID_SDK_ROOT:-}" && -d "$ANDROID_SDK_ROOT" ]]; then
  SDK_DIR="$ANDROID_SDK_ROOT"
elif [[ -n "${ANDROID_HOME:-}" && -d "$ANDROID_HOME" ]]; then
  SDK_DIR="$ANDROID_HOME"
else
 COMMON=( "$HOME/Android/Sdk" "$HOME/Library/Android/sdk" \
           "/usr/local/android-sdk" "/opt/android-sdk" )
  for p in "${COMMON[@]}"; do
    [[ -d "$p" ]] || continue
    read -rp "Found SDK at '$p'. Use? [Y/n]: " r; r=${r:-Y}
    if [[ $r =~ ^[Yy]$ ]]; then SDK_DIR="$p"; break; fi
  done
fi

while [[ -z "$SDK_DIR" ]]; do
  read -rp "Enter Android SDK path (or export ANDROID_SDK_ROOT): " SDK_DIR
  [[ -d "$SDK_DIR" ]] || { echo "❌ '$SDK_DIR' not a dir."; SDK_DIR=""; }
done
echo "→ SDK: $SDK_DIR"
export ANDROID_SDK_ROOT="$SDK_DIR"

# --- 3. Project name with validation ---
reserved=(assert break case catch class const continue default do else enum \
  extends false final finally for if in is new null rethrow return super \
  switch this throw true try var void while with abstract as covariant \
  deferred dynamic export external factory get implements import interface \
  library mixin operator part set static typedef)
is_reserved(){ for w in "${reserved[@]}"; do [[ "$w" == "$1" ]] && return 0; done; return 1; }
DEFAULT_NAME="my_app"
while :; do
  read -rp "Project name [$DEFAULT_NAME]: " NAME
  NAME=${NAME:-$DEFAULT_NAME}
  if [[ ! $NAME =~ ^[a-z_][a-z0-9_]*$ ]]; then
    echo "❌ Use [a-z0-9_], start with letter/_."; continue
  fi
  if is_reserved "$NAME"; then
    echo "❌ '$NAME' is reserved."; continue
  fi
  PROJECT_NAME="$NAME"; break
done

# Display Name
DEFAULT_DISP="$(echo "$PROJECT_NAME" \
  | sed -E 's/_/ /g; s/(^| )([a-z])/\1\U\2/g')"
read -rp "Display name [$DEFAULT_DISP]: " DISPLAY_NAME
DISPLAY_NAME=${DISPLAY_NAME:-$DEFAULT_DISP}

# Org & desc
read -rp "Organization (reverse-DNS) [com.example]: " ORG
ORG=${ORG:-com.example}
read -rp "Description [A new Flutter project.]: " DESCRIPTION
DESCRIPTION=${DESCRIPTION:-A new Flutter project.}

# 4) Template
echo; TEMPLATES=(app module package plugin)
echo "Select template:"
select TEMPLATE in "${TEMPLATES[@]}"; do
  [[ -n $TEMPLATE ]] && break
  echo "→ Choose 1-${#TEMPLATES[@]}."
done

# 5) Platforms
echo; PLATTS=(android ios web linux macos windows)
echo "Select platforms (numbers, e.g. 1 2):"
for i in "${!PLATTS[@]}"; do printf "  %2d) %s\n" $((i+1)) "${PLATTS[i]}"; done
read -rp "Platforms [1 2]: " -a IDX
LIST=()
for i in "${IDX[@]}"; do
  ((i>=1&&i<=${#PLATTS[@]})) && LIST+=("${PLATTS[i-1]}")
done
[ ${#LIST[@]} -eq 0 ] && LIST=(android ios)
PLATFORMS="${LIST[*]}"

# 6) Android language
read -rp "Android language [kotlin]: " ANDROID_LANG
ANDROID_LANG=${ANDROID_LANG:-kotlin}

# 7) NDK (default = first)
NDK_BASE="$SDK_DIR/ndk"
[[ -d $NDK_BASE ]] || { echo "❌ $NDK_BASE missing."; exit 1; }
VERS_NDK=( "$NDK_BASE"/* )
echo; echo "NDK versions:"
for i in "${!VERS_NDK[@]}"; do
  printf "  %2d) %s\n" $((i+1)) "${VERS_NDK[i]##*/}"
done
read -rp "NDK [1]: " n; n=${n:-1}
((n<1||n>${#VERS_NDK[@]})) && n=1
SELECTED_NDK="${VERS_NDK[n-1]##*/}"
echo "→ NDK: $SELECTED_NDK"

# 8) JDK (default = JAVA_HOME or first)
JVM="/usr/lib/jvm"
[[ -d $JVM ]] || { echo "❌ $JVM missing."; exit 1; }
VERS_JDK=( "$JVM"/* )
echo; echo "JDKs:"
for i in "${!VERS_JDK[@]}"; do
  printf "  %2d) %s\n" $((i+1)) "${VERS_JDK[i]##*/}"
done
# find JAVA_HOME index
defJ=1
if [[ -n "${JAVA_HOME:-}" ]]; then
  for i in "${!VERS_JDK[@]}"; do
    [[ "${VERS_JDK[i]}"==$JAVA_HOME ]] && defJ=$((i+1))
  done
fi
read -rp "JDK [$defJ]: " j; j=${j:-$defJ}
((j<1||j>${#VERS_JDK[@]})) && j=$defJ
SELECTED_JDK="${VERS_JDK[j-1]}"
echo "→ JDK: $SELECTED_JDK"

# 9) Gradle (from ~/.gradle/wrapper/dists or fallback list)
GRD_DISTS=( ~/.gradle/wrapper/dists/gradle-*-all )
DIST_LIST=()
for d in ${GRD_DISTS[@]}; do
  [[ -d $d ]] && DIST_LIST+=("$(basename $d)")
done
# fallback
[ ${#DIST_LIST[@]} -eq 0 ] && DIST_LIST=(gradle-8.3-all gradle-8.2-all gradle-8.1.1-all)
echo; echo "Gradle distributions:"
for i in "${!DIST_LIST[@]}"; do
  printf "  %2d) %s\n" $((i+1)) "${DIST_LIST[i]}"
done
read -rp "Gradle [1]: " g; g=${g:-1}
((g<1||g>${#DIST_LIST[@]})) && g=1
SELECTED_GRADLE="${DIST_LIST[g-1]}"
echo "→ Gradle: $SELECTED_GRADLE"

# 10) Create Flutter project
echo; echo "🚀 Creating $PROJECT_NAME..."
flutter create \
  --template="$TEMPLATE" \
  --project-name="$PROJECT_NAME" \
  --org="$ORG" \
  --description="$DESCRIPTION" \
  --platforms="$(echo "${PLATFORMS// /,}")" \
  --android-language="$ANDROID_LANG" \
  "$PROJECT_NAME"

# 11) Update android/gradle.properties
GP="$PROJECT_NAME/android/gradle.properties"
if [[ -f $GP ]]; then
  # NDK
  if grep -q '^android\.ndkVersion=' $GP; then
    sed -i "s|^android\.ndkVersion=.*|android.ndkVersion=$SELECTED_NDK|" $GP
  else
    echo -e "\n# by script\nandroid.ndkVersion=$SELECTED_NDK" >> $GP
  fi
  # JDK
  if grep -q '^org\.gradle\.java\.home=' $GP; then
    sed -i "s|^org\.gradle\.java\.home=.*|org.gradle.java.home=$SELECTED_JDK|" $GP
  else
    echo "org.gradle.java.home=$SELECTED_JDK" >> $GP
  fi
  echo "✅ gradle.properties updated."
else
  echo "⚠️  Missing gradle.properties; set NDK/JDK manually."
fi

# 12) Update gradle-wrapper.properties
GW="$PROJECT_NAME/android/gradle/wrapper/gradle-wrapper.properties"
if [[ -f $GW ]]; then
  sed -i "s|^distributionUrl=.*|distributionUrl=https\\://services.gradle.org/distributions/$SELECTED_GRADLE.zip|" $GW
  echo "✅ gradle-wrapper.properties set to $SELECTED_GRADLE."
fi

# 13) Update android/app/build.gradle
BG="$PROJECT_NAME/android/app/build.gradle"
if [[ -f $BG ]]; then
  # parse major version from JDK basename
  JV=$(basename "$SELECTED_JDK")
  [[ $JV =~ ([0-9]+) ]] && JVNUM=${BASH_REMATCH[1]} || JVNUM=8
  if (( JVNUM == 8 )); then
    SC="JavaVersion.VERSION_1_8"
  else
    SC="JavaVersion.VERSION_$JVNUM"
  fi

  sed -i "s|sourceCompatibility = .*|sourceCompatibility = $SC|" $BG
  sed -i "s|targetCompatibility = .*|targetCompatibility = $SC|" $BG
  sed -i "s|jvmTarget = .*|jvmTarget = $SC|" $BG

  # ndkVersion
  if grep -q 'ndkVersion' $BG; then
    sed -i "s|ndkVersion.*|ndkVersion \"$SELECTED_NDK\"|" $BG
  else
    sed -i "/defaultConfig {/a \        ndkVersion \"$SELECTED_NDK\"" $BG
  fi

  echo "✅ build.gradle updated (Java $JVNUM, NDK)."
fi

# 14) Patch AndroidManifest.xml
AM="$PROJECT_NAME/android/app/src/main/AndroidManifest.xml"
[[ -f $AM ]] && {
  sed -i "s|\(android:label=\)\"[^\"]*\"|\1\"$DISPLAY_NAME\"|" $AM
  echo "✅ Android label → $DISPLAY_NAME."
}

# 15) Patch iOS Info.plist
PL="$PROJECT_NAME/ios/Runner/Info.plist"
[[ -f $PL ]] && {
  if grep -q '<key>CFBundleDisplayName</key>' $PL; then
    sed -i "/<key>CFBundleDisplayName<\/key>/{n; s|<string>.*|<string>$DISPLAY_NAME</string>|}" $PL
  else
    sed -i "/<key>CFBundleName<\/key>/a\\
    <key>CFBundleDisplayName<\/key>\\
    <string>$DISPLAY_NAME<\/string>" $PL
  fi
  echo "✅ iOS Display Name → $DISPLAY_NAME."
}

# 16) Open in VS Code
if command -v code >/dev/null 2>&1; then
  echo "📂 Opening in VS Code..."
  cd "$PROJECT_NAME" && code .
else
  echo "🎉 Done! cd $PROJECT_NAME && code ."
fi

echo "✅ All done – project '$PROJECT_NAME' is ready! 🎉"
