#!/usr/bin/env bash

# Constantes agrupadas
declare -A COLORS=(
    ["reset"]="\033[0m"
    ["bold"]="\033[1m"
    ["dim"]="\033[2m"
    ["blink"]="\033[5m"
)
declare -a GRADIENT_COLORS=(
    "\033[38;5;196m" "\033[38;5;202m" "\033[38;5;208m" "\033[38;5;214m"
    "\033[38;5;220m" "\033[38;5;226m" "\033[38;5;190m" "\033[38;5;154m"
    "\033[38;5;118m" "\033[38;5;82m"  "\033[38;5;46m"  "\033[38;5;47m"
    "\033[38;5;48m"  "\033[38;5;49m"  "\033[38;5;50m"  "\033[38;5;51m"
    "\033[38;5;45m"  "\033[38;5;39m"  "\033[38;5;33m"  "\033[38;5;27m"
)
MATRIX_CHARS="01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン"
PARTICLE_CHARS="✦ ✧ ✪ ✫ ✬ ✭ ✮ ✯ ✰ ✱ ✲ ✳"

# Parámetros configurables
FRAMES_BANNER=35
SLEEP_BANNER=0.08
FRAMES_DEDICATORIA=40
SLEEP_DEDICATORIA=0.12

# Dimensiones de la terminal
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
TERM_HEIGHT=$(tput lines 2>/dev/null || echo 24)

# Funciones auxiliares
get_text_dimensions() {
    local text="$1"
    local max_width=0
    local height=0
    while IFS= read -r line; do
        local clean_line
        clean_line=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')
        local line_width
        line_width=$(echo -n "$clean_line" | wc -m)
        local emoji_count
        emoji_count=$(echo -n "$clean_line" | grep -o '[^\x00-\x7F]' | wc -l)
        line_width=$((line_width + emoji_count))
        [ "$line_width" -gt "$max_width" ] && max_width=$line_width
        ((height++))
    done <<< "$text"
    echo "$max_width $height"
}

