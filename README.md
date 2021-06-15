# Notes
各种记不住的命令

## Python 开头写什么？

```
#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

import time,sys,traceback,math

LOGLEVEL={0:"DEBUG",1:"INFO",2:"WARN",3:"ERR",4:"FATAL"}
LOGFILE=sys.argv[0].split(".")
LOGFILE[-1]="log"
LOGFILE=".".join(LOGFILE)

def log(msg,l=1,end="\n",logfile=LOGFILE,color=None):
    """
        color: "1;33" "1;32"
    """
    st=traceback.extract_stack()[-2]
    lstr=LOGLEVEL[l]
    #now_str="%s %03d"%(time.strftime("%y/%m/%d %H:%M:%S",time.localtime()),math.modf(time.time())[0]*1000)
    now_str="%s"%(time.strftime("%y/%b %H:%M:%S",time.localtime()),)
    perfix="%s [%s,%s:%03d]"%(now_str,lstr,st.name,st.lineno)
    if color:
        color="\x1b[%sm"%(color)
        color_rst="\x1b[m"
    else:
        color=""
        color_rst=""
    if l<3:
        tempstr="%s %s%s%s%s"%(perfix,color,str(msg),end,color_rst)
    else:
        tempstr="%s %s:\n%s%s"%(perfix,str(msg),traceback.format_exc(limit=5),end)
    print(tempstr,end="")
    if l>=1:
        with open(logfile,"a") as f:
            f.write(tempstr)
```

## Python 执行 shell/bash 命令

只执行不要返回值
```
os.system('ls -l')
```
获得输出
```
stream=os.popen('echo Returned output')
output=stream.read()
print(output)
>>> 'Returned output\n'
```

要是想 `ls` 还可以

```
os.listdir(".")
```

## ffmpeg

加字幕（软字幕）

```
# -c copy 表示音频视频和字幕编码都直接复制
# -metadata:s:s:0 language="English" 给字幕一个名字
# -metadata:s:s:0 表示第一个字幕
ffmpeg -i input.mp4 -i subtitles.srt -c copy -metadata:s:s:0 language="English" output.mkv
```

## Links

注意下面这个命令中的"要建立的快捷方式"是不需要提前建立的，`ln`会帮你创建

```ln -s 已经存在的文件 要建立的快捷方式```

rm听起来就好危险，要是不小心把真正存在的数据也删了呢？

```unlink 快捷方式```

samba 允许链接 [Accessing symbolic links through Samba](https://access.redhat.com/solutions/54407)

```
[global]
follow symlinks = yes
unix extensions = no
wide links = yes
```

## 查看电池状态
Dump all parameters for all objects

```upower -d```

Show information about object path

```upower -i /org/freedesktop/UPower/devices/battery_BAT0```

## Vim 配置

Edit `vim /etc/vim/vimrc` (or `vim ~/.vimrc`) to config vim.

### tab 自动换为空格
```
set ts=4
set softtabstop=2    "按退格键的时候退回缩进的长度
set expandtab
set autoindent
```
尼玛我明明换了，结果别的文件行，碰上 .py 结尾的就给我抽风，草你妈老子用 nano，nano 就没这些破事，浪费我半小时。

续: nano 真好用，不但不会自动缩进，而且还能高亮显示结尾的空格。一个好的程序应该尽可能好的完成自己的本职工作，别的都不要管。你觉得为用户着想，其实往往是帮倒忙。就好像 vim 搞一堆蛋疼的设置但我根本不想要，想改又改不彻底，这不成 windows 了吗？
