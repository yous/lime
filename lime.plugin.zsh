prompt_lime_user() {
  echo '%F{109}%n%f'
}

prompt_lime_dir() {
  echo '%F{143}%~%f'
}

prompt_lime_git() {
  # Get VCS information
  vcs_info

  # Store working_tree without the 'x' prefix
  local working_tree="${vcs_info_msg_1_#x}"
  [[ -n $working_tree ]] || return

  echo "%F{109}${vcs_info_msg_0_}$(prompt_lime_git_dirty)%f "
}

prompt_lime_git_dirty() {
  test -z "$(command git status --porcelain --ignore-submodules=dirty -unormal)"
  (( $? )) && echo "*"
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

  setopt prompt_subst
  PROMPT='$(prompt_lime_user) $(prompt_lime_dir) $(prompt_lime_git)$(prompt_lime_symbol) '
}

prompt_lime_setup
