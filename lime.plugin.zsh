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

prompt_lime_user() {
  local prompt_color="${LIME_USER_COLOR:-109}"
  if (( ${LIME_SHOW_HOSTNAME:-0} )) && [[ -n "$SSH_CONNECTION" ]]; then
    echo "%F{${prompt_color}}%n@%m%f"
  else
    echo "%F{${prompt_color}}%n%f"
  fi
}

prompt_lime_dir() {
  local prompt_color="${LIME_DIR_COLOR:-143}"
  echo "%F{${prompt_color}}%~%f"
}

prompt_lime_git() {
  # Get VCS information
  vcs_info

  # Store working_tree without the 'x' prefix
  local working_tree="${vcs_info_msg_1_#x}"
  [[ -n $working_tree ]] || return

  local prompt_color="${LIME_GIT_COLOR:-109}"
  echo "%F{${prompt_color}}${vcs_info_msg_0_}$(prompt_lime_git_dirty)%f "
}

prompt_lime_git_dirty() {
  local git_status_options=(--porcelain -unormal)
  if [[ "$prompt_lime_git_post_1_7_2" -ge 0 ]]; then
    git_status_options+=(--ignore-submodules=dirty)
  fi

  test -z "$(command git status $git_status_options)"
  (( $? )) && echo '*'
}

prompt_lime_symbol() {
  if [ $UID -eq 0 ]; then
    echo '#'
  else
    echo '$'
  fi
}

prompt_lime_setup() {
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

  setopt prompt_subst
  PROMPT='$(prompt_lime_user) $(prompt_lime_dir) $(prompt_lime_git)$(prompt_lime_symbol) '
}

prompt_lime_setup

# Clean up the namespace
unfunction git_compare_version
