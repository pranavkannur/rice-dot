#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# AUDIO & MICROPHONE CONTROL WITH VISUAL OSD
# ==============================================================================

ACTION="${1:-}"

get_sink_volume() {
    local raw
    raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    local val
    val=$(echo "$raw" | awk '{print int($2 * 100)}')
    echo "$val"
}

is_sink_muted() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "\[MUTED\]"
}

get_source_volume() {
    local raw
    raw=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
    local val
    val=$(echo "$raw" | awk '{print int($2 * 100)}')
    echo "$val"
}

is_source_muted() {
    wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "\[MUTED\]"
}

case "$ACTION" in
    volume-up)
        wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
        vol=$(get_sink_volume)
        notify-send -h string:x-canonical-private-synchronous:audio_osd \
                    -h int:value:"$vol" \
                    -t 1200 -i audio-volume-high "Volume" "$vol%"
        ;;

    volume-down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        vol=$(get_sink_volume)
        notify-send -h string:x-canonical-private-synchronous:audio_osd \
                    -h int:value:"$vol" \
                    -t 1200 -i audio-volume-low "Volume" "$vol%"
        ;;

    mute-toggle)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        if is_sink_muted; then
            notify-send -h string:x-canonical-private-synchronous:audio_osd \
                        -t 1500 -i audio-volume-muted "Audio" "🔇 Speakers Muted"
        else
            vol=$(get_sink_volume)
            notify-send -h string:x-canonical-private-synchronous:audio_osd \
                        -h int:value:"$vol" \
                        -t 1200 -i audio-volume-high "Audio" "🔊 Speakers Active ($vol%)"
        fi
        ;;

    mic-mute-toggle)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        if is_source_muted; then
            notify-send -h string:x-canonical-private-synchronous:mic_osd \
                        -u critical \
                        -t 1500 -i microphone-sensitivity-muted "Microphone" "🔴 Microphone Muted"
        else
            vol=$(get_source_volume)
            notify-send -h string:x-canonical-private-synchronous:mic_osd \
                        -t 1500 -i audio-input-microphone "Microphone" "🟢 Microphone Live ($vol%)"
        fi
        ;;

    mic-up)
        wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SOURCE@ 5%+
        vol=$(get_source_volume)
        notify-send -h string:x-canonical-private-synchronous:mic_osd \
                    -h int:value:"$vol" \
                    -t 1200 -i audio-input-microphone "Microphone Gain" "$vol%"
        ;;

    mic-down)
        wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-
        vol=$(get_source_volume)
        notify-send -h string:x-canonical-private-synchronous:mic_osd \
                    -h int:value:"$vol" \
                    -t 1200 -i audio-input-microphone "Microphone Gain" "$vol%"
        ;;

    *)
        echo "Usage: $0 {volume-up|volume-down|mute-toggle|mic-mute-toggle|mic-up|mic-down}"
        exit 1
        ;;
esac
