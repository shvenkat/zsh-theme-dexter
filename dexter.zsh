# A theme with an emphasis on the right side of the terminal, hence the name.
#
# Copyright (c) 2016 by Shiv Venkatasubrahmanyam <shiv@alum.mit.edu>.
# License: Apache License 2.0
#
# EXAMPLE
#
# The prompt looks as follows, where _ is the cursor:
#
# ◀▶ sleep 5                         [env] (master *%) ~/f/b/quux megatr… 18:17
# (5s)
#
# ◀▶ false                           [env] (master *%) ~/f/b/quux megatr… 18:18
# (exit 1)
#
# ◀▶ _                               [env] (master *%) ~/f/b/quux megatr… 18:18
#
# See README.md for features, installation, use and customization.


# ----------  DEFAULTS  ----------

DEXTER_LEFT_PROMPT_STRING="${DEXTER_LEFT_PROMPT_STRING:-◀▶}"
if ! [[ -v DEXTER_RIGHT_PROMPT_ELEMS ]]; then
    DEXTER_RIGHT_PROMPT_ELEMS=(venv git workdir host time)
fi
DEXTER_VENV_COLOR="${DEXTER_VENV_COLOR:-$fg_bold[green]}"
DEXTER_GIT_COLOR="${DEXTER_GIT_COLOR:-$fg[default]}"
DEXTER_WORKDIR_COLOR="${DEXTER_WORKDIR_COLOR:-$fg_bold[cyan]}"
DEXTER_HOST_COLOR="${DEXTER_HOST_COLOR:-$fg_bold[cyan]}"
DEXTER_TIME_COLOR="${DEXTER_TIME_COLOR:-$fg_bold[cyan]}"
DEXTER_SHOW_EXIT_MESSAGE="${DEXTER_SHOW_EXIT_MESSAGE:-1}"
DEXTER_EXIT_STATUS_COLOR="${DEXTER_EXIT_STATUS_COLOR:-$fg[red]}"
DEXTER_SHOW_ELAPSED_TIME="${DEXTER_SHOW_ELAPSED_TIME:-1}"
DEXTER_TIME_LIMIT_SECS="${DEXTER_TIME_LIMIT_SECS:-5}"
if ! [[ -v DEXTER_UNTIMED_COMMANDS ]]; then
    DEXTER_UNTIMED_COMMANDS=("time" "bg" "fg" "more" "less" "man"
                             "emacs" "emacsclient" "nvim" "vim" "nano"
                             "ssh", "git")
fi


# ----------  LEFT PROMPT  ----------

setopt prompt_subst
if [[ "$DEXTER_SHOW_EXIT_MESSAGE" == 1 ]]; then
    PS1='${DEXTER_LEFT_PROMPT_STRING} '
else
    PS1='%(?,%{${reset_color}%},%{${DEXTER_EXIT_STATUS_COLOR}%})${DEXTER_LEFT_PROMPT_STRING}%{$reset_color%} '
fi


# ----------  RIGHT PROMPT  ----------

RPS1=''
for _elem in $DEXTER_RIGHT_PROMPT_ELEMS; do
    case "$_elem" in
        venv)
            # Python virtualenv.
            if type virtualenv_prompt_info >/dev/null 2>&1; then
                ZSH_THEME_VIRTUALENV_PREFIX="["
                ZSH_THEME_VIRTUALENV_SUFFIX="]"
                RPS1+=' %{${DEXTER_VENV_COLOR}%}$(virtualenv_prompt_info)%{${reset_color}%}'
            fi
            ;;
        git)
            # Git status
            if type __git_ps1 >/dev/null 2>&1; then
                GIT_PS1_SHOWDIRTYSTATE=yes
                GIT_PS1_SHOWSTASHSTATE=yes
                GIT_PS1_SHOWUNTRACKEDFILES=yes
                GIT_PS1_SHOWUPSTREAM="verbose"
                GIT_PS1_DESCRIBE_STYLE="branch"
                RPS1+=' %{${DEXTER_GIT_COLOR}%}$(__git_ps1 "(%s)")%{${reset_color}%}'
            fi
            ;;
        workdir)
            # Working directory.
            if type shrink_path >/dev/null 2>&1; then
                # Use a fish-style abbreviation.
                RPS1+=' %{${DEXTER_WORKDIR_COLOR}%}$(shrink_path -l -t -T)%{${reset_color}%}'
            else
                # Show at most 1 leading and 2 trailing path components.
                RPS1+=' %{${DEXTER_WORKDIR_COLOR}%}%(4~|%-1~/…/%2~|%3~)%{${reset_color}%}'
            fi
            ;;
        host)
            # Hostname.  Use the first component (upto the first period),
            # truncated to 6 characters.
            RPS1+=' %{${DEXTER_HOST_COLOR}%}%7>…>%m%>>%{${reset_color}%}'
            ;;
        time)
            # Time in HH:MM 24-hour format.
            RPS1+=' %{${DEXTER_TIME_COLOR}%}$(date +%H:%M)%{${reset_color}%}'
            ;;
        *)
            echo "Invalid specifier '$elem' in $DEXTER_RIGHT_PROMPT_ELEMS." 1>&2
            ;;
    esac
