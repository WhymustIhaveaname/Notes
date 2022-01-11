### How to check current AMD Radeon driver version

* Commands from [4]

```
$ sudo lshw -c video
  *-display UNCLAIMED
       description: VGA compatible controller
       product: Advanced Micro Devices, Inc. [AMD/ATI]
       vendor: Advanced Micro Devices, Inc. [AMD/ATI]
       physical id: 0
       bus info: pci@0000:03:00.0
       version: c1
       width: 64 bits
       clock: 33MHz
       capabilities: pm pciexpress msi vga_controller bus_master cap_list
       configuration: latency=0
       resources: memory:d0000000-dfffffff memory:e0000000-e01fffff ioport:f000(size=256) memory:fcd00000-fcdfffff memory:fce00000-fce1ffff
$ lsmod | grep amd
edac_mce_amd           32768  0
gpio_amdpt             20480  0
gpio_generic           20480  1 gpio_amdpt
$ dmesg | grep -i amdgpu # no output
```

* Commands from [5]

```
$ lspci -nn | grep -E 'VGA|Display'
03:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Navi 22 [Radeon RX 6700/6700 XT / 6800M] [1002:73df] (rev c1)
0a:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Cezanne [1002:1638] (rev c8)
```

* Commands from stackoverflow

```
$ glxinfo -B
Error: unable to open display
```

### Youtube resources

[1] [AMD Radeon 6600XT: Linux Setup Made Easy! by Level1Linux](https://www.youtube.com/watch?v=VSXftsxBpi0)

    update Linux firmware using git

[2] [Installing AMD OpenCL ROCm driver Ubuntu 20.04 by Novaspirit Tech](https://www.youtube.com/watch?v=efKjfBkjPlM)

    install AMD OpenCL ROCm

[3] [Installing AMD Radeon GPU mesa drivers on Ubuntu by LinuxH2O](https://www.youtube.com/watch?v=MgfSXjnawYE)

    AMD's official driver is always unstable, so we need to install an opensorce one

    ```
        sudo add-apt-repository ppa:oibaf/graphics-drivers
        # and then apt update & apt upgrade
    ```

[4] [AMD Radeon Ubuntu 20.04 Driver Installation](https://linuxconfig.org/amd-radeon-ubuntu-20-04-driver-installation)

    * The Open Source AMD Radeon Ubuntu Driver is already installed on your system by default. They’re integrated into Mesa and the Linux kernel.
    (comment: the `mesa` is the same as [3]. However, my ubuntu 20.04 does not have it out of box.)
    * `sudo add-apt-repository ppa:oibaf/graphics-drivers` and then `sudo apt update && sudo apt -y upgrade` (also same as [3])

[5] [AMDGPU-Driver](https://help.ubuntu.com/community/AMDGPU-Driver)

[6] [Proprietary Drivers vs Open Source | nVidia vs AMD by Chris Titus Tech](https://www.youtube.com/watch?v=0tL4y5Gmol8)

    * do not install amd's gpupro (this is the same as [3])
    * https://github.com/lutris/docs/blob/master/InstallingDrivers.md
    ```
        sudo add-apt-repository ppa:kisak/kisak-mesa && sudo dpkg --add-architecture i386 && sudo apt update && sudo apt upgrade && sudo apt install libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386
    ```

[7] [OpenCL not working with RX 6700 XT](https://askubuntu.com/questions/1336913/opencl-not-working-with-rx-6700-xt)

    * one should use rocm (as recommanded by [2])