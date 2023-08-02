#!/bin/sh

echo_installed(){
    echo "$1 has been installed"
}

echo_installing(){
    echo "installing $1"
}

echo_updating(){
    echo "updating $1"
}

# install zsh
if type zsh > /dev/null 2>&1; then
    echo_installed zsh
else
    if type apt > /dev/null 2>&1; then
        sudo apt install zsh
    elif type pacman > /dev/null 2>&1; then
        sudo pacman -S zsh
    fi
fi

# install oh-my-zsh
if [ -d ~/.oh-my-zsh ]; then
    echo_installed oh-my-zsh
else
    echo_installing oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# change oh-my-zsh theme
ZSH_THEME=agnoster
echo "change theme to $ZSH_THEME"
sed -i "/^ZSH_THEME=/s/".*"/"$ZSH_THEME"/" ~/.zshrc

ZSH_CLONE_PLUGINS=(zsh-users/zsh-syntax-highlighting marlonrichert/zsh-autocomplete)

for plugin in ${ZSH_CLONE_PLUGINS[*]}; do
    plugin_name=$(echo $plugin | sed -n "s/\([^\/]*\)\/\([^\/]*\)/\2/p")

    if [ ! -d ~/.oh-my-zsh/custom/plugins/$plugin_name ]; then
        echo_installing $plugin
        git clone https://github.com/$plugin.git ~/.oh-my-zsh/custom/plugins/$plugin_name
    else
        echo_updating $plugin
        cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/ && git pull
    fi
done

install_zsh_plugin(){
    PLUGIN_NAME=$1
    PLUGINS_LINE=$(sed -n "/^plugins=/p" ~/.zshrc)

    if ! echo $PLUGINS_LINE | grep " $PLUGIN_NAME[ \)]" >/dev/null; then
        echo_installing $PLUGIN_NAME
        sed -i "/^plugins=/s/(\([^)]\+\))/(\1 $PLUGIN_NAME)/" ~/.zshrc;
    else
        echo_installed $PLUGIN_NAME
    fi

}

ZSH_PLUGINS=(zsh-syntax-highlighting zsh-autocomplete z)

for plugin in ${ZSH_PLUGINS[*]}; do
    install_zsh_plugin $plugin
done 
