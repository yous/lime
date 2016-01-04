# Zsh Themes

Custom [Zsh](http://www.zsh.org) themes.

## Usage

### Antigen

To load `lime.zsh-theme` on [Antigen](https://github.com/zsh-users/antigen):

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

### zgen

To load `lime.zsh-theme` on [zgen](https://github.com/tarjoilija/zgen):

``` zsh
zgen load yous/zsh-themes lime
```

### zplug

I recommend you to use [zplug](https://github.com/b4b4r07/zplug). To load
`lime.zsh-theme`:

``` sh
zplug "yous/zsh-themes", of:"lime.zsh-theme"
```

## Demo

### Lime

![Lime](https://raw.githubusercontent.com/yous/zsh-themes/master/demo/lime.png)

## License

Copyright (c) 2014-2016 Chayoung You. See [LICENSE.txt](LICENSE.txt) for
details.
