import os
import string
import time
import anydbm
import struct
import shutil
import zlib
import glob
import hashlib
import json
import sys

SOURCE_DIR = 'H:/project/kaifa/client/Arpg/bin'
DIF_DIR = 'dif' #dif path
VERSION_NAME = 'fileTime.swf'
GAMEDATA_DIR = 'H:/project/kaifa/resdb_snapshot/gamedata'
DABAO_PY = 'H:/project/kaifa/dabao.py'
ZSWF = 'zswf.exe'
MAIN_SWF = 'Arpg.swf'
MAIN11_SWF = 'Arpg_11.swf';
MAIN10_SWF = 'Arpg_10.swf';

GAMERES_COPY_LIST = ["gameres", "map"]
UNINCLUE_FOLDER = ".svn"

db = anydbm.open('data.dat', 'c')

def copyMain():
    shutil.copy(SOURCE_DIR + '/' + MAIN_SWF, SOURCE_DIR + '/' + MAIN11_SWF)
    shutil.copy(SOURCE_DIR + '/' + MAIN_SWF, SOURCE_DIR + '/' + MAIN10_SWF)

def makeVesion():
    #copyMain()
    for root, dirs, files in os.walk(SOURCE_DIR):
        for fileName in files:
            try:
                if string.index(root, UNINCLUE_FOLDER) >= 0:
                    break
            except Exception, e:
                pass
            from_dir = '/'.join(root.split('\\'))
            from_name = '/'.join(fileName.split('\\'))
            fullName = '%s/%s' % (from_dir, from_name)
            fileInfo = os.stat(fullName)
            key = string.replace(fullName, SOURCE_DIR + "/", "")
            times = time.localtime(fileInfo.st_mtime)
            version = str(times.tm_year) + str(times.tm_mon) + str(times.tm_mday) + str(times.tm_hour) + str(times.tm_min) + str(times.tm_sec)
            f = open(fullName)
            m5 = hashlib.md5()
            m5.update(f.read())
            m5hex = m5.hexdigest()
            obj = {"md5" : m5hex, "version" : version}
            #print obj
            try:
                if (json.loads(db[key]))["md5"] != m5hex:
                    #print key, (json.loads(db[key]))["md5"], m5hex
                    copy(SOURCE_DIR,DIF_DIR,key)
                    db[key] = json.dumps(obj)
                    print "dif..:" + key
            except Exception, e:
                copy(SOURCE_DIR,DIF_DIR,key)
                db[key] = json.dumps(obj)
            else:
                pass
            finally:
                pass

            #print key, version

def makeVersionFile():
    f = open(VERSION_NAME, 'wb')
    s = ""
    for key, value in db.iteritems():
        #writeUTF8(f, key)
        #writeUTF8(f, value)
        skey = getUTF8(key)
        svalue = getUTF8((json.loads(value))["version"])
        try:
             s = s + skey + svalue
        except Exception, e:
            print key + " name fail....."
       
        
    zs = zlib.compress(s)
    f.write(zs)
    f.close()
    shutil.copy(VERSION_NAME, SOURCE_DIR + "/" + VERSION_NAME)
    shutil.copy(VERSION_NAME, DIF_DIR + "/" + VERSION_NAME)

    #zswf(DIF_DIR + '/' + MAIN11_SWF)
    #zswf(DIF_DIR + '/' + MAIN_SWF)
    print "complete..."

def writeUTF8(f, s):
    f.write(struct.pack('>h',len(s)))
    f.write(s)

def getUTF8(s):
    return struct.pack('>h',len(s)) + s

def copy(src,det,key):
    des = det + "/" + key
    fpath, fname = os.path.split(des)
    if os.path.isdir(fpath) == False:
        os.makedirs(fpath)
    shutil.copy(src + "/" + key, des)
    #try:
    #    if string.index(key, 'swf') >= 0 :
    #        zswf(des)
    #except Exception, e:
    #    pass
    
    print "copying..." + des

def delDifFoler():
    try:
        os.system('rd /S /Q ' + DIF_DIR)
    except Exception, e:
        pass

def delete_file_folder(src):
    if os.path.isfile(src):
        try:
            os.remove(src)
        except:
            pass
    elif os.path.isdir(src):
        for item in os.listdir(src):
            itemsrc=os.path.join(src,item)
            delete_file_folder(itemsrc)
            try:
                os.rmdir(src)
            except:
                pass


def copyGameData():
    #for foler in GAMERES_COPY_LIST:
    #    shutil.copytree(GAMEDATA_DIR + "/" + foler, SOURCE_DIR + "/" + foler + "/temp")
    #    lists =  glob.glob(SOURCE_DIR + "/" + foler + "/temp/*")
    #    print lists
    #    for path in lists:
    #        print path
    #        shutil.move(path, SOURCE_DIR + "/" + foler + "/" + os.path.basename(path))
    #    shutil.rmtree(SOURCE_DIR + "/" + foler + "/temp")
    for root, dirs, files in os.walk(GAMEDATA_DIR):
        for fileName in files:
            try:
                if string.index(root, UNINCLUE_FOLDER) >= 0:
                    break
            except Exception, e:
                pass
            from_dir = '/'.join(root.split('\\'))
            from_name = '/'.join(fileName.split('\\'))
            fullName = '%s/%s' % (from_dir, from_name)
            key = string.replace(fullName, GAMEDATA_DIR + "/", "")
            copy(GAMEDATA_DIR,SOURCE_DIR, key)

def dabao():
    os.system('py %s ' % (DABAO_PY))

def zswf(filename):
    os.system('%s %s -f %s' % (ZSWF, filename, filename))


def build():
    delDifFoler()
    copyGameData()
    dabao() 
    makeVesion()
    makeVersionFile()
    db.close()

def release(): #not copy gameres data
    delDifFoler()
    #copyGameData()
    dabao() 
    makeVesion()
    makeVersionFile()
    db.close()

#def lookupVersion(key):
#    for dbkey, value in db.iteritems():
#        if(dbkey == key):


if __name__ == "__main__":
    if len(sys.argv) == 1:
        build()

    if len(sys.argv) == 2:
        if(sys.argv[1] == "release"):
            release()

    #if len(sys.argv) == 3:
    #    if(sys.argv[1] == "lookup"):