get_visible_width() {
    local text="$1"
    local clean_text
    clean_text=$(echo "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local width
    width=$(echo -n "$clean_text" | wc -m)
    local emoji_count
    emoji_count=$(echo -n "$clean_text" | grep -o '[^\x00-\x7F]' | wc -l)
    echo $((width + emoji_count))
}

center_text() {
    local text="$1"
    local term_width=${2:-$TERM_WIDTH}
    local text_width
    text_width=$(get_visible_width "$text")
    local margin=$(( (term_width - text_width) / 2 ))
    [ "$margin" -lt 0 ] && margin=0
    printf "%*s" "$margin" ""
}

matrix_step() {
    local i
    for ((i=0; i<10; i++)); do
        local x=$((RANDOM % TERM_WIDTH))
        local y=$((RANDOM % TERM_HEIGHT))
        local char_index=$((RANDOM % ${#MATRIX_CHARS}))
        local char=${MATRIX_CHARS:$char_index:1}
        local color_index=$((RANDOM % ${#GRADIENT_COLORS[@]}))
        printf "\033[%d;%dH%s%s%s" "$y" "$x" "${COLORS[dim]}" "${GRADIENT_COLORS[color_index]}" "$char"
    done
}

generate_particles() {
    local x_center=$1
    local y_center=$2
    local intensity=$3
    local i
    for ((i=0; i<intensity; i++)); do
        local offset_x=$((RANDOM % 20 - 10))
        local offset_y=$((RANDOM % 6 - 3))
        local px=$((x_center + offset_x))
        local py=$((y_center + offset_y))
        [ "$px" -lt 1 ] && px=1
        [ "$px" -gt "$TERM_WIDTH" ] && px=$TERM_WIDTH
        [ "$py" -lt 1 ] && py=1
        [ "$py" -gt "$TERM_HEIGHT" ] && py=$TERM_HEIGHT
        local particle_chars=($PARTICLE_CHARS)
        local particle=${particle_chars[$((RANDOM % ${#particle_chars[@]}))]}
        local color_index=$((RANDOM % ${#GRADIENT_COLORS[@]}))
        printf "\033[%d;%dH%s%s%s" "$py" "$px" "${COLORS[bold]}" "${GRADIENT_COLORS[color_index]}" "$particle"
    done
}

draw_glitch_text() {
    local row=$1 text="$2" frame=$3 color=$4 bold=$5
    local width=$TERM_WIDTH
    local padding
    padding=$(center_text "$text" "$width")
    tput cup "$row" "$padding" 2>/dev/null
    if [ "$bold" = "true" ]; then
        printf "\033[1;38;5;%dm" "$color"
    else
        printf "\033[38;5;%dm" "$color"
    fi
    if [ $((frame % 12)) -eq 0 ]; then
        local glitched=""
        local i
        for ((i=0; i<${#text}; i++)); do
            if [ $((RANDOM % 10)) -eq 0 ]; then
                glitched+="█"
            else
                glitched+="${text:$i:1}"
            fi
        done
        printf "%s" "$glitched"
    else
        printf "%s" "$text"
    fi
    printf "%s" "${COLORS[reset]}"
}

draw_neon_line() {
    local row=$1 text="$2" frame=$3 base_color=$4
    local width=$TERM_WIDTH
    local padding
    padding=$(center_text "$text" "$width")
    tput cup "$row" "$padding" 2>/dev/null
    local pulse=$((frame % 8))
    if [ "$pulse" -lt 4 ]; then
        printf "\033[1;38;5;%dm%s%s" "$base_color" "$text" "${COLORS[reset]}"
    else
        printf "\033[38;5;%dm%s%s" "$((base_color + 6))" "$text" "${COLORS[reset]}"
    fi
}

draw_cyber_text() {
    local row=$1 text="$2" frame=$3 color=$4
    local width=$TERM_WIDTH
    local padding
    padding=$(center_text "$text" "$width")
    tput cup "$row" "$padding" 2>/dev/null
    printf "\033[38;5;%dm" "$color"
    local i
    for ((i=0; i<${#text}; i++)); do
        local scan_pos=$(((frame - i) % 20))
        if [ "$scan_pos" -eq 0 ]; then
            printf "\033[1m%c\033[22m" "${text:$i:1}"
        else
            printf "%c" "${text:$i:1}"
        fi
    done
    printf "%s" "${COLORS[reset]}"
}

draw_info_text() {
    local row=$1 text="$2" frame=$3 color=$4
    local width=$TERM_WIDTH
    local padding
    padding=$(center_text "$text" "$width")
    tput cup "$row" "$padding" 2>/dev/null
    local visible_chars=$((frame * 3))
    [ "$visible_chars" -gt "${#text}" ] && visible_chars=${#text}
    printf "\033[38;5;%dm%s" "$color" "${text:0:$visible_chars}"
    if [ "$visible_chars" -lt "${#text}" ]; then
        local blink=$((frame % 4))
        if [ "$blink" -lt 2 ]; then
            printf "\033[38;5;226m█"
        fi
    fi
    printf "%s" "${COLORS[reset]}"
}

draw_starfield() {
    local frame=$1 width=$2 height=$3
    local stars=("✦" "✧" "⋆" "✩" "✪" "✫" "✬" "✭" "✮" "✯")
    local i
    for ((i=0; i<15; i++)); do
        local star_row=$((1 + (i * 7) % (height - 2)))
        local star_col=$((5 + (i * 13) % (width - 10)))
        local star_phase=$(((frame + i * 3) % 16))
        if [ "$star_phase" -lt 8 ]; then
            tput cup "$star_row" "$star_col" 2>/dev/null
            local star_idx=$((i % ${#stars[@]}))
            local brightness=$((225 - star_phase * 10))
            printf "\033[38;5;%dm%s%s" "$brightness" "${stars[star_idx]}" "${COLORS[reset]}"
        fi
    done
}

draw_compact_banner() {
    local frame=$1
    shift
    local colors=("$@")
    local compact_title="✦ NEXUS KALI APEX ✦"
    local width=$TERM_WIDTH
    local padding
    padding=$(center_text "$compact_title" "$width")
    tput cup 1 "$padding" 2>/dev/null
    local color_idx=$((frame % ${#colors[@]}))
    printf "\033[1;38;5;%dm%s%s" "${colors[color_idx]}" "$compact_title" "${COLORS[reset]}"
}

draw_heart_text() {
    local row=$1 text="$2" frame=$3 line_idx=$4
    local width=$TERM_WIDTH
    local padding
    padding=$(center_text "$text" "$width")
    tput cup "$row" "$padding" 2>/dev/null
    local heart_colors=(213 219 225 196 197 198)
    local color_idx=$(((frame + line_idx * 5) % ${#heart_colors[@]}))
    local pulse=$(((frame + line_idx * 8) % 12))
    if [ "$pulse" -lt 6 ]; then
        printf "\033[1;38;5;%dm%s%s" "${heart_colors[color_idx]}" "$text" "${COLORS[reset]}"
    else
        printf "\033[38;5;%dm%s%s" "${heart_colors[color_idx]}" "$text" "${COLORS[reset]}"
    fi
}

draw_floating_elements() {
    local frame=$1 width=$2 height=$3
    local elements=("🐾" "💖" "🌟" "✨" "💫" "🌈")
    local i
    for ((i=0; i<6; i++)); do
        local float_cycle=$(((frame + i * 10) % 40))
        local element_row=$((3 + (float_cycle / 5) + (i % 3) * 5))
        local element_col=$((10 + i * 12 + (float_cycle % 8)))
        if [ "$element_row" -lt $((height - 3)) ] && [ "$element_col" -lt $((width - 5)) ]; then
            tput cup "$element_row" "$element_col" 2>/dev/null
            local element_idx=$((i % ${#elements[@]}))
            printf "%s" "${elements[element_idx]}"
        fi
    done
}

draw_love_border() {
    local frame=$1 width=$2 height=$3
    local border_color=$((213 + (frame % 6)))
    printf "\033[38;5;%dm" "$border_color"
    tput cup 0 0 2>/dev/null && printf "💖"
    tput cup 0 $((width-2)) 2>/dev/null && printf "💖"
    tput cup $((height-1)) 0 2>/dev/null && printf "💖"
    tput cup $((height-1)) $((width-2)) 2>/dev/null && printf "💖"
    printf "%s" "${COLORS[reset]}"
}

draw_dynamic_border() {
    local frame=$1 width=$2 height=$3
    local border_chars=("═" "━" "─" "═" "━" "─")
    local char_idx=$((frame % ${#border_chars[@]}))
    local color=$((39 + (frame % 12)))
    printf "\033[38;5;%dm" "$color"
    local col
    for ((col=0; col<width; col++)); do
        local wave_offset=$(((col + frame) % 8))
        if [ "$wave_offset" -eq 0 ]; then
            tput cup 0 "$col" 2>/dev/null && printf "▀"
            tput cup $((height-1)) "$col" 2>/dev/null && printf "▄"
        fi
    done
    printf "%s" "${COLORS[reset]}"
}

show_final_message() {
    local width=$TERM_WIDTH
    local height=$TERM_HEIGHT
    sleep 1
    local continue_msg="💫 Presiona Enter para continuar con amor... 💫"
    local msg_row=$((height - 3))
    local msg_col
    msg_col=$(center_text "$continue_msg" "$width")
    local i
    for ((i=0; i<20; i++)); do
        tput cup "$msg_row" "$msg_col" 2>/dev/null
        local pulse_color=$((196 + (i % 8)))
        if [ $((i % 4)) -lt 2 ]; then
            printf "\033[1;38;5;%dm%s%s" "$pulse_color" "$continue_msg" "${COLORS[reset]}"
        else
            printf "\033[38;5;%dm%s%s" "$pulse_color" "$continue_msg" "${COLORS[reset]}"
        fi
        sleep 0.2
    done
    read -r
    clear
}

safe_draw_text() {
    local row=$1 text="$2" frame=$3 type=$4
    local visible_width
    visible_width=$(get_visible_width "$text")
    if [ "$visible_width" -gt $((TERM_WIDTH - 4)) ]; then
        text="${text:0:$((TERM_WIDTH - 4))}" # Truncar aproximado
    fi
    local padding
    padding=$(center_text "$text")
    tput cup "$row" "$padding" 2>/dev/null
    local color_idx
    case "$type" in
        glitch) draw_glitch_text "$row" "$text" "$frame" "226" "true" ;;
        neon) draw_neon_line "$row" "$text" "$frame" "51" ;;
        cyber) color_idx=$(((frame + row) % ${#cyber_colors[@]})); draw_cyber_text "$row" "$text" "$frame" "${cyber_colors[color_idx]}" ;;
        info) draw_info_text "$row" "$text" "$frame" "159" ;;
        heart) draw_heart_text "$row" "$text" "$frame" "$row" ;;
    esac
}

animate_banner() {
    local term_width=$TERM_WIDTH
    local term_height=$TERM_HEIGHT
    
    local banner_content
    local dedication_lines=(
        "🐕💖 Dedicado a Mimi, mi fiel compañera que corre en el cielo 🐾"
        "🌟 Su espíritu guía cada línea de código ✨"
        "💫 Siempre en mi corazón, corriendo libre bajo las estrellas 🌈"
    )
    
    local cyber_colors=(39 45 51 87 123 159 195 201 207 213 219 225 231)
    
    # Seleccionar banner según tamaño
    if [ "$term_width" -lt 80 ] || [ "$term_height" -lt 24 ]; then
        banner_content=(
            "░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓█▓▒░      ░▒▓█▓▒░"
            "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░"
            "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░"
            "░▒▓███████▓▒░░▒▓████████▓▒░▒▓█▓▒░      ░▒▓█▓▒░"
            "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░"
            "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░"
            "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓█▓▒░"
            "────────────────────────────"
            "v${SCRIPT_VERSION:-1.0} by Dazka00"
        )
    else
        banner_content=(
            " ░▒▓██████▓▒░░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░"
            "░▒▓███████▓▒░░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░"
            "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      "
            "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      "
            "░▒▓█▓▒░░▒▓█▓▒░▒▓██████▓▒░  ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░"
            "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░"
            "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░"
            "░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓███████▓▒░"
            "──────────────────────────────────────────────────────────────"
            "v${SCRIPT_VERSION:-1.0} by Dazka00"
        )
    fi
    
    tput civis 2>/dev/null
    clear
    
    local max_banner_lines=$((term_height - 8))
    local banner_lines_to_show=${#banner_content[@]}
    [ "$banner_lines_to_show" -gt "$max_banner_lines" ] && banner_lines_to_show=$max_banner_lines
    
    # FASE 1: Aparición del banner con efecto matriz
    local frame
    for ((frame=0; frame<FRAMES_BANNER; frame++)); do
        matrix_step
        clear
        local start_row=$(( (term_height - banner_lines_to_show) / 2 ))
        [ "$start_row" -lt 1 ] && start_row=1
        
        local i
        for ((i=0; i<banner_lines_to_show; i++)); do
            local line_delay=$((i * 2))
            if [ "$frame" -gt "$line_delay" ] && [ $((start_row + i)) -lt $((term_height - 1)) ]; then
                local row=$((start_row + i))
                local line="${banner_content[i]}"
                
                if [ "$i" -eq $((banner_lines_to_show - 2)) ]; then
                    line=$(printf "%${term_width}s" | tr " " "─" | cut -c1-$((term_width - 4)))
                fi
                
                local type
                if [ "$i" -eq 0 ]; then
                    type="glitch"
                elif [ "$i" -eq $((banner_lines_to_show - 2)) ]; then
                    type="neon"
                elif [ "$i" -eq $((banner_lines_to_show - 1)) ]; then
                    type="info"
                else
                    type="cyber"
                fi
                safe_draw_text "$row" "$line" "$frame" "$type"
                generate_particles $((term_width / 2)) "$row" 1
            fi
        done
        
        draw_dynamic_border "$frame" "$term_width" "$term_height"
        sleep "$SLEEP_BANNER"
    done
    
    # FASE 2: Transición
    sleep 0.5
    
    # FASE 3: Dedicatoria con fondo de estrellas y partículas
    for ((frame=0; frame<FRAMES_DEDICATORIA; frame++)); do
        matrix_step
        clear
        draw_starfield "$frame" "$term_width" "$term_height"
        draw_compact_banner "$frame" "${cyber_colors[@]}"
        
        local max_ded_lines=$((term_height / 3))
        local ded_lines_to_show=${#dedication_lines[@]}
        [ "$ded_lines_to_show" -gt "$max_ded_lines" ] && ded_lines_to_show=$max_ded_lines
        
        local ded_start_row=$((term_height / 2 - ded_lines_to_show))
        [ "$ded_start_row" -lt 3 ] && ded_start_row=3
        
        for ((i=0; i<ded_lines_to_show; i++)); do
            local line_delay=$((i * 8))
            if [ "$frame" -gt "$line_delay" ] && [ $((ded_start_row + i * 2)) -lt $((term_height - 1)) ]; then
                local row=$((ded_start_row + i * 2))
                local line="${dedication_lines[i]}"
                
                safe_draw_text "$row" "$line" "$frame" "heart"
                generate_particles $((term_width / 2)) "$row" 2
            fi
        done
        
        draw_floating_elements "$frame" "$term_width" "$term_height"
        draw_love_border "$frame" "$term_width" "$term_height"
        sleep "$SLEEP_DEDICATORIA"
    done
    
    # FASE 4: Mensaje final
    show_final_message
    tput cnorm 2>/dev/null
}

trap "tput cnorm 2>/dev/null; clear" EXIT

animate_banner
