#!/usr/bin/env bash
# This script automatically detects the presets directory for PulseEffects or EasyEffects

# Function to check the selected audio effects application and set the presets directory
check_type() {
    echo "Select the audio effects application:"
    echo "1) PulseEffects"
    echo "2) EasyEffects"
    read -p "Enter your choice (1 or 2): " choice

    case $choice in
    1)
        if dpkg -l | grep -q "pulseeffects"; then
            PRESETS_DIRECTORY="$HOME/.config/PulseEffects"
        elif flatpak list | grep -q "com.github.wwmm.pulseeffects"; then
            PRESETS_DIRECTORY="$HOME/.var/app/com.github.wwmm.pulseeffects/config/PulseEffects"
        elif [ -d "$HOME/.config/PulseEffects" ]; then
            PRESETS_DIRECTORY="$HOME/.config/PulseEffects"
        else
            echo "Error! Couldn't find PulseEffects presets directory!"
            exit 1
        fi
        ;;
    2)
        if dpkg -l | grep -q "easyeffects"; then
            PRESETS_DIRECTORY="$HOME/.config/easyeffects"
        elif flatpak list | grep -q "com.github.wwmm.easyeffects"; then
            PRESETS_DIRECTORY="$HOME/.var/app/com.github.wwmm.easyeffects/config/EasyEffects"
        elif [ -d "$HOME/.config/easyeffects" ]; then
            PRESETS_DIRECTORY="$HOME/.config/easyeffects"
        else
            echo "Error! Couldn't find EasyEffects presets directory!"
            exit 1
        fi
        ;;
    *)
        echo "Invalid choice! Please enter 1 or 2."
        exit 1
        ;;
    esac
}

# Function to check and create impulse directory if it doesn't exist
check_impulse_directory() {
    if [ ! -d "$PRESETS_DIRECTORY/irs" ]; then
        mkdir -p "$PRESETS_DIRECTORY/irs"
    fi
}

# Function to install presets
install_presets() {
    echo "Installing MusicX1"

    # Create output directory if it doesn't exist
    mkdir -p "$PRESETS_DIRECTORY/output"

    # Download JSON files
    curl "https://raw.githubusercontent.com/arvindchauhan1/EasyEffects-Pulseeffects-EQ/main/MusicX1-Headphones.json" --output "$PRESETS_DIRECTORY/output/MusicX1-Headphones.json" --silent
    curl "https://raw.githubusercontent.com/arvindchauhan1/EasyEffects-Pulseeffects-EQ/main/MusicX1-Laptop.json" --output "$PRESETS_DIRECTORY/output/MusicX1-Laptop.json" --silent

    # Check if files were downloaded successfully
    if [[ ! -f "$PRESETS_DIRECTORY/output/MusicX1-Headphones.json" || ! -f "$PRESETS_DIRECTORY/output/MusicX1-Laptop.json" ]]; then
        echo "Error: Failed to download MusicX1 JSON files."
        exit 1
    fi

    echo "Installing impulse files"

    # Array of impulse files to download
    impulse_files=(
        "https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/irs/Dolby%20ATMOS%20((128K%20MP3))%201.Default.irs"
        "https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/irs/MaxxAudio%20Pro%20((128K%20MP3))%204.Music%20w%20MaxxSpace.irs"
        "https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/irs/Razor%20Surround%20((48k%20Z-Edition))%202.Stereo%20+20%20bass.irs"
        # Add more impulse file URLs as needed
    )

    # Loop through the array and download each file
    for url in "${impulse_files[@]}"; do
        filename=$(basename "$url")
        curl "$url" --output "$PRESETS_DIRECTORY/irs/$filename" --silent
    done

    # Update user name in JSON files
    sed -i 's/niel/'"$USER"'/g' "$PRESETS_DIRECTORY/output/MusicX1-Headphones.json"
    sed -i 's/niel/'"$USER"'/g' "$PRESETS_DIRECTORY/output/MusicX1-Laptop.json"
    echo "Done!"
}

check_type
check_impulse_directory
install_presets
