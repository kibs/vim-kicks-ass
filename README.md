Vim Kicks Ass
=============

This is an attempt of creating some sort of framework for managing you VIM configuration, in a social way.
A lot of people share their .vimrc on github, which is great, but chances that you find exactly the VIM
configuration you like is pretty small. This project is (or will be) a collection of popular VIM plugins,
colorschemes and custom made presets, which can be enabled or disabled easily using the included
vim-kicks-ass plugin. You will also find templates which you can use as your own vimrc, or you can
use them for inspiration for creating your own.

My inspiration comes from the great [oh-my-zsh](https://github.com/robbyrussel/oh-my-zsh) project, where a lot of
people has forked, contributed and otherwise helped creating a great framework for configuring zshell. I 
wan't the same for VIM.

I am not the greatest vimscript developer, nor am I the most advanced superuser of VIM, but with help from
the community, I hope this project can become a great help for all those VIM lovers out there.

Requirements
------------

haven't testet a lot, as this is an alpha release, but you should have

* VIM 7.3
* git in your path

Installation
------------

3 small steps is required for getting up and running

```sh
# clone this repository
$ git clone https://github.com/kibs/vim-kicks-ass.git ~/.vim-kicks-ass

# enable vim-kicks-ass
$ mkdir -p ~/.vim/autoload
$ ln -s ~/.vim-kicks-ass/vim_kicks_ass.vim ~/.vim/autoload/vim_kicks_ass.vim

# create a .vimrc file, and use functions described further down, or choose a template as a starting point
$ cp ~/.vim-kicks-ass/templates/vimrc ~/.vimrc
```

And you should be good to go. *important!* the first time you start vim, it can take some time depending on how many plugins you enabled

Upgrading
---------

just goto your vim-kicks-ass folder and update using git
```
$ cd ~/.vim-kicks-ass
$ git pull
$ git submodule update
```

Functions
---------

### vim_kicks_ass#with_plugins()

Use this for enabling all the plugins you want, can be called as many times you want. Can take a single string, or a list of plugins

```vimscript
call vim_kicks_ass#with_plugins("fugitive")
call vim_kicks_ass#with_plugins(["markdown", "surround"])
```

### vim_kicks_ass#without_plugins()

if you want to remove a plugin, after you already added it, you can use this

```vimscript
call vim_kicks_ass#without_plugins("fugitive")
call vim_kicks_ass#without_plugins(["markdown", "surround"])
```

### vim_kicks_ass#using_colorschemes()

load all the colorschemes you want, and don't forget to actually set it

```vimscript
call vim_kicks_ass#using_colorschemes("jellybeans")
colorscheme jellybeans
```

### vim_kicks_ass#using_presets()

presets are just small blocks of configuration, if you like a specific preset you can enable it, and save yourself some configuration

```vimscript
call vim_kicks_ass#using_presets("ruby")
```

Contributing
------------

Please fork and send pull requests, together we can make this big ;)

Thanks
------

I have copied some functions from the great [pathogen](https://github.com/tpope) project by [Tim Pope](https://github.com/tpope), his vim plugins are the best!
