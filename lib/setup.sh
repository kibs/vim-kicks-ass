#!/bin/sh

# make sure we work from toolbox root
cd `dirname $0`/..
toolbox=`pwd -P`
autoloadpath="$HOME/.vim/autoload"
bundlepath="$HOME/.vim/bundle"

# make sure we have folders
if [ ! -d $bundlepath ]; then
    mkdir -p $bundlepath
fi

# remove all current links, make sure we start from scratch
for bundle in $bundlepath/* ; do
    if [ -d $bundle -a -L $bundle ]; then
        # make sure it is a bundle inside vim-kicks-ass
        cd $bundle; realpath=`pwd -P`; cd $toolbox
        if [ $(echo | awk -v r=$realpath -v t=$toolbox '{print index(r, t)}') -eq 1 ]; then
            rm $bundle
        fi
    fi
done

# create new links for specified bundles
for bundle in $@; do
    path=$toolbox/$bundle
    name=`basename $path`

    if [ -d $path ]; then
        # always make sure submodule is updated and ready, ignore errors if not a submodule
        git submodule update --recursive --init $bundle 2> /dev/null

        # register bundle, now ready to be loaded by pathogen
        ln -s $path $bundlepath/$name
    fi
done

# make sure lib submodules is up-to-date
git submodule update --init $toolbox/lib/pathogen

# make sure we have pathogen installed
if [ ! -d $autoloadpath ]; then
    mkdir -p $autoloadpath
fi

if [ ! -e $autoloadpath/pathogen.vim ]; then
    ln -s $toolbox/lib/pathogen/autoload/pathogen.vim $autoloadpath/pathogen.vim
fi
