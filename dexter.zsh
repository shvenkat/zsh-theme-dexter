# A theme with an emphasis on the right (hand) side of the terminal.
#
# The prompt looks like this (_ is your cursor):
#
# %% _                           [env] (master *%) /t/zsh-theme-dexter ticond…
#
# The right prompt shows the following information from left to right, if the
# required plugins are available:
#
# * python virtualenv, using the virtualenv plugin (robbyrussell/oh-my-zsh)
#
# * git status, using the gitfast plugin (robbyrussell/oh-my-zsh)
#
# * fish-style working directory, using the shrink-path plugin
#   (shvenkat/oh-my-zsh)
#
# * abbreviated hostname
#
# Copyright (c) 2016 by Shiv Venkatasubrahmanyam <shiv@alum.mit.edu>.
# License: MIT.


# LEFT PROMPT
# Use '%% ' if the shell is running without privileges, '## ' otherwise.
# Use green text if the last command exited successfully, red otherwise.
PS1='%(?,%{$fg[green]%},%{$fg[red]%})%#%# %{$reset_color%}'


# RIGHT PROMPT

# Hostname.
# Use the first component (upto the first period), truncated to 6 characters.
__host="%7>…>%m%>>"

# Working directory.
# Use a fish-style abbreviation if the shrink-path plugin is available.
if type shrink_path >/dev/null 2>&1; then
    __cwd='$(shrink_path -f -T)'
else
    __cwd='%(5~|%-1~/…/%3~|%4~)'
fi

# Python virtualenv.
ZSH_THEME_VIRTUALENV_PREFIX="["
ZSH_THEME_VIRTUALENV_SUFFIX="]"
__venv='%{$fg[yellow]%}$(virtualenv_prompt_info)%{$reset_color%}'

# Git status
GIT_PS1_SHOWDIRTYSTATE=yes
GIT_PS1_SHOWSTASHSTATE=yes
GIT_PS1_SHOWUNTRACKEDFILES=yes
GIT_PS1_SHOWUPSTREAM="verbose"
GIT_PS1_DESCRIBE_STYLE="branch"
git_status='%{$fg_bold[magenta]%}$(__git_ps1 "(%s)")%{$reset_color%}'

setopt prompt_subst
RPS1='${(e)${__venv}} ${(e)${git_status}} ${(e)${__cwd}} ${__host}'
