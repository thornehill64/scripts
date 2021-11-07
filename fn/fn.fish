#!/bin/fish

set dir
set quer

read -p "set_color red; echo -n 'DIRECTORY'; set_color yellow; echo -n '>> '; set_color normal;" dir
read -p "set_color red; echo -n 'QUERY'; set_color yellow; echo -n '>> '; set_color normal;" quer

if test -n dir;
	set dir $PWD
end

find $dir -iname $quer
