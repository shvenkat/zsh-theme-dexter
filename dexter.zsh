# A theme with an emphasis on the right side (hence the name) of the terminal.
#
# The prompt looks as follows, where _ is the cursor:
#
# ▶▶ false                                [env] (master *%) ~/f/b/quux megatr…
# exit 1
#
# ▶▶ true                                 [env] (master *%) ~/f/b/quux megatr…
#
# ▶▶ _                                    [env] (master *%) ~/f/b/quux megatr…
#
# Features:
#
#   * A blank line before each prompt. If the previous command exited with a
#     non-zero status, the blank line is preceeded by a line indicating the exit
#     status.
#
#   * The left prompt indicates the privilege of the shell (## if privileged, ▶▶
#     otherwise).
#
#   * The right prompt shows the following information from left to right, if
#     the corresponding plugins are available:
#       + python virtualenv, using the oh-my-zsh virtualenv plugin,
#       + git status, using the oh-my-zsh gitfast plugin,
#       + fish-style abbreviated working directory, using the oh-my-zsh
#         shrink-path plugin, and
#       + abbreviated hostname.
#
# To facilitate integration with terminal color schemes, the color of certain
# elements can be customized using the following variables. The default colors
# shown below are intended for use with the solarized dark palette. To override
# these, specify any valid terminal/ANSI color escape sequences.
#
#   DEXTER_EXIT_FAILURE_COLOR    red          $fg[red]
#   DEXTER_VENV_COLOR            yellow       $fg[yellow]
#   DEXTER_GIT_COLOR             violet       $fg_bold[magenta]
#   DEXTER_WORKDIR_COLOR         normal       $fg[default]
#   DEXTER_HOSTNAME_COLOR        dark gray    $fg_bold[green]
#
# Copyright (c) 2016 by Shiv Venkatasubrahmanyam <shiv@alum.mit.edu>.
# License: MIT.

setopt prompt_subst

DEXTER_EXIT_FAILURE_COLOR=${DEXTER_EXIT_FAILURE_COLOR=$fg[red]}
DEXTER_VENV_COLOR=${DEXTER_VENV_COLOR=$fg[yellow]}
DEXTER_GIT_COLOR=${DEXTER_GIT_COLOR=$fg_bold[magenta]}
DEXTER_WORKDIR_COLOR=${DEXTER_WORKDIR_COLOR=$fg[default]}
DEXTER_HOSTNAME_COLOR=${DEXTER_HOSTNAME_COLOR=$fg_bold[green]}


# LEFT PROMPT

# Use a horizontal line as a separator before each prompt.
precmd() {
    eval "\
        if [[ $? -gt 0 ]] && [[ $? -lt 128 ]] || [[ $? -gt 159 ]]; then \
            echo -e \"${DEXTER_EXIT_FAILURE_COLOR}exit $?${reset_color}\"; \
        fi; \
        echo"
}
# Use '▶▶ ' if the shell is running without privileges, '## ' otherwise.
PS1='%(!.#.▶)%(!.#.▶) '


# RIGHT PROMPT

RPS1=''

# Python virtualenv.
if type virtualenv_prompt_info >/dev/null 2>&1; then
    ZSH_THEME_VIRTUALENV_PREFIX="["
    ZSH_THEME_VIRTUALENV_SUFFIX="]"
    RPS1+='%{${DEXTER_VENV_COLOR}%}$(virtualenv_prompt_info)%{$reset_color%} '
fi

# Git status
if type __git_ps1 >/dev/null 2>&1; then
    GIT_PS1_SHOWDIRTYSTATE=yes
    GIT_PS1_SHOWSTASHSTATE=yes
    GIT_PS1_SHOWUNTRACKEDFILES=yes
    GIT_PS1_SHOWUPSTREAM="verbose"
    GIT_PS1_DESCRIBE_STYLE="branch"
    RPS1+='%{${DEXTER_GIT_COLOR}%}$(__git_ps1 "(%s)")%{$reset_color%} '
fi

# Working directory.
if type shrink_path >/dev/null 2>&1; then
    # Use a fish-style abbreviation.
    RPS1+='%{${DEXTER_WORKDIR_COLOR}%}$(shrink_path -l -t -T)%{$reset_color%} '
else
    # Show at most 1 leading and 2 trailing path components.
    RPS1+='%{${DEXTER_WORKDIR_COLOR}%}%(4~|%-1~/…/%2~|%3~)%{$reset_color%} '
fi

# Hostname.
# Use the first component (upto the first period), truncated to 6 characters.
RPS1+='%{${DEXTER_HOSTNAME_COLOR}%}%7>…>%m%>>%{$reset_color%}'
