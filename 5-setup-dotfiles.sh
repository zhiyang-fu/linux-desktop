git clone --separate-git-dir=$HOME/.dotfiles git@github.com:zhiyang-fu/dotfiles.git dotfiles-tmp
rsync --recursive --verbose --exclude={'.git'} dotfiles-tmp/ $HOME/
rm --recursive dotfiles-tmp
#git clone --bare git@github.com:zhiyang-fu/dotfiles.git
#git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout -f
dotfiles config --local status.showUntrackedFiles no

#install python3 for pubs
sudo pacman -S python
python -m ensurepip --upgrade
python -m pip install --upgrade pip
pip3 install argcomplete
mkdir $HOME/.bash_completion.d
activate-global-python-argcomplete --dest=$HOME/.bash_completion.d

#vim plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# add the following to line 56 of .vim/plugged/targets.vim/autoload/targets/mappings.vim
#                     \ '%': {'separator': [{'d': '%'}]},




