#!/bin/bash

# r1.sh - Extract and display menu items in card format

curl_menu() {
    curl -s -o - "https://api.mynovae.ch/en/api/v2/salepoints/13-restaurant-r1/menus/week/$(date -I)" \
        -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0' \
        -H 'Accept: application/json, text/plain, */*' \
        -H 'Accept-Language: en-US,de;q=0.7,en;q=0.3' \
        -H 'Referer: https://www.mynovae.ch/' \
        -H 'X-Requested-With: xmlhttprequest' \
        -H 'Novae-Front-Version: 3.5.9' \
        -H 'Novae-Codes: CER103' \
        -H 'Origin: https://www.mynovae.ch' \
        -H 'DNT: 1' \
        -H 'Sec-Fetch-Dest: empty' \
        -H 'Sec-Fetch-Mode: cors' \
        -H 'Sec-Fetch-Site: same-site' \
        -H 'Connection: keep-alive' \
        -H 'Pragma: no-cache' \
        -H 'Cache-Control: no-cache' \
        -H 'TE: trailers'
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Display menu items in card format"
    echo ""
    echo "OPTIONS:"
    echo "  -l LANG    Language preference (fr|en) [default: fr]"
    echo "  -w WIDTH   Card width [default: 32]"
    echo "  -t         Show only today's dishes"
    echo "  -h         Show this help message"
}

# Default values
LANGUAGE="fr"
CARD_WIDTH=32
TODAY_ONLY=true

# Parse command line arguments
while getopts "l:w:th" opt; do
    case $opt in
        l) LANGUAGE="$OPTARG" ;;
        w) CARD_WIDTH="$OPTARG" ;;
        t) TODAY_ONLY=true ;;
        h) show_usage; exit 0 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; show_usage; exit 1 ;;
    esac
done

# Validate inputs
if [[ "$LANGUAGE" != "fr" && "$LANGUAGE" != "en" ]]; then
    echo "Error: Language must be 'fr' or 'en'" >&2
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: jq required but not installed" >&2
    exit 1
fi

# Auto-detect terminal width and calculate cards per row
TERMINAL_WIDTH=$(tput cols 2>/dev/null || echo 80)
CARDS_PER_ROW=$(( TERMINAL_WIDTH / (CARD_WIDTH + 1) ))
if [[ $CARDS_PER_ROW -lt 1 ]]; then
    CARDS_PER_ROW=1
fi

# Get today's date
TODAY=$(date +%Y-%m-%d)
TODAY_DISPLAY=$(date +"%a %d %b" | tr '[:lower:]' '[:upper:]')

# Function to wrap text to fit card width
wrap_text() {
    local text="$1"
    local width=$((CARD_WIDTH - 4))  # Account for borders and padding

    if [[ ${#text} -le $width ]]; then
        echo "$text"
    else
        echo "$text" | fold -s -w $width | head -5
    fi
}

# Function to pad text to center it
center_text() {
    local text="$1"
    local width=$((CARD_WIDTH - 2))  # Account for side borders
    local text_length=${#text}
    local padding=$(( (width - text_length) / 2 ))

    printf "%*s%s%*s" $padding "" "$text" $((width - text_length - padding)) ""
}

# Function to create card content
create_card_content() {
    local dish="$1"

    # Create wrapped lines for the dish name
    local wrapped_dish
    mapfile -t wrapped_dish < <(wrap_text "$dish")

    # Create the card content array (8 lines total)
    local -a card_lines

    # Add empty line at top
    card_lines[0]=""

    # Add wrapped dish lines starting from line 1
    local line_idx=1
    for line in "${wrapped_dish[@]}"; do
        if [[ $line_idx -lt 7 ]]; then  # Leave space at bottom
            card_lines[$line_idx]="$(center_text "$line")"
            ((line_idx++))
        fi
    done

    # Fill remaining lines with empty space
    while [[ $line_idx -lt 8 ]]; do
        card_lines[$line_idx]=""
        ((line_idx++))
    done

    printf '%s\n' "${card_lines[@]}"
}

# Function to create horizontal border
create_border() {
    local type="$1"  # top, bottom
    local count="$2"

    case "$type" in
        "top")
            printf "┌"
            printf "─%.0s" $(seq 1 $((CARD_WIDTH - 2)))
            for ((i=1; i<count; i++)); do
                printf "┬"
                printf "─%.0s" $(seq 1 $((CARD_WIDTH - 2)))
            done
            printf "┐"
            ;;
        "bottom")
            printf "└"
            printf "─%.0s" $(seq 1 $((CARD_WIDTH - 2)))
            for ((i=1; i<count; i++)); do
                printf "┴"
                printf "─%.0s" $(seq 1 $((CARD_WIDTH - 2)))
            done
            printf "┘"
            ;;
    esac
    printf "\n"
}

# Function to display date header
display_date_header() {
    local total_width=$((CARDS_PER_ROW * CARD_WIDTH + CARDS_PER_ROW - 1))
    local date_text="$TODAY_DISPLAY"
    local date_width=$((${#date_text} + 2))  # Add padding
    local left_padding=$(( (total_width - date_width ) / 2 ))

    printf "%*s" $left_padding ""
    printf "┌"
    printf "─%.0s" $(seq 1 $date_width)
    printf "┐\n"

    printf "%*s" $left_padding ""
    printf "│ %s │\n" "$date_text"

    printf "%*s" $left_padding ""
    printf "└"
    printf "─%.0s" $(seq 1 $date_width)
    printf "┘\n"
}

# Main function to display cards
display_menu_cards() {
    local json_input
    json_input="$(curl_menu)"

    if [[ -z "$json_input" ]]; then
        echo "Error: Failed to fetch menu data" >&2
        return 1
    fi

    # Extract dishes
    local -a dishes
    mapfile -t dishes < <(echo "$json_input" | jq -r --arg lang "$LANGUAGE" --arg today "$TODAY" '
        if type == "array" then
            .[] | select(.date == $today) | .title[$lang] // .title.fr // .title.en
        else
            select(.date == $today) | .title[$lang] // .title.fr // .title.en
        end
    ' | grep -v "^null$")

    if [[ ${#dishes[@]} -eq 0 ]]; then
        echo "No dishes found for today ($TODAY)"
        return 1
    fi

    # Display date header
    display_date_header
    echo

    # Process dishes in rows
    local dish_idx=0
    while [[ $dish_idx -lt ${#dishes[@]} ]]; do
        local cards_in_row=0
        local -a card_contents=()

        # Prepare cards for this row
        for ((i=0; i<CARDS_PER_ROW && dish_idx<${#dishes[@]}; i++)); do
            local dish="${dishes[$dish_idx]}"
            card_contents[i]="$(create_card_content "$dish")"
            ((cards_in_row++))
            ((dish_idx++))
        done

        # Draw top border
        create_border "top" $cards_in_row

        # Draw card content lines
        for line_num in {0..7}; do
            for ((card_idx=0; card_idx<cards_in_row; card_idx++)); do
                printf "│"
                local line
                line=$(echo "${card_contents[$card_idx]}" | sed -n "$((line_num + 1))p")
                if [[ -z "$line" ]]; then
                    printf "%*s" $((CARD_WIDTH - 2)) ""
                else
                    printf "%s" "$line"
                fi
            done
            printf "│\n"
        done

        # Draw bottom border
        create_border "bottom" $cards_in_row

        # Add spacing between rows
        if [[ $dish_idx -lt ${#dishes[@]} ]]; then
            echo
        fi
    done
}

# Execute main function
display_menu_cards

