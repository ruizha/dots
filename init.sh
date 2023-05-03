osname=$(uname -s)
command=""
if [[ osname == "Darwin" ]]; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	command="brew install"
elif [[ osname == "Linux" ]]; then
	sudo apt update
	command="sudo apt install"
fi

$command git zsh curl tmux vim
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

curl https://raw.githubusercontent.com/ruizha/dots/main/.tmux.conf > $HOME/.tmux.conf
curl https://github.com/ruizha/dots/blob/main/.zshrc > $HOME/.tmux.conf
