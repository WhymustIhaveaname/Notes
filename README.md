# Notes
各种记不住的命令

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

## Multiprocessing Collecting Data

```
import torch,copy,pickle,tempfile,os
#from multiprocessing import Process,Queue
from torch.multiprocessing import Process,Queue
torch.multiprocessing.set_start_method('spawn')

def gen_data(paras):
    data=[(torch.rand(100,100),torch.rand(10)) for i in range(1000)]
    # save file to tmp
    fd,fname=tempfile.mkstemp(suffix='.mydata.tmp',prefix='',dir='/tmp')
    with open(fd,"wb") as f:
        pickle.dump(train_datas,f)
    data_q.put((fd,fname))
    
def daemon():
    data_q=Queue()
    plist=[]
    for i in range(4):
        plist.append(Process(target=gen_data,args=(paras)))
        plist[-1].start()
    rlist=[]
    for p in plist:
        p.join()
        fd,fname=data_q.get(False)
        with open(fname,"rb") as f:
            rlist+=pickle.load(f)
        os.unlink(fname) # delete the file
    return rlist
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
