# Notes
各种记不住的命令

* git 快速上手：[git_tutorial.sh](https://github.com/WhymustIhaveaname/Notes/blob/main/git_tutorial.sh)
* Python 部分：[python-notes.md](https://github.com/WhymustIhaveaname/Notes/blob/main/python-notes.md)

## Bash 的括号

数字运算用双圆括号、double parentheses、Arithmetic Expansion：`(())`，其他用双方括号`[[]]`，单方括号是垃圾。

## 停止 Jupyter notebook 的自动补全

不是说自动补全不好，而是经常错，尤其是删除时会多删一个，连括号配对都分不清还是别自动补全了。

解决方法：在 notebook 中运行
```
from notebook.services.config import ConfigManager
c = ConfigManager()
c.update('notebook', {"CodeCell": {"cm_config": {"autoCloseBrackets": False}}})
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

## 系统监视命令

* 重复执行某一条指令（每 2s 执行一次、每 5s 执行一次）

    ```
    watch cmd
    watch -n 5 cmd
    ```

* cpu 温度和 gpu 温度，`sed -n '9,11p'` 是截取 9 至 11 行

    `watch "sensors coretemp-*; nvidia-smi -q -d TEMPERATURE | sed -n '9,11p'"`

* 树苺派是否低电压, more options at [raspberrypi documentation for vcgencmd](https://www.raspberrypi.com/documentation/computers/os.html#vcgencmd).

    `watch vcgencmd get_throttled`

* 实时网速

    `iftop`

## 两台 Linux 之间测网速

一边开启服务器
```
iperf -s
```
另一边连接
```
iperf -c ip
```
可选参数：`-p`指定端口，`-u`使用 UDP

## Logrotate

先测试语法 `logrotate -dv /etc/logrotate.d/configfile`， 再手动执行 `logrotate -fv /etc/logrotate.d/configfile`

```
logrotate --help
    -d, --debug               Don't do anything, just test and print debug messages
    -f, --force               Force file rotation
    -v, --verbose             Display messages during rotation
```

一些样例配置文件

```
$ cat /etc/logrotate.d/apt
/var/log/apt/term.log {
  rotate 12
  monthly
  compress
  missingok
  notifempty
}
$ cat /etc/logrotate.d/dpkg
/var/log/dpkg.log {
	monthly
	rotate 12
	compress
	delaycompress
	missingok
	notifempty
	create 644 root root
}
```

* compress: Old versions of log files are compressed with gzip(1) by default.
* nocompress: Old versions of log files are not compressed.
* delaycompress: Postpone compression of the previous log file to the next rotation cycle. This only has effect when used in combination with compress.
* missingok: If the log file is missing, go on to the next one without issuing an error message. See also nomissingok.
* nomissingok: If a log file does not exist, issue an error. This is the default.
* notifempty: Do not rotate the log if it is empty (this overrides the ifempty option).
* See https://linux.die.net/man/8/logrotate for more info.

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

`sudo vi /etc/ssh/sshd_config` 更改
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

## 启动至图形化界面 (graphical) 或者命令行 (multi-user)

```
sudo systemctl set-default graphical.target
sudo systemctl set-default multi-user.target
```

## do nothing when close the lid

```
vi /etc/systemd/logind.conf
modify: HandleLidSwitch=ignore
systemctl restart systemd-logind
```

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
