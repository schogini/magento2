#!/bin/bash

# Copyright (c) 2015 Schogini Systems P Ltd http://schogini.biz

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# SCRIPT: Magento 2 Easy CLI Install Bash Script With Products



yn () {
    while true; do
        read -p "$1 [N]? " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            [\ ]* ) return 1;;
            [Xx]* ) exit 1;;
            #* ) echo "Please answer yes or no or X to exit. [N]";;
            * ) return 1;;
        esac
    done
}
if yn "Install(CLONE) M2 at magento2 at `pwd`"; then
	git clone https://github.com/magento/magento2.git
	cd magento2
	git checkout master
fi

[ `basename $(pwd)` != magento2 ] && cd magento2

replace '"minimum-stability": "alpha"' '"minimum-stability": "beta"' -- composer.json

if yn "Compose Self-Update"; then
    composer self-update
fi
if yn "Compose Update (Uses the JSON file, not the Lock file) at `pwd`"; then
    composer update
fi
if yn "Clear Cache and Set Permissions at `pwd`"; then
   sudo chmod -R 777 var pub app/etc
   sudo rm -fR var/cache/* var/page_cache/* 
fi
#drwxrwx---@ 18 daemon  staff  612 Nov 13 17:30 cache
#drwxrwxrwx@  4 sree    staff  136 Nov 13 17:25 composer_home
#drwxrwx---@  5 daemon  staff  170 Nov 13 17:25 generation
#drwxrwx---@  4 daemon  staff  136 Nov 13 17:24 log
#drwxrwx---@  3 daemon  staff  102 Nov 13 17:30 page_cache
#drwxrwx---@  2 daemon  staff   68 Nov 13 17:24 tmp
#drwxrwx---@  4 daemon  staff  136 Nov 13 17:20 view_preprocessed


d=`pwd`
db=`basename $(dirname $d)`

if yn "Drop and Create DB $db"; then
  echo "drop database $db"   |mysql -u root
  echo "create database $db" |mysql -u root
fi

if yn "Install Magento 2 at `pwd`"; then
  chmod 755 bin/magento
./bin/magento setup:install --base-url=http://127.0.0.1/$db/magento2/ \
--db-host=localhost --db-name=$db --db-user=root \
--admin-firstname=Sreeprakash --admin-lastname=Neelakantan --admin-email=sree@schogini.com \
--admin-user=admin --admin-password=admin123 --language=en_US \
--currency=USD --timezone=America/Chicago --use-rewrites=1 \

fi
if yn "AGAIN Clear Cache and Set Permissions at `pwd`"; then
   sudo rm -fR var/cache/* var/page_cache/* 
   sudo chmod -R 777 var pub app/etc
fi

if yn "Reindex"; then
  ./bin/magento indexer:reindex
fi

if yn "Flush Cache"; then
  ./bin/magento cache:flush   
   sudo rm -fR var/cache/* var/page_cache/* 
   sudo chmod -R 777 var pub app/etc
fi

if yn "Install Sample Data and do Upgrade and Compile"; then

	./bin/magento sampledata:deploy
        ./bin/magento setup:upgrade
        ./bin/magento -v setup:di:compile
fi

if yn "AGAIN Setup:Upgrade"; then
  ./bin/magento setup:upgrade
fi

if yn "AGAIN Setup:DI:Compile"; then
  ./bin/magento -v setup:di:compile
fi

if yn "Build Static Files"; then
  ./bin/magento setup:static-content:deploy
fi

if yn "AGAIN Reindex"; then
  ./bin/magento indexer:reindex
  ./bin/magento cache:flush   
  sudo rm -fR var/cache/* var/page_cache/* 
  sudo chmod -R 777 var pub app/etc
fi

if yn "Export DB $db"; then
  mysqldump -u root $db > ../$db.sql
fi
