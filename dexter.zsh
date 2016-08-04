# A theme with an emphasis on the right side (hence the name) of the terminal.
#
# The prompt looks as follows, where _ is the cursor:
#
# ────────────────────────────────────────────────────────────────────────────
# %% _                                    [env] (master *%) ~/f/b/quux megatr…
#
#
# Features:
#
#   * A horizontal line before each prompt.
#
#   * The left prompt indicates:
#     + exit status of the previous command (green for 0, red otherwise), and
#     + privilege of the shell (## if privileged, %% otherwise).
#
#   * The right prompt shows the following information from left to right, if
#     the corresponding plugins are available:
#     + python virtualenv, using the virtualenv plugin (robbyrussell/oh-my-zsh),
#     + git status, using the gitfast plugin (robbyrussell/oh-my-zsh),
#     + fish-style abbreviated working directory, using the shrink-path plugin
#       (shvenkat/oh-my-zsh), and
#     + abbreviated hostname.
#
# To facilitate integration with terminal color schemes, the color of certain
# elements can be customized using the following variables. The default colors
# shown below are intended for use with the solarized dark palette. To override
# these, specify any valid terminal/ANSI color escape sequences.
#
#   DEXTER_SEPARATOR_COLOR       black        $fg[black]
#   DEXTER_EXIT_SUCCESS_COLOR    green        $fg[green]
#   DEXTER_EXIT_FAILURE_COLOR    red          $fg[red]
#   DEXTER_VENV_COLOR            yellow       $fg[yellow]
#   DEXTER_GIT_COLOR             violet       $fg_bold[magenta]
#   DEXTER_WORKDIR_COLOR         normal       $fg[default]
#   DEXTER_HOSTNAME_COLOR        dark gray    $fg_bold[green]
#
# Finally, the line drawing character(s) can be changed using the variable
# DEXTER_SEPARATOR_CHARS. The default value is the Unicode character 'BOX
# DRAWINGS HEAVY HORIZONTAL' (U+2501).
#
#
# Copyright (c) 2016 by Shiv Venkatasubrahmanyam <shiv@alum.mit.edu>.
# License: MIT.

setopt prompt_subst

DEXTER_SEPARATOR_COLOR=${DEXTER_SEPARATOR_COLOR=$fg[black]}
DEXTER_EXIT_SUCCESS_COLOR=${DEXTER_EXIT_SUCCESS_COLOR=$fg[green]}
DEXTER_EXIT_FAILURE_COLOR=${DEXTER_EXIT_FAILURE_COLOR=$fg[red]}
DEXTER_VENV_COLOR=${DEXTER_VENV_COLOR=$fg[yellow]}
DEXTER_GIT_COLOR=${DEXTER_GIT_COLOR=$fg_bold[magenta]}
DEXTER_WORKDIR_COLOR=${DEXTER_WORKDIR_COLOR=$fg[default]}
DEXTER_HOSTNAME_COLOR=${DEXTER_HOSTNAME_COLOR=$fg_bold[green]}


# LEFT PROMPT

# Use a horizontal line as a separator before each prompt.
__separator=${DEXTER_SEPARATOR_CHARS='━'}
while [[ ${#__separator} -lt 1024 ]]; do
    __separator+="$__separator"
done
PS1='%{${DEXTER_SEPARATOR_COLOR}%}${__separator[0,$COLUMNS]}%{$reset_color%}
'
# Use '%% ' if the shell is running without privileges, '## ' otherwise.
# Use green text if the last command exited successfully, red otherwise.
PS1+='%(?,%{${DEXTER_EXIT_SUCCESS_COLOR}%},%{${DEXTER_EXIT_FAILURE_COLOR}%})%#%# %{$reset_color%}'


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
    RPS1+='%{${DEXTER_WORKDIR_COLOR}%}$(shrink_path -f -T)%{$reset_color%} '
else
    # Show at most 1 leading and 2 trailing path components.
    RPS1+='%{${DEXTER_WORKDIR_COLOR}%}%(4~|%-1~/…/%2~|%3~)%{$reset_color%} '
fi

# Hostname.
# Use the first component (upto the first period), truncated to 6 characters.
RPS1+='%{${DEXTER_HOSTNAME_COLOR}%}%7>…>%m%>>%{$reset_color%}'
