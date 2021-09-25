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

def log(msg,l=1,end="\n",logfile=LOGFILE):
    st=traceback.extract_stack()[-2]
    lstr=LOGLEVEL[l]
    #now_str="%s %03d"%(time.strftime("%y/%m/%d %H:%M:%S",time.localtime()),math.modf(time.time())[0]*1000)
    now_str="%s"%(time.strftime("%y/%b %H:%M:%S",time.localtime()),)
    perfix="%s [%s,%s:%03d]"%(now_str,lstr,st.name,st.lineno)
    if l<3:
        tempstr="%s %s%s"%(perfix,str(msg),end)
    else:
        tempstr="%s %s:\n%s%s"%(perfix,str(msg),traceback.format_exc(limit=5),end)
    print(tempstr,end="")
    if l>=1:
        with open(logfile,"a") as f:
            f.write(tempstr)
```

想要颜色？

```
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

## matplotlib 画图

```
fig,axs=plt.subplots(2,2)
#fig,((ax1,ax2),(ax3,ax4))=plt.subplots(2,2)
axs[0, 0].plot(x, y)
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

要是想 `ls` 还可以`os.listdir(".")`


## Multiprocessing Collecting Data

```
# daemon 启动若干个 gen_data
# gen_data 生成训练数据把它们存在临时文件中（/tmp），之后把文件名通过一个 queue 返回
# Linux 的 /tmp 是挂载在内存上的，所以速度很快
# daemon 获得文件名后打开 /tmp 中的文件读出训练集然后删除文件（释放内存）

import torch,copy,pickle,tempfile,os,copy
from torch.multiprocessing import Process,Queue # from multiprocessing import Process,Queue
torch.multiprocessing.set_start_method('spawn') # 没这个 pytorch 多进程会报错，放在 daemon 的进程中即可，gen_data 的进程不用这句

def gen_data(model,data_q,gpu_num,data_num,other_paras):
    data=[(torch.rand(100,100),torch.rand(10)) for i in range(1000)]
    fd,fname=tempfile.mkstemp(suffix='.mydata.tmp',prefix='',dir='/tmp') # 后缀可以改，方便辨认
    with open(fd,"wb") as f:
        pickle.dump(data,f) # 把训练数据存在临时文件中
    data_q.put((fd,fname)) # 把文件名通过一个 queue 返回

def daemon(model):
    data_q=Queue() # 返回文件名的 queue
    plist=[]
    for i in range(4):
        plist.append(Process(target=gen_data,args=(copy.deepcopy(model),data_q,gpu_num,data_num,other_paras)))
        plist[-1].start()
    rlist=[]
    for p in plist:
        p.join() # 等待进程结束
        fd,fname=data_q.get(False) #读出进程放在 queue 中的文件名
        with open(fname,"rb") as f:
            rlist+=pickle.load(f)
        os.unlink(fname) # 删除文件（释放内存）
    return rlist
```

### 当显存不足时这个技巧可以挤出一个线程
```
def gen_data(model,gpu_num,data_num,other_paras):
    data=[(torch.rand(100,100),torch.rand(10)) for i in range(1000)]
    return data

def mob(model,data_q,gpu_num,data_num,other_paras)
    data=gen_data(model,gpu_num,data_num,other_paras)
    fd,fname=tempfile.mkstemp(suffix='.mydata.tmp',prefix='',dir='/tmp')
    with open(fd,"wb") as f:
        pickle.dump(data,f)
    data_q.put((fd,fname))

def daemon(model):
    data_q=Queue()
    plist=[]
    for i in range(4):
        plist.append(Process(target=mob,args=(copy.deepcopy(model),data_q,gpu_num,data_num,other_paras)))
        plist[-1].start()
    rlist=gen_data(model,gpu_num,data_num,other_paras) #本来当前线程的 model(用于梯度下降的 model)在生成数据时是闲着的，现在把它也用起来
    for p in plist:
        p.join()
        fd,fname=data_q.get(False)
        with open(fname,"rb") as f:
            rlist+=pickle.load(f)
        os.unlink(fname)
    return rlist
```

## ffmpeg 加字幕（软字幕）

```
# -c copy 表示音频视频和字幕编码都直接复制
# -metadata:s:s:0 language="English" 给字幕一个名字
# -metadata:s:s:0 表示第一个字幕

ffmpeg -i input.mp4 -i subtitles.srt -c copy -metadata:s:s:0 language="English" output.mkv
```

```
# -ss 和 -t 开始时间和时长
ffmpeg -i input.mkv -ss 00:00:07 -t 00:00:18 -c:v h264 output.mp4
```


## Logrotate

```
logrotate --help
    -d, --debug               Don't do anything, just test and print debug messages
    -f, --force               Force file rotation
    -v, --verbose             Display messages during rotation
```
先测试语法 `logrotate -dv /etc/logrotate.d/configfile`， 再手动执行 `logrotate -fv /etc/logrotate.d/configfile`


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

## 网不好导致 SSH 总断？

`sudo vi /etc/ssh/sshd_config`
    ```
    ClientAliveInterval 60
    ClientAliveCountMax 20
    ```
其含义是每 60s 服务器测试一下客户端有没有响应，连续 20 次没响应则关闭 session。这样网再差都不会断啦

## Ubuntu DNS

```
sudo systemctl stop systemd-resolved.service
sudo systemctl disable systemd-resolved.service
sudo systemctl mask systemd-resolved.service
sudo rm /etc/resolv.conf
sudo vi /etc/NetworkManager/NetworkManager.conf
(add in "[main]") dns=none #NetworkManager will not modify resolv.conf
sudo systemctl restart network-manager.service
```
See [NetworkManager.conf.(5)](https://manpages.debian.org/unstable/network-manager/NetworkManager.conf.5.en.html) for other configurations.

## Sublime

* add to `hosts`: `127.0.0.1 license.sublimehq.com`
* add to sublime settings: `"update_check": false`


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
