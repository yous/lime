# Outputs -1, 0, or 1 if the installed git version is less than, equal to, or
# greater than the input version, respectively
git_compare_version() {
  local input_version
  local installed_version
  input_version=(${(s/./)1})
  installed_version=($(command git --version 2>/dev/null))
  installed_version=(${(s/./)installed_version[3]})

  for i in {1..3}; do
    if [[ $installed_version[$i] -gt $input_version[$i] ]]; then
      echo 1
      return 0
    fi
    if [[ $installed_version[$i] -lt $input_version[$i] ]]; then
      echo -1
      return 0
    fi
  done
  echo 0
}

prompt_lime_precmd() {
  # Set title
  prompt_lime_set_title

  # Get VCS information
  vcs_info
}

prompt_lime_preexec() {
  # Show the current job
  prompt_lime_set_title "$1"
}

prompt_lime_set_title() {
  local window_title="$(prompt_lime_window_title)"
  local tab_title="$(prompt_lime_tab_title "$@")"

  # Inside screen or tmux
  case "$TERM" in
    screen*)
      # Set window title
      print -n '\e]0;'
      echo -n "${window_title}"
      print -n '\a'

      # Set window name
      print -n '\ek'
      echo -n "${tab_title}"
      print -n '\e\\'
      ;;
    cygwin|putty*|rxvt*|xterm*)
      # Set window title
      print -n '\e]2;'
      echo -n "${window_title}"
      print -n '\a'

      # Set tab name
      print -n '\e]1;'
      echo -n "${tab_title}"
      print -n '\a'
      ;;
    *)
      # Set window title if it's available
      zmodload zsh/terminfo
      if [[ -n "$terminfo[tsl]" ]] && [[ -n "$terminfo[fsl]" ]]; then
        echoti tsl
        echo -n "${window_title}"
        echoti fsl
      fi
      ;;
  esac
}

prompt_lime_window_title() {
  # Username, hostname and current directory
  print -Pn '%n@%m: %~'
}

prompt_lime_tab_title() {
  if [ "$#" -eq 1 ]; then
    echo -n "$(prompt_lime_first_command "$1")"
  else
    # `%40<..<` truncates following string longer than 40 characters with `..`.
    # `%~` is current working directory with `~` instead of full `$HOME` path.
    # `%<<` sets the end of string to truncate.
    print -Pn '%40<..<%~%<<'
  fi
}

prompt_lime_first_command() {
  setopt local_options extended_glob

  # Return the first command excluding env, options, sudo, ssh
  print -rn ${1[(wr)^(*=*|-*|sudo|ssh)]:gs/%/%%}
}

prompt_lime_render() {
  echo -n "${prompt_lime_rendered_user}"
  echo -n ' '
  prompt_lime_dir
  echo -n ' '
  prompt_lime_git
  echo -n "${prompt_lime_rendered_symbol}"
}

prompt_lime_user() {
  local prompt_color="${LIME_USER_COLOR:-$prompt_lime_default_user_color}"
  if (( ${LIME_SHOW_HOSTNAME:-0} )) && [[ -n "$SSH_CONNECTION" ]]; then
    echo -n "%F{${prompt_color}}%n@%m%f"
  else
    echo -n "%F{${prompt_color}}%n%f"
  fi
}

prompt_lime_dir() {
  local prompt_color="${LIME_DIR_COLOR:-$prompt_lime_default_dir_color}"
  local dir_components="${LIME_DIR_DISPLAY_COMPONENTS:-0}"
  if (( dir_components )); then
    echo -n "%F{${prompt_color}}%($((dir_components + 1))~:...%${dir_components}~:%~)%f"
  else
    echo -n "%F{${prompt_color}}%~%f"
  fi
}

prompt_lime_git() {
  # Store working_tree without the 'x' prefix
  local working_tree="${vcs_info_msg_1_#x}"
  [[ -n $working_tree ]] || return

  local prompt_color="${LIME_GIT_COLOR:-$prompt_lime_default_git_color}"
  echo -n "%F{${prompt_color}}${vcs_info_msg_0_}$(prompt_lime_git_dirty)%f "
}

prompt_lime_git_dirty() {
  local git_status_options
  git_status_options=(--porcelain -unormal)
  if [[ "$prompt_lime_git_post_1_7_2" -ge 0 ]]; then
    git_status_options+=(--ignore-submodules=dirty)
  fi

  [ -n "$(command git status $git_status_options)" ] && echo -n '*'
}

prompt_lime_symbol() {
  if [ $UID -eq 0 ]; then
    echo -n '#'
  else
    echo -n '$'
  fi
}

prompt_lime_setup() {
  precmd_functions+=(prompt_lime_precmd)
  preexec_functions+=(prompt_lime_preexec)

  autoload -Uz vcs_info

  zstyle ':vcs_info:*' enable git
  # Export only two msg variables from vcs_info
  zstyle ':vcs_info:*' max-exports 2
  # %s: The current version control system, like 'git' or 'svn'
  # %r: The name of the root directory of the repository
  # #S: The current path relative to the repository root directory
  # %b: Branch information, like 'master'
  # %m: In case of Git, show information about stashes
  # %u: Show unstaged changes in the repository (works with 'check-for-changes')
  # %c: Show staged changes in the repository (works with 'check-for-changes')
  #
  # vcs_info_msg_0_ = '%b'
  # vcs_info_msg_1_ = 'x%r' x-prefix prevents creation of a named path
  #                         (AUTO_NAME_DIRS)
  zstyle ':vcs_info:git*' formats '%b' 'x%r'
  # '%a' is for action like 'rebase', 'rebase-i', 'merge'
  zstyle ':vcs_info:git*' actionformats '%b(%a)' 'x%r'

  # The '--ignore-submodules' option is introduced on git 1.7.2
  prompt_lime_git_post_1_7_2=$(git_compare_version '1.7.2')

  # Support 8 colors
  if [[ "$TERM" = *"256color" ]]; then
    prompt_lime_default_user_color=109
    prompt_lime_default_dir_color=143
    prompt_lime_default_git_color=109
  else
    prompt_lime_default_user_color=cyan
    prompt_lime_default_dir_color=green
    prompt_lime_default_git_color=cyan
  fi

  prompt_lime_rendered_user="$(prompt_lime_user)"
  prompt_lime_rendered_symbol="$(prompt_lime_symbol)"

  # If set, parameter expansion, command substitution and arithmetic expansion
  # is performed in prompts
  setopt prompt_subst
  PROMPT='$(prompt_lime_render) '
}

prompt_lime_setup

# Clean up the namespace
unfunction git_compare_version
