# Zsh Themes

Custom [Zsh](http://www.zsh.org) themes.

## Usage

### Antigen

I recommend you to use [Antigen](https://github.com/zsh-users/antigen).

``` zsh
antigen theme yous/zsh-themes lime
```

### oh-my-zsh

Clone this repository and make symbolic links to [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh).

``` sh
git clone https://github.com/yous/zsh-themes.git
cd zsh-themes
ln -s "$PWD/lime.zsh-theme" ~/.oh-my-zsh/themes/lime.zsh-theme
```

Then select the theme in `.zshrc`:

``` zsh
ZSH_THEME="lime"
```
