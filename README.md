## How to install
`cd ~`

`echo ".cfg" >> .gitignore`

`git clone git@github.com:aaronzper/dotfiles.git ./.dotfiles-git --bare`

`alias dotfiles='git --git-dir=$HOME/.dotfiles-git/ --work-tree=$HOME'`

`dotfiles config --local status.showUntrackedFiles no`

`dotfiles checkout`

Taken from [here](https://www.ackama.com/what-we-think/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained/).
