export ZSH="$HOME/.oh-my-zsh"

# avoid duplicates..
export HISTCONTROL=ignoredups:erasedups

# append history entries..
setopt APPEND_HISTORY

# After each command, save and reload history
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

export GOPATH=$HOME/go
PATH="$PATH:$HOME/.local/bin:$GOPATH/bin:$HOME/.scripts:$GOPATH:$GOPATH/bin:/opt/homebrew/bin"
VIMRC="$HOME/.config/nvim"
EDITOR='nvim'
VISAUL=$EDITOR

plugins=(git)

fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure

source $ZSH/oh-my-zsh.sh

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
export HISTTIMEFORMAT="%F %T "

function pin() {
	if [[ ! -f $HOME/.pbklist ]]; then
		touch $HOME/.pbklist
	fi
	if [[ $1 == "" ]]; then
		echo "Please specify 'mark', 'rm', 'clearall', 'list', 'find', or a label"
	elif [[ $1 == "mark" || $1 == "mk" || $1 == "s" ]]; then
		pin rm $2 # delete entry if it already exists
		echo $2::$(pwd) >> $HOME/.pbklist
	elif [[ $1 == "rm" ]]; then
		for i in {2.."$#"}; do
			sed -i '' "/$@[i]::/d" $HOME/.pbklist
		done
	elif [[ $1 == "l" || $1 == "list" ]]; then
		cat $HOME/.pbklist
	elif [[ $1 == "clearall" ]]; then
		rm $HOME/.pbklist
		touch $HOME/.pbklist
	elif [[ $1 == "find" ]]; then
		grep -i "$2" $HOME/.pbklist
	else
		mkr=$(grep "$1::" $HOME/.pbklist)
		if [[ mkr == "" ]]; then
			echo "No bookmark $1 found"
		else
			cd ${mkr//$1:://}
		fi
	fi
}

function b64d() {
    echo "$1" | base64 --decode
}

func hgl() {
PS3="branch: "
select branch in $(hg branch | grep $1); do
    if [[ $branch == 'exit' ]]; then
        break
    fi
    git checkout $branch
    break
done
COLUMNS=0
}

func hg() {
    if [[ $(ls | wc -l) > 0 ]]; then
        rm debug.test* # remove debug.test* files generated by dlv
    fi
    if [[ $1 == "init" ]]; then
        git checkout -b $2
    elif [[ $1 == "revert-uncommitted" ]]; then
        git add -A
        git reset --hard HEAD
    elif [[ $1 == "push" ]]; then
        if [[ $2 == "up" ]]; then
            git push -u origin $(curb)
        else
	    git pull --no-ff
            git push
        fi
    elif [[ $1 == "uc" ]]; then
        echo '`uploadchain` is unsupported. Doing basic `hg push` for now'
        git push
    elif [[ $1 == "ac" ]]; then
        if [[ $2 == "" ]]; then
            echo "Commit message required but not supplied"
        else
            git add -A
            git commit -m $2
        fi
    elif [[ $1 == "acpush" ]]; then
        hg ac $2
        git push
    elif [[ $1 == "rename" ]]; then
        git branch -m "$2"
    elif [[ $1 == "sync" ]]; then
        if [[ $2 == "" ]]; then
            echo "Branch name must be provided"
        else
            git merge $2
        fi
    elif [[ $1 == "delete-merged-branch" ]]; then
        branch=$(curb)
        git checkout main
        git branch -D $branch
    elif [[ $1 == "prune" ]]; then
        if [[ $2 == "" ]]; then
            echo "Branch name must be provided"
        elif [[ $2 == "this" ]]; then
            delb=$(curb)
            git checkout main
            git branch -D $delb
        else
            git branch -D $2
        fi
    elif [[ $1 == "sync-rebase" || $1 == "rebase-sync" || $1 == "rs" || $1 == "sr" ]]; then
        if [[ $2 == "" ]]; then
            git pull --rebase
        fi
        cb=$(curb)
        git checkout $2
        git pull --rebase
        git checkout $cb
        git merge $2
    elif [[ $1 == "pull" ]]; then
        git pull
    elif [[ $1 == "revert" ]]; then
        if [[ $2 == "" ]]; then
            git reset --hard HEAD
        else
            git reset --hard HEAD~$2
        fi
    elif [[ $1 == "stash" ]]; then
        if [[ $2 != "" ]]; then
            for i in {2.."$#"}; do
                git stash -- $@[i]
            done
        else
            git stash
        fi
    elif [[ $1 == "apply" ]]; then
        git stash apply
    elif [[ $1 == "checkout" || $1 == "c" ]]; then
        if [[ $2 == "-n" || $2 == "-b" ]]; then
            git checkout -b $3
        else
            git checkout $2
        fi
    elif [[ $1 == "cc" ]]; then
        git checkout ruizha/FINPLAT-$2
    elif [[ $1 == "status" ]]; then
        if [[ $2 != "" ]]; then
            git diff --diff-filter=MA --name-status $2...
        else
            st=$(git status)
            st=${st//git add/hg amend}
            st=${st//git push/hg push}
            echo $st
        fi
    elif [[ $1 == "amend" ]]; then
        if [[ $2 == "-a" || $2 == "-A" || $2 == "" ]]; then
            git add -A
        else
            for i in {2.."$#"}; do
                git add $@[i]
            done
        fi
    elif [[ $1 == "commit" ]]; then
        git commit -m $2
    elif [[ $1 == "diff" ]]; then
        if [[ $2 != "" ]]; then
            git diff $2...$(curb)
        else
            git diff
        fi
    elif [[ $1 == "untrack" ]]; then
        for i in {2.."$#"}; do
			git rm --cached $@[i]
		done
    elif [[ $1 == "log" ]]; then
        git log
    elif [[ $1 == "mv" ]]; then
        git mv $1 $2
    elif [[ $1 == "branch" ]]; then
        if [[ $2 != '' ]]; then
            git branch | grep $2
        else
            git branch
        fi
    elif [[ $1 == "rebase" ]]; then
        git rebase --onto $1 $(curb)
    elif [[ $1 == "checkout-file" || $1 == "copy" ]]; then
        if [[ $3 != "" ]]; then
            echo "Checking out file $2 in branch $3"
            git checkout $3 -- $2
        else
            echo "Checking out file $2 branch main"
            git checkout main -- $2
        fi
    elif [[ $1 == "help" ]]; then
        echo "Available commands:"

        echo "Working with commits (write):"
        echo "\tamend:                      git add all"
        echo "\tcommit (message):           git commit -m (message)"
        echo "\tpush [up]:                  git push OR git push -u origin \$current_branch"
        echo ""
        echo "\tac:                         adds and commits all changes"
        echo "\tacpush:                     adds, commits, and pushes all changes"
        echo "\tstash:                      git stash"
        echo "\tapply:                      git stash apply"
        echo "\tmv:                         renames file"
        echo "\trevert-uncommited:          reverts all changes in current branch that have not been committed"
        echo "\trs (branch):                pulls (branch) from remote and syncs current branch to it"
        echo ""

        echo "Working with commits (read):"
        echo "\tuntrack (file) [files...]:  untrack listed files"
        echo "\tlog:                        git log"
        echo ""
        echo "Working with branches (write):"
        echo "\tinit [branch-name]:         git checkout -b [branch-name]"
        echo "\trename:                     renames branch"
        echo "\trebase [branch-name]:       rebases onto [branch-name]"
        echo "\tsync (branch):              sync current branch to remote or to (branch) by pulling (branch)'s remote"
        echo "\tsync-rebase (branch):       performs a 'git pull --rebase' on target branch and then merges current
                                            branch with target brnach"
        echo "\trevert [number]:            reverts to HEAD~[number]"
        echo ""

        echo "Working with branches (read):"
        echo "\tstatus:                     git status"
        echo "\tdiff (--all):               uncommitted changes or all files that differ between current branch and main (--all)"
        echo "\tcheckout/c [-n/-b] (name):  git checkout"
        echo "\tdelete-merged-branch:       deletes the current branch"
        echo "\tprune (branch-name):        deletes (branch-name)"
        echo ""

        echo "Working with files:"
        echo "\tcheckout-file [filepath] (branch):     checks out file in (branch)"
        echo "\thelp:                       help"
    else
        hg help
    fi
}

function sdot() {
	pin mark tmp_sdot

	cp $HOME/.zshrc $HOME/repos/dots/.zshrc
	cp $HOME/.tmux.conf $HOME/repos/dots/.tmux.conf
	cp $HOME/.vimrc $HOME/repos/dots/.vimrc
    cp -r $HOME/.scripts $HOME/repos/.scripts
    msg=""
    if [[ $1 != "" ]]; then
        msg=$1
    fi
	cd $HOME/repos/dots
	git add -A
	git commit -m "Updating dots $(date +%d.%m.%y-%H:%M:%S) [$msg]"
	git push origin main
	pin tmp_sdot
	pin rm tmp_sdot
}

function jsoncheck() {
    if jq -e . >/dev/null 2>&1 <<<$(cat $1); then
        echo "Parsed JSON successfully and got something other than false/null"
    else
        echo "Failed to parse JSON, or got false/null"
    fi
}

function getuuid() {
    uuidgen | awk '{ print tolower($0) }'
}

function check-url-exists() {
    if curl --head --silent --fail $1 2> /dev/null;
     then
      echo "This page exists."
     else
      echo "This page does not exist."
    fi
}

func nn() {
    cl=$(pwd)
    cd $(git rev-parse --show-toplevel)
    fp=$(fzf)
    if [[ fp != '' ]]; then
	nvim $fp
    fi
    cd $cl
}

export TERM="xterm-256color"
alias tmux="TERM=screen-256color-bce tmux"
alias zz="source ~/.zshrc"
alias ze="nvim ~/.zshrc && zz"
alias python="python3"
alias curb="git rev-parse --abbrev-ref HEAD"
alias fport="sudo lsof -i -P | grep LISTEN | grep"
alias dlv="$HOME/go/bin/dlv"
alias hgc="hg c"
alias hgp="hg push"
alias hgcc="hg cc"
alias ve="nvim $HOME/.config/nvim"
alias gitsha="git rev-parse HEAD"
alias prettyjson='python -m json.tool'
alias history='history -f'
alias vf='nvim $(fzf)'
alias nf='nvim $(fzf)'
alias vim='nvim'
alias vimconf='nvim ~/.config/nvim/init.vim'
alias pdlv='python $HOME/.scripts/delver.py'
alias nvidia-driver='cat /proc/driver/nvidia/version'
alias pbcopy='xclip -selection clipboard'