done
# Remove leading space character.
if [[ "$RPS1" =~ "^ " ]]; then
    RPS1="${RPS1:1}"
fi


# ----------  PREVIOUS COMMAND SUMMARY AND BLANK LINE  ----------

# Returns current time in seconds since Unix epoch.
_get_timestamp() {
    echo "$(date '+%s')"
}

# Initialize state variables, since `precmd` runs before `preexec` when the
# shell starts.
_start_seconds="$(_get_timestamp)"
_is_timed_cmd="true"

# Returns time formatted with suitable units.
# $1: Time in seconds (integer).
_format_time() {
    local seconds="$1"
    local time_msg
    if [[ $seconds -lt 60 ]]; then
        time_msg="${seconds}s"
    elif [[ $seconds -lt 3600 ]]; then
        time_msg="$((seconds / 60))m $((seconds % 60))s"
    elif [[ $seconds -lt 86400 ]]; then
        time_msg="$((seconds / 3600))h $((seconds % 3600 / 60))m"
    else
        time_msg="$((seconds / 86400))d $((seconds % 86400 / 3600))h"
    fi
    echo -n "$time_msg"
}

# Returns wall clock time elapsed since last call to `preexec` in suitable units,
# formatted. The string is empty if less than 5 seconds have elapsed.
# Args: None.
_get_time_message() {
    local stop_seconds="$(_get_timestamp)"
    local seconds=$(( $stop_seconds - $_start_seconds ))
    if [[ $seconds -ge "$DEXTER_TIME_LIMIT_SECS" ]] \
           && [[ "${_is_timed_cmd}" == "true" ]]; then
        echo -n "$(_format_time $seconds) elapsed"
    fi
}

# Returns a formatted string showing the exit status of the last command.
# $1: Numeric exit status of last command.
_get_exit_message() {
    local exit_message
    if [[ $1 -eq 0 ]]; then
        exit_message=""
    elif [[ $1 -gt 128 ]] && [[ $1 -le 159 ]]; then
        signal=$(($1 - 128))
        case $signal in
            2) exit_message="INTerrupted" ;;
            9) exit_message="KILLed" ;;
            15) exit_message="TERMinated" ;;
            17) exit_message="" ;;
            18) exit_message="" ;;
            *) exit_message="SIGNAL $signal" ;;
        esac
    else
        exit_message="exit $?"
    fi
    if [[ -n "$exit_message" ]]; then
        exit_message="${DEXTER_EXIT_STATUS_COLOR}${exit_message}${reset_color}"
    fi
    echo -n "$exit_message"
}

# Prints a formatted string showing the exit status and elapsed wall-clock time
# of the last command.
# $1: Numeric exit status of last command.
_print_postexec_message() {
    local message=""
    if [[ "$DEXTER_SHOW_EXIT_MESSAGE" == 1 ]]; then
        message="${message}$(_get_exit_message "$1")"
    fi
    if [[ "$DEXTER_SHOW_ELAPSED_TIME" == 1 ]]; then
        local time_message="$(_get_time_message)"
        if [[ -n "$time_message" ]]; then
            message="${message:+${message}; }${time_message}"
        fi
    fi
    if [[ -n "$message" ]]; then
        echo -e "(${message})"
    fi
}

# This hook is called before the next prompt is displayed. It shows the exit
# status of the last command and/or the wall-clock time it consumed, if
# needed. Prints a blank line before the next prompt.
# Args: None.
precmd() {
    _print_postexec_message $?
    echo
}

# This hook is called after a command is entered and before it is executed. It
# records the start time of the command to be executed.
# $1: Command string as typed by the user.
# $2: First line of the command, after alias expansion.
# $3: Full command, after alias expansion.
preexec() {
    if [[ "$DEXTER_SHOW_ELAPSED_TIME" == 1 ]]; then
        for cmd in "$DEXTER_UNTIMED_COMMANDS[@]"; do
            if [[ $3 =~ "^${cmd}" ]]; then
                _is_timed_cmd="false"
                return
            fi
        done
        _is_timed_cmd="true"
        _start_seconds="$(_get_timestamp)"
    fi
}
