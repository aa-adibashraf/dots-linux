# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

POWERLEVEL9K_TRANSIENT_PROMPT=always
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# source ~/fzf-git.sh/fzf-git.sh

# source ~/.cargo/env

# Flutter auto-reload runner
run_flutter_auto_reload() {
  local SCRIPT_PATH="./tools/run_with_auto_reload.sh"
  local DEVICE_ID="$1"

  # --- Check for script existence ---
  if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ Error: Script not found at $SCRIPT_PATH"
    echo "Make sure you're in a Flutter project directory with tools/run_with_auto_reload.sh"
    return 1
  fi

  # --- Ask if user wants to open simulator ---
  read -q "OPEN_SIMULATOR?🌀 Do you want to open the iOS Simulator? (y/n) "
  echo ""
  if [[ "$OPEN_SIMULATOR" == "y" || "$OPEN_SIMULATOR" == "Y" ]]; then
    echo "📱 Opening iOS Simulator..."
    open -a Simulator
    echo "⏳ Waiting for simulator to boot..."
    # Wait until booted (using xcrun simctl)
    until xcrun simctl list devices | grep -q "(Booted)"; do
      sleep 2
    done
    echo "✅ Simulator booted!"
  fi

  # --- Run the Flutter script ---
  echo "🚀 Running Flutter app..."
  if [ -n "$DEVICE_ID" ]; then
    echo "📱 Target device: $DEVICE_ID"
    bash "$SCRIPT_PATH" "$DEVICE_ID"
  else
    bash "$SCRIPT_PATH"
  fi

  # --- Check exit status ---
  local STATUS=$?
  if [ $STATUS -eq 0 ]; then
    echo "✅ Flutter app finished successfully!"
  else
    echo "❌ Flutter app failed with exit code $STATUS"
  fi
}

# Add alias shortcut
alias fra='run_flutter_auto_reload'


# ---- Eza (better ls) -----

alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"
alias c= clear
alias ga='git add'
alias gc='git commit -m'
alias gca='git commit -a -m'

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

eval "$(zoxide init zsh)"

alias cd="z"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

export EDITOR=nvim

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$PATH":"$HOME/.pub-cache/bin"

# Added by LM Studio CLI (lms)
# export PATH="$PATH:/Users/adibashraf/.lmstudio/bin"
# End of LM Studio CLI section

eval "$(starship init zsh)"

autoload -Uz add-zsh-hook
add-zsh-hook precmd transient-prompt-precmd

TRANSIENT_PROMPT="${PROMPT// prompt / prompt --profile transient }"
TRANSIENT_RPROMPT="${PROMPT// prompt / prompt --profile rtransient }"

function transient-prompt-precmd {
    # Fix ctrl+c behavior
    TRAPINT() { transient-prompt; return $(( 128 + $1 )) }

    # Save transient prompt
    SAVED_PROMPT="$(eval "printf '%s' \"${TRANSIENT_PROMPT}\"")"
    SAVED_RPROMPT="$(eval "printf '%s' \"${TRANSIENT_RPROMPT}\"")"
}

autoload -Uz add-zle-hook-widget
add-zle-hook-widget zle-line-finish transient-prompt

function transient-prompt() {
    # Use saved transient prompt
    PROMPT="$SAVED_PROMPT" RPROMPT="$SAVED_RPROMPT" zle .reset-prompt
}

# Added by Antigravity
# export PATH="/Users/adibashraf/.antigravity/antigravity/bin:$PATH"
