#!/bin/sh
#####################
#			
#��������Shell�ű�
#
#chmod +x release.sh
#�������óɿ�ִ���ļ�
#./release.sh ִ�иýű�
#�ýű�����4������
#1��newFolder ���µ��ļ����ڵ�Ŀ¼
#2��gameFolder ���������ڵ�Ŀ¼
#3��cdnFolder CDN���ڵ�Ŀ¼
#4��tempFolder ��Ҫ���ݵ�Ŀ¼
#����������������ĸ���������Ҫ�Ĺ����ǽ�newFolder
#�������е��ļ����Ƶ�gameFolder��cdnFolderĿ¼����
#���ݵ��ļ� ��Ҫ�ǽ�CND���ڵ�Ŀ¼������ļ����Ƶ�tempFolderĿ¼����
#
#ִ�и�shell�ű� 
#ѡ��1��ʼ���¿ͻ���
#ѡ��2�ͽ����ýű�
#
#���ڲ���������
#newFolder һ��Ĭ��Ϊhtml����Ϊ�����Ŀͻ�����html�ļ�������
#          ֻҪ����Shell�ű���ͻ����ļ�html����ͬһĿ¼����
#
#gameFolder Ϊ���������ڵ�Ŀ¼ һ�㲻��Ҫ���� ֻ��Ϊ�˱������
#	    ��ֹ��������ĳЩ��Դû��ӳ��CDNĿ¼����
#	    Ҳȷ��Loader2D.swf �� Game.swfΪ�����ļ�
#	    S0����·��Ϊ /var/www/html
#	    ����2����·��Ϊ /var/www_sec/html
#
#cdnFolder  ��Ŀ¼ΪCDN�������ڵ�Ŀ¼���������Դ������ڴˣ��������������ȷ
#	    S0����·��Ϊ /user/cszd
#	    ����2����·��Ϊ /user/cszd
#
#tempFolder ��Ҫ���ݵ�·��
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
