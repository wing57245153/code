#!/bin/sh
#####################
#			
#发布程序Shell脚本
#
#chmod +x release.sh
#将其设置成可执行文件
#./release.sh 执行该脚本
#该脚本设置4个参数
#1、newFolder 更新的文件所在的目录
#2、gameFolder 主域名所在的目录
#3、cdnFolder CDN所在的目录
#4、tempFolder 所要备份的目录
#可以灵活设置以上四个参数，主要的功能是将newFolder
#里面所有的文件复制到gameFolder和cdnFolder目录上面
#备份的文件 主要是将CND所在的目录下面的文件复制到tempFolder目录下面
#
#执行该shell脚本 
#选择1开始更新客户端
#选择2就结束该脚本
#
#关于参数的设置
#newFolder 一般默认为html，因为导出的客户端在html文件夹下面
#          只要将该Shell脚本与客户端文件html放在同一目录即可
#
#gameFolder 为主域名所在的目录 一般不需要更新 只是为了保险起见
#	    防止程序里面某些资源没有映射CDN目录下面
#	    也确保Loader2D.swf 与 Game.swf为最新文件
#	    S0服的路径为 /var/www/html
#	    版署2服的路径为 /var/www_sec/html
#
#cdnFolder  该目录为CDN配置所在的目录，程序的资源都存放在此，所以务必设置正确
#	    S0服的路径为 /user/cszd
#	    版署2服的路径为 /user/cszd
#
#tempFolder 所要备份的路径
###################
newFolder=html 
gameFolder=/var/www_sec/html 
cdnFolder=/user/cszd
tempFolder=backup
echo "are you sure you release the game?"
select var in "y" "n"; do
       break
done
if [ "$var" = "y" ];
then
	echo "starting release..."
	if [ -d "$tempFolder" ]
	then
		echo "the temp folder is exist..."
	else
		echo "creating temp folder..."
		mkdir $tempFolder
	fi
	echo "======================="
	echo "backup the game to temp folder..."
	cp -rf $cdnFolder/* $tempFolder/
	echo "back up game over..."
	echo "======================"
	echo "releasing game..."
	cp -rf $newFolder/* $gameFolder/
	cp -rf $newFolder/* $cdnFolder/
	echo "release ok."
	echo "======================"
else
	echo "you just Dsauce..."
fi
