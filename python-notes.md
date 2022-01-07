# Notes for Python
各种记不住的命令 Python 部分

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