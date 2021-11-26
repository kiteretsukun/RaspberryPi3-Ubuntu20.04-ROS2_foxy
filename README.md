# Raspimouse : RapsberryPi3 + Ubuntu 20.04 + ROS2 foxy
これはRaspimouseをRapsberryPi3 + Ubuntu 20.04 + ROS2 foxyで動かすための手順です。<br>
基本的にはRT-Shopさんの下記参考URLの1番と2番の手順をなぞれば良いのですが、ROS2のサンプルであるraspimouse2のソースをRapsberryPi3でビルドするとRaspimouseパッケージが25%で止まってしまう現象があります。<br>
この現象を回避する方法をtshellさんが記載してくれているのですが、ここではその手順を参考にしつつWindows10のDockerを使ってインストールする手順を記載します。<br>
初心者にもわかるようにUbuntu20.04のインストール方法から順番に記載します。ただし、Linuxに由来するコマンドや知識はご自身で補完してください。

![IMG_0723](https://user-images.githubusercontent.com/34445043/117532437-7ef08280-b022-11eb-8467-5362277e8733.jpg)

## 参考URL
1. Inastall Ubuntu 20.04 and ROS2 for RasberryPi3 : https://www.rt-shop.jp/blog/archives/11061
2. Build the device driver and raspimouse2.git : https://www.rt-shop.jp/blog/archives/11249
3. tshell's blog(build raspimouse2) : https://tshell.hatenablog.com/entry/2021/03/08/222557
4. tshell's blog(install ROS2) : https://tshell.hatenablog.com/entry/2021/03/07/224537

## raspimouse2のビルドが面倒だという方へ
このGitページに保管している rsp.tar がビルド済みのraspimouse2になります。<br>
こちらを展開すればすぐに使えます。（Linux初心者のため環境が変わると使えるかわかりません。）下記Requirementsと同じ仕様ならOKだと思います。<br>

rsp.tarの中身はフォルダで構成されていて、<br><br>
```
rsp.tar
 ├ build
 ├ install
 ├ log
 └ src
```
になっています。<br><br>

これらのフォルダの配置は
```
/
 └home
  └ubuntu
   └ros2_ws
     ├ build
     ├ install
     ├ log
     └ src
```
となるようにします。<br><br>

そのため、rsp.tarを/home/ubutu/ros2_wsに置いて、
```
$ cd /home/ubuntu/ros2_ws
$ tar xvf rsp.tar
```
とやれば、上記フォルダ配置になります。<br><br>
あとはROS2とraspimouse2を使うだけになります。<br>
詳しくはこの記事を読んでください。

# Requirements
* Raspberry Pi Mouse(Raspimouse)
  - https://rt-net.jp/products/raspberrypimousev3/
  - RT Robot Shop
  - 私はRaspimouse V2 を使いました。
* RaspberryPi
  - Raspiemouseのバージョンに合わせて、準備してください。V2の場合はRaspberryPi3、V3の場合はRaspberryPi4。
  - microSD : 16GB 以上が良いと思います。
  - 最後に無線LAN設定しますが、最初は有線LANで接続しておくと無難です。あと、キーボードとHNMIでモニタに接続しておいてください。
* Linux for RaspberryPi3
  - ubuntu-20.04.2-preinstalled-server-arm64+raspi.img.xz
  - https://ubuntu.com/download/raspberry-pi
* Device Driver
  - https://github.com/rt-net/RaspberryPiMouse
* ROS2
  - https://docs.ros.org/en/foxy/Installation/Ubuntu-Install-Debians.html
* Windows10 
  - version : 20H2
  - WSL2 : Ubuntu 20.04
  - Docker Desktop
  - Visual Studio Code(Docker extentionをインストールしておくこと。Powershellがターミナルとして立ち上げられるように準備すること。)
  - Powershell
  - Etcher(https://www.balena.io/etcher/) : microSDにUbuntuイメージを書き込むソフト
  - WinSCP(FTPツール) : https://ja.osdn.net/projects/winscp/
  - Win32 Disk Imager : https://sourceforge.net/projects/win32diskimager/

# RapsberryPi3 に Ubuntu 20.04 をインストールする
Ubuntu.comからRaspberryPiのArm64bitに対応したイメージがダウンロードできるので、ダウンロードしてください。<br>
2021.05.08時点ではUbuntu Server 20.04.2 LTSが選べました。LTSというタイプを選ぶのが良いそうです。このあたりはLinux系の詳しい情報を調べてください。<br>
ダウンロードしたイメージをEtcherというソフトを使ってイメージを書き込みます。<br>
書き込みが終わったら、microSDカードをRaspberryPiに差し込んで起動させます。
  - 立ち上げる前にUSBキーボード、有線LAN、モニター(HDMI)を接続しておいてください。立ち上げて、後から接続しても検知されないので、その場合は電源を無理やり切りましょう。本当は良くないのですが、大丈夫です。
  - RaspberryPi本体は、まだRaspimouseに搭載しなくても良いですが、デバイスドライバーをビルドする時点では搭載した方が良いです。
 
ubuntu server の場合、最初はlogin idもパスワードも「ubuntu」なので、それでログインしてください。<br>
ログインするとこんな感じになります。
```
ubuntu@ubuntu:`$ 
```
以降、コマンドを入力する部分を
```
$ 
```
と記載します。

パスワードはこのままではまずいので、変更します。パスワードはご自身で決めてください。
```
$ passwd
Changing password for pi.
Current password: 
New password: 
Retype new password: 
passwd: password updated successfully
```

# Windows10からRasberryPiのUbuntuへSSH接続するための準備
SSH接続は、暗号化された状態でサーバー間やPC間を通信する方式です。<br>
Ubuntuが立ち上がったRaspberryPiで作業します。<br>
まず、ネットワークアダプタがどのように認識されているか調べます。
```
$ ifconfig -a
eth0: flags=...
      .........
lo: flags=...
      .........
wlan0: flags=...
      .........
```
私のRaspberryPiでは有線LANアダプタがeth0、無線LANアダプタがwlan0でした。これは皆さんも同じのはず、です。<br>
有線LANのネットワークアダプタが分かったので、RaspberryPiの有線LANのIPアドレスを調べます。IPアドレスはサンプルです。
```
$ ip addr show eth0
3: eth0: ...
   inet 192.168.1.2/24 ...
```
次にSSHの準備です。IPアドレスはご自身のアドレスに読み替えてください。
```
$ ssh ubuntu@192.168.1.2
(略)
Are you sure you want to conotinue connecting (yes/no)?
```
となるので、
```
Are you sure you want to conotinue connecting (yes/no)? yes
```
として、Enterを押してください。<br>
これでWindows10からSSH接続できます。<br><br>

Windows10からはPowershellでアクセスします。Usernameの部分はご自身の環境に読み替えてください。(\は￥(←全角で書いてます)のことです。)
```
PS C:\Users\Username>
```
SSH接続するには
```
PS C:\Users\Username> ssh ubuntu@192.168.1.2
ubuntu@192.168.1.2's password: yourpassword
(略)
ubuntu@ubuntu:~$
```
でアクセスできます。

# RaspberryPi Ubuntuのソフトアップデート
おまじないのように下記を実行してください。
```
$ sudo apt update
$ sudo apt upgrade
```
sudo は管理者権限で実行するためのコマンドです。パスワードを聞かれたらログインした際のubuntuユーザーのパスワードを記入すればOKです。

# デバイスドライバーのインストール(RapsberryPi3 Ubuntu20.04)
Ubuntuが立ち上がったRaspberryPiで作業します。<br>
デバイスドライバのソースファイルをGitHubからクローンして、クローン時にできたディレクトリを移動します。
```
$ cd /home/ubuntu
$ git clone https://github.com/rt-net/RaspberryPiMouse.git
$ cd RaspberryPiMouse/utils
$ sudo apt install linux-headers-$(uname -r) build-essential
$ ./build_install.bash
```
このビルドが上手くいくとピッという音が鳴り、光センサが一度光ると思います。これでビルド(インストール)成功です。<br>
ビルドしたものの場所はこちらです。
```
$ cd /home/ubuntu/RaspberryPiMouse/src/drivers
$ ls -l
lrwxrwxrwx 1 ubuntu ubuntu    17 Apr 30 14:10 Makefile -> Makefile.ubuntu14
-rw-rw-r-- 1 ubuntu ubuntu   268 Apr 30 11:28 Makefile.raspbian
-rw-rw-r-- 1 ubuntu ubuntu   477 Apr 30 11:28 Makefile.ubuntu14
-rw-rw-r-- 1 ubuntu ubuntu     0 Apr 30 14:11 Module.symvers
-rw-rw-r-- 1 ubuntu ubuntu    53 Apr 30 14:11 modules.order
-rw-rw-r-- 1 ubuntu ubuntu 61288 Apr 30 11:28 rtmouse.c
-rw-rw-r-- 1 ubuntu ubuntu 55752 Apr 30 14:11 rtmouse.ko
-rw-rw-r-- 1 ubuntu ubuntu    53 Apr 30 14:11 rtmouse.mod
-rw-rw-r-- 1 ubuntu ubuntu  2819 Apr 30 14:11 rtmouse.mod.c
-rw-rw-r-- 1 ubuntu ubuntu  7008 Apr 30 14:11 rtmouse.mod.o
-rw-rw-r-- 1 ubuntu ubuntu 51136 Apr 30 14:11 rtmouse.o
```
この中のrtmouse.koがカーネルモジュールと呼ばれるもので、ビルドしてできたデバイスドライバーになります。カーネルはLinux用語なので調べてみてください。<br><br>

ビルドした直後はrtmouse.koが実行されており、
```
$ ls -l /dev/rt*
crw-rw-rw- 1 root root 510, 0 May  8 10:30 /dev/rtbuzzer0
crw-rw-rw- 1 root root 511, 0 May  8 10:30 /dev/rtled0
crw-rw-rw- 1 root root 511, 1 May  8 10:30 /dev/rtled1
crw-rw-rw- 1 root root 511, 2 May  8 10:30 /dev/rtled2
crw-rw-rw- 1 root root 511, 3 May  8 10:30 /dev/rtled3
crw-rw-rw- 1 root root 508, 0 May  8 10:30 /dev/rtlightsensor0
crw-rw-rw- 1 root root 504, 0 May  8 10:30 /dev/rtmotor0
crw-rw-rw- 1 root root 506, 0 May  8 10:30 /dev/rtmotor_raw_l0
crw-rw-rw- 1 root root 507, 0 May  8 10:30 /dev/rtmotor_raw_r0
crw-rw-rw- 1 root root 505, 0 May  8 10:30 /dev/rtmotoren0
crw-rw-rw- 1 root root 509, 0 May  8 10:30 /dev/rtswitch0
crw-rw-rw- 1 root root 509, 1 May  8 10:30 /dev/rtswitch1
crw-rw-rw- 1 root root 509, 2 May  8 10:30 /dev/rtswitch2
```
のように表示されます。このrtxxxというファイルがデバイスファイルと呼ばれ、Raspimouseはデバイスファイルを通じて操作することができます。詳しくは上田隆一先生の著書「RaspberryPiで学ぶ　ROSロボット入門」をご覧ください。デバイスファイルの直接的な動かし方などが解説されています。ROSであろうがROS2であろうが、デバイスファイルの使い方は同じです。<br><br>

RasberryPiを再起動させると、自動ではデバイスドライバーが読み込まれないので、細工します。setup.bashというシェルスクリプトを準備して、cronを使って起動時にシェルスクリプトを読みこむことでデバイスドライバが起動時に読み込まれるようします。(cd は cd /home/ubuntu と同じ意味で、ホームディレクトリに移動します。)
```
$ cd
$ mkdir pimouse_setup
$ cd pimouse_setup
```
setup.bashを作ります。viというエディタを使うのが一般的だと思いますが、癖があって慣れが必要です。使い方は調べてください。
```
$ sudo vi setup.bash
```
中身は以下のように記載してください。
```
#!/bin/bash -xve

exec 2> /tmp/setup.log

cd /home/ubuntu/RaspberryPiMouse/src/drivers/
/sbin/insmod rtmouse.ko

sleep 1
chmod 666 /dev/rt*

echo 0 > /dev/rtmotoren0
```
exec 2> /tmp/setup.log は /tmp にログを出すためのコマンドです。<br>
/sbin/insmod rtmouse.ko　は、rtmouse.ko を実行してカーネルにデバイスファイルをねじ込むコマンドです。<br>
デバイスドライバがすぐに出来ないのでsleep 1で1秒待ちます。<br>
chmod 666 /dev/rt* はroot以外の権限(今はubuntuユーザーです)でもデバイスファイルが使えるように権限を変更します。
echo 0 > /dev/rtmotoren0 は安全のためモーターの電源を切るコマンドを送っています。<br><br>
setup.bash に実行権をつけておきます。
```
sudo chmod 755 setup.bash
```
記載した中身の確認は
```
$ cat setup.bash
```
で中身を見ることができます。<br><br>

次にcron設定です。
```
$ sudo vi crontab.conf
```
中身は以下のように記載してください。
```
@reboot /home/ubuntu/pimouse_setup/setup.bash
```
crontabにセットします。
```
$ sudo crontab crontab.conf
```
これで以下のようなファイル構成になります。
```
/
 └home
  └ubuntu
   ├RaspberryPiMouse
   │ ├src
   │ ├utils
   │ ├ ・・・
   └pimouse_setup
     ├setup.bash
     └crontab.conf
```
これで、再起動すると自動でデバイスドライバが読み込まれ、ピッという音が鳴り、光センサが一度光ります。その後ログインできるようになります。<br><br>

※たまにrtmouse.koに実行権がない場合があるようなので、その場合は以下を実施してください。
```
$ cd
$ sudo chmod 755 /home/ubuntu/RaspberryPiMouse/src/drivers/rtmouse.ko
```

# ROS2 foxyのインストール(RapsberryPi3 Ubuntu20.04)
ROS公式HPに記載があります。<br>
URL : https://docs.ros.org/en/foxy/Installation/Ubuntu-Install-Debians.html<br>
ROS2のパッケージはDesktopとBaseを選べます。ここではbaseを選びます。上記URLに「Try some examples」という項目があるのですが、これをやるにはDesktopを選ばないとできません。<br>
実行は以下のコマンドになります。
```
$ sudo apt update && sudo apt install curl gnupg2 lsb-release
$ curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
$ sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

$ sudo apt update
$ sudo apt install ros-foxy-ros-base

$ sudo apt install python3-colcon-common-extensions
$ sudo apt install -y python3-pip
$ pip3 install -U argcomplete
```
ROS2がインストールされたか反応を見るにはヘルプを呼び出します。ヘルプが表示されればインストールされています（と思います）。1行目はROS2を動かすために必要なコマンドです。
```
$ source /opt/ros/foxy/setup.bash
$ ros2 --help
usage: ros2 [-h] Call `ros2 <command> -h` for more detailed usage. ...

ros2 is an extensible command-line tool for ROS 2.

optional arguments:
  -h, --help            show this help message and exit

Commands:
  action     Various action related sub-commands
  bag        Various rosbag related sub-commands
  component  Various component related sub-commands
  daemon     Various daemon related sub-commands
  doctor     Check ROS setup and other potential issues
  interface  Show information about ROS interfaces
  launch     Run a launch file
  lifecycle  Various lifecycle related sub-commands
  multicast  Various multicast related sub-commands
  node       Various node related sub-commands
  param      Various param related sub-commands
  pkg        Various package related sub-commands
  run        Run a package specific executable
  security   Various security related sub-commands
  service    Various service related sub-commands
  topic      Various topic related sub-commands
  wtf        Use `wtf` as alias to `doctor`

  Call `ros2 <command> -h` for more detailed usage.
```

Raspimouseを再起動するとROS2のリンクが動かずコマンドが効かないので、ホームディレクトリにある.bashrcの最後に以下を書き込んでおく。
```
ubuntu@ubuntu:~$ ls -al
ubuntu@ubuntu:~$ sudo vi .bashrc

source /opt/ros/foxy/setup.bash
```

# RaspimouseをROS2で動かすためにraspimouse2パッケージをビルドする
RaspimouseをROS2で動かすためにGeoffrey Biggsさんが作っているraspimouse2というパッケージがあります。まずはそれを利用させてもらうべく、ビルドを試みます。rt-shopさんのHPに記載された手順でビルドを行うと、2つあるパッケージのうちraspimouseのビルドが25%から進みません。これを回避するためにtshellさんがx86マシンでビルドする方法を記載してくれています。ここではWindow10でビルドできるようにかなり具体的に記載します。<br>

raspimouse2のビルドの仕方は、以下の通り。
1. RaspberryPi用のUbuntuのARMイメージファイルをx86でも動くように、qemu-user-staticというモジュールを利用して、ARM用のバイナリをx86命令へ変換しながら実行する仕掛けをする。
2. x86で動くARM用イメージファイルをWindows10のDockerへインポートして、ARM用UbuntuをWindows10のDockerでコンテナとして立ち上げる。
3. そのコンテナを使ってWSL2上に展開したraspimouse2のソースを含むフォルダをホームディレクトリとしてマウントした状態で別のコンテナを立ち上げる。追加で立ち上げたコンテナはROS2がインストールされている状態かつUbuntuであるようにDockerfileを作る。
4. 追加で立ち上げたコンテナでraspimouse2をビルドする。
5. ビルドされたものをRaspimouseへ移植する。

![ビルドイメージ](https://user-images.githubusercontent.com/34445043/117824271-4f9f7700-b2a9-11eb-82f2-25bb4cafc863.JPG)

## WSL2 ubuntu:20.04
RaspberryPiで動かすUbuntuのイメージファイル(ubuntu-20.04.2-preinstalled-server-arm64+raspi.img.xzを展開して.imgにしておいてください。)は、Windows10のダウンロードフォルダにあるものとします。<br>
imgファイルの保管先 : C:/Users/username/Downloads<br>
そのうえで、WSL2のUbuntu 20.04を立ち上げて以下を実行します。
```
$ cd
$ sudo losetup -fP /mnt/c/Users/Username/Downloads/ubuntu-20.04.2-preinstalled-server-arm64+raspi.img
$ mesg | grep loop
    0.206070] Calibrating delay loop (skipped), value calculated using timer frequency.. 6815.99 BogoMIPS (lpj=34079990)
[    0.361366] loop: module loaded
[  132.096953]  loop0: p1 p2
```
mesg | grep loop　でループバックデバイスがどこに作られたかわかります。私の環境では/dev/loop0でした。<br>
```
$ sudo fdisk -l /dev/loop0
Disk /dev/loop0: 3.4 GiB, 3259499520 bytes, 6366210 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x4ec8ea53

Device       Boot  Start     End Sectors  Size Id Type
/dev/loop0p1 *      2048  526335  524288  256M  c W95 FAT32 (LBA)
/dev/loop0p2      526336 6366175 5839840  2.8G 83 Linux
```
sudo fdisk -l /dev/loop0を行うことで、Linuxパーティションが/dev/loop0p2ということがわかります。この情報を次で使います。
```
$ sudo mount /dev/loop0p2 /mnt
```
後で/dev/loop0p2へqemu-user-staticというモジュールの一部をコピーするために、先にWSL2から/dev/loop0p2をマウントしておきます。<br>
ちなみに、マウントした先を覗いてみると...
```
$ ls /mnt
bin  boot  dev  etc  home  lib  lost+found  media  mnt  opt  proc  root  run  sbin  snap  srv  sys  tmp  usr  var
```
Ubuntuのイメージファイルの中身が見えています。イメージファイルをマウントしたので、このようになります。

## VSC (Visual Studio Code)＋Docker
次はARM64用のUbuntuイメージをx86でも動くようにする改造をします。TerminalとしてPowershellが動かせるように準備してください。WSL2でやっても良いのですが、この作業は一度行うだけなのでWSL2を汚すよりは、Dockerで作業してコンテナを捨てしまう方が、すっきりと作業が出来ます。なので、Dockerコンテナを立ち上げていきます。<br>
前提条件としては、Windows10のダウンロードフォルダにUbuntuイメージが展開されている状態です。@以下の数字はそれぞれ異なります。「$」が「root@a67cf51b1d6d:/#」に切り替わっていますが、これはDockerコンテナのコンソールを呼び出している状態を示しています。
```
$ docker run -it -v C:/Users/Username/Downloads:/img --name ubuntu ubuntu:20.04
root@a67cf51b1d6d:/# 
```
ここでDockerコンテナ側のコンソールに切り替わります。
```
root@a67cf51b1d6d:/# apt update
root@a67cf51b1d6d:/# apt install -y qemu-user-static
root@a67cf51b1d6d:/# ls /usr/bin/qe*
/usr/bin/qemu-aarch64-static       /usr/bin/qemu-or1k-static
/usr/bin/qemu-aarch64_be-static    /usr/bin/qemu-ppc-static 
/usr/bin/qemu-alpha-static         /usr/bin/qemu-ppc64-static
/usr/bin/qemu-arm-static           /usr/bin/qemu-ppc64abi32-static
/usr/bin/qemu-armeb-static         /usr/bin/qemu-ppc64le-static
/usr/bin/qemu-cris-static          /usr/bin/qemu-riscv32-static
/usr/bin/qemu-hppa-static          /usr/bin/qemu-riscv64-static
/usr/bin/qemu-i386-static          /usr/bin/qemu-s390x-static
/usr/bin/qemu-m68k-static          /usr/bin/qemu-sh4-static
/usr/bin/qemu-microblaze-static    /usr/bin/qemu-sh4eb-static
/usr/bin/qemu-microblazeel-static  /usr/bin/qemu-sparc-static
/usr/bin/qemu-mips-static          /usr/bin/qemu-sparc32plus-static
/usr/bin/qemu-mips64-static        /usr/bin/qemu-sparc64-static
/usr/bin/qemu-mips64el-static      /usr/bin/qemu-tilegx-static
/usr/bin/qemu-mipsel-static        /usr/bin/qemu-x86_64-static
/usr/bin/qemu-mipsn32-static       /usr/bin/qemu-xtensa-static
/usr/bin/qemu-mipsn32el-static     /usr/bin/qemu-xtensaeb-static
/usr/bin/qemu-nios2-static
```
インストールしたqemu-user-staticの中身が見えています。この中のqemu-arm-staticを引き抜いて、使っていくことになります。
ここで一旦Dockerコンテナ側のコンソールから抜けます。こんなイメージです。
```
root@a67cf51b1d6d:/#  exit
C:\Windows>
```
このままVSC上で作業を続けます。
```
$ docker ps -al
CONTAINER ID   IMAGE          COMMAND       CREATED          STATUS              PORTS     NAMES
a67cf51b1d6d   ubuntu:20.04   "/bin/bash"   18 minutes ago   Up About a minute             ubuntu
```
ここでコンテナのIDがわかるので（IDは適宜変更してください。）
```
docker cp a67cf51b1d6d:/usr/bin/qemu-arm-static C:\Users\Username\Downloads\qemu-arm-static
```
これでWindows10の C:/Users/username/Downloadsにqemu-arm-staticがコピーされています。
コピーが終わったら、今利用したDockerコンテナは削除してOKです。

## Windows10
C:\Users\Username\Downloads\qemu-arm-static を \\wsl$\Ubuntu-20.04\home\Username へコピーしてください。

## WSL2 ubuntu:20.04
ここではqemu-arm-staticをWSL2上でマウントしてあるUbuntuイメージへコピーして、tarファイルにまとめてイメージを保存します。<br><br>

まず、ホームディレクトリへ移動して確認します。その後、qemu-arm-staticをWSL2上でマウントしてあるUbuntuイメージへコピーします。さらにqemu-arm-staticを実行ファイルに変更します(chmod)。
```
$ cd
$ pwd
$ /home/Username
$ ls
qemu-arm-static
$ sudo cp qemu-arm-static /mnt/usr/bin
$ ls -l /mnt/usr/bin/qemu-arm-static
$ sudo chmod 755 /mnt/usr/bin/qemu-arm-static
```
qemu-arm-staticがコピーしてあるUbuntuイメージを、tarファイルにまとめてイメージを保存します。オーナーも変更します。
```
$ cd /mnt
$ sudo /home/raspi-ubuntu-20.04.tar .
$ sudo chown Username:Username raspi-ubuntu-20.04.tar
```
Username の部分はご自身のID(WSL2:Windows10)です。tarファイルの名前は自由につけて構いませんが、後続の作業で同じ名称を使う必要があります。。<br>
このイメージ(raspi-ubuntu-20.04-x86.tar)がArm64用Ubuntuをx86で動かせるように改造したイメージファイルになります。

## VSC
raspi-ubuntu-20.04-x86.tarをWindows10のDockerで動かす準備をします。<br>
VSC側で\\wsl$\Ubuntu-20.04\homeを選んでオープンして、Powershellを準備します。ホームディレクトリにいることを確認して続けます。
```
$ pwd
Path
----
Microsoft.PowerShell.Core\FileSystem::\\wsl$\Ubuntu-20.04\home\Username
$ docker import raspi-ubuntu-20.04.tar raspi-ubuntu:20.04
```
ARM64用Ubuntu を立ち上げ、さらに x86 Docker で動いているか確認します。@以降の数字はランダムに変わります。
```
$ docker run -it --name raspi-ubuntu raspi-ubuntu:20.04 /bin/bash
root@68eea23010f6:/# arch
aarch64
```
aarch64と表示されればアーキテクチャはARM64になっており，ARM用のUbuntu 20.04イメージが実行されています。
もし standard_init_linux.go:211: exec user process caused "exec format error" というエラーが出たら、下記を実行とのことです。私は出ませんでした。
```
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```
立ち上げたDockerコンテナは引き続き使用するのでこのままにします。

## WSL2 ubuntu:20.04
次の作業に向けて作業フォルダを準備します。作業フォルダは自由につけてください。
```
$ cd
$ mkdir docker-raspi
$ cd docker-raspi
$ pwd
/home/Username/docker-raspi
```
このフォルダはWindows10から見ると、\\wsl$\Ubuntu-20.04\home\Username/docker-raspi として見えます。


## VSC
先に立ち上げてあるARM64タイプのUbuntuコンテナを使い、WSL2側のフォルダをマウントしつつ、ROS2がインストールされた、もう一つのDockerコンテナを立ち上げます。この発想は素晴らしいです。<br>
ここではどこでファイルを作るかをイメージできるようにviで作っていますが、Windows10のテキストエディタで作ってFTPで送っても良いです。
```
$ pwd
/home/Username/docker-raspi
$ sudo vi Dockerfile

 FROM raspi-ubuntu:20.04
	
	RUN apt update && apt install -y curl gnupg2 lsb-release
	RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
	RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'
	
	RUN apt update && \
		apt install -y ros-foxy-ros-base  python3-colcon-common-extensions python3-pip && \
		pip3 install -U argcomplete
```
準備したDockerfileを使ってイメージのビルドをします。
```
$ docker build --rm -t raspi-ubuntu-ros2:foxy .
```
最後の行のピリオドが必要なので気を付けてください。<br><br>

ビルドしたイメージを使ってコンテナ化して立ち上げてみます。@以降の数字はランダムに変わります。
```
$ docker run --rm -it raspi-ubuntu-ros2:foxy /bin/bash
root@68eea23010f6:/#
```
rt-shopさんの記事にdemo_nodes_cppというサンプルパッケージでのテストが記載されているのですが、これは上記Dockerfileで「ros-foxy-ros-base」ではなくて「ros-foxy-ros-desktop」をインストールするように指示しないと使えないので注意してください。desktopを入れると余計に時間がかかるので、余裕があればチャレンジしていただいても良いかと思います。<br><br>
rt-shopさんの記事 : https://rt-net.jp/mobility/archives/13190<br><br>
ROS2がインストールされたか反応を見るには先ほどと同じくヘルプを呼び出すと当たりがつくと思います。。ヘルプが表示されればインストールされています（と思います）。
```
root@68eea23010f6:/# source /opt/ros/foxy/setup.bash
root@68eea23010f6:/# ros2 --help
usage: ros2 [-h] Call `ros2 <command> -h` for more detailed usage. ...
```
一度コンテナから出ます。
```
root@68eea23010f6:/# exit
```
## WSL2 ubuntu:20.04
raspimouse2のビルドに向けて、ここのコンテナの起動方法がトリッキーです。\wsl$\Ubuntu-20.04\home\Username\docker-raspi\ros2_wsフォルダをコンテナの/homeにマウントさせてコンテナを起動します。そのため、WSL2側で準備します。
```
$ cd
$ cd docker-raspi
$ mkdir -p ros2_ws/src
$ cd ros2_ws/src
$ git clone https://github.com/rt-net/raspimouse2.git
```
## VSC
トリッキーなコンテナを起動し、raspimouse2をビルドします。
```
$ docker run --rm -it -v /home/Username/docker-raspi/ros2_ws:/home/ros2_ws raspi-ubuntu-ros2:foxy /bin/bash
$ source /opt/ros/foxy/setup.bash
$ cd /home/ros2_ws
$ colcon build
Starting >>> raspimouse_msgs
[Processing: raspimouse_msgs]                             
[Processing: raspimouse_msgs]                                      
Finished <<< raspimouse_msgs [1min 8s]                             
Starting >>> raspimouse
[Processing: raspimouse]                                  
[Processing: raspimouse]                                     
[Processing: raspimouse]                                       
Finished <<< raspimouse [1min 55s]                             
                          
Summary: 2 packages finished [3min 4s]
```
RaspberryPiではビルド出来なかったraspimouse2がビルド出来ました！ビルドしたファイルは「\wsl$\Ubuntu-20.04\home\Username\docker-raspi\ros2_ws」フォルダに出来ています。それはトリッキーなコンテナの立ち上げ方にあります。コンテナを立ち上げる際に、WSL2の「/home/Username/docker-raspi/ros2_ws」をコンテナ側の「/home/ros2_ws」フォルダとしてマウントした状態で立ち上げたので、WSL2へファイルが出力されています。<br><br>

ビルド前での後でも良いので下記の通りチェックしていただくとわかります。下記の例はビルド後です。
```
$ ls /home/ros2_ws
build  install  log  src
```
新しいコンテナではホームディレクトリにフォルダを作っていないのにフォルダがあって、さらにファイルがあります。srcの中を見るとgit cloneしたraspimouse2があることもわかります。<br><br>

※コンテナを立ち上げた時にros2_ws以下に何もない、という方は、Powershellを立ち上げて、以下を調べてみてください。
```
$ wsl --list --verbose
  NAME                   STATE           VERSION
* Ubuntu-20.04           Running         2
  docker-desktop         Running         2
  docker-desktop-data    Running         2
  Ubuntu                 Stopped         2
```
ここで上記のようにUbuntu-20.04に※が付いていないとダメのようです。※がついいていない方は以下のコマンドで変更できます。
```
$ wsl --terminate Ubuntu-20.04
```

## WSL2 ubuntu:20.04
あとは、ビルドしたros2_wsフォルダの中身をRasberryPiへ移せばよいのですが、さらにもう一工夫が必要です。シンボリックリンクがFTPでコピーできなかったので、tarファイルに固めます。FTPでのコピーで問題なければ、tar化は不要です。
```
$ cd /home/docker-raspi/ros2_ws
$ sudo tar cvf rsp.tar build install log src
```

## Windows10
rsp.tarをFTPでコピーします。コピー先はRaspimouseの/home/ubuntu/ros2_wsになります。場所が重要なので、同じ場所にコピーしてください。場所が異なるとエラーで動きません。

## Raspimouse
rsp.tarを展開します。
```
$ cd /home/ubuntu/ros2_ws
$ tar xvf rsp.tar
$ ls -l
drwxr-xr-x 4 root   root       4096 May  8 03:43 build
drwxr-xr-x 4 root   root       4096 May  8 03:44 install
drwxr-xr-x 3 root   root       4096 May  8 03:42 log
-rw-rw-r-- 1 ubuntu ubuntu 29399040 May  8 03:47 rsp.tar
drwxr-xr-x 3 ubuntu ubuntu     4096 May  8 03:41 src
```
以上で、RaspberryPi3を搭載するRaspimouseへUbuntu20.04+ROS2+raspimouse2をインストール出来ました。

# Raspimouseで動作確認
こちらはrt-shopさんの記事の手順のままです。https://github.com/rt-net/raspimouse2<br>
Raspimouseはステッピングモーターが下に当たらないように浮かしておいてください。<br>
ターミナルを2つ使いますので、Powershellの画面を2つ開いておいてください。<br><br>

### Terminal 1
```
$ source /opt/ros/foxy/setup.bash
$ source ~/ros2_ws/install/setup.bash
$ ros2 run raspimouse raspimouse
```
ここでカーソルが戻ってこなくなります。
### Terminal 2
```
$ source ~/ros2_ws/install/setup.bash
$ ros2 lifecycle set raspimouse configure
Transitioning successful
```
### Set buzzer frequency(Tesminal 2)
コマンドを送って、1秒ほど遅れてブザーがなります。
```
$ ros2 topic pub -1 /buzzer std_msgs/msg/Int16 '{data: 1000}'
$ ros2 topic pub -1 /buzzer std_msgs/msg/Int16 '{data: 0}'
```
### Set rotate motors(Terminal 2)
コマンドを送って、こちらも少し遅れてダイオードが赤く点滅し、さらにコマンドを送るとステッピングモーターが回り始めます。
```
$ ros2 lifecycle set raspimouse activate
$ ros2 service call /motor_power std_srvs/SetBool '{data: true}'
$ ros2 topic pub -1 /cmd_vel geometry_msgs/Twist '{linear: {x: 0.05, y: 0, z: 0}, angular: {x: 0, y: 0, z: 0.05}}'
$ ros2 lifecycle set raspimouse deactivate
```
### ROS2を終了する
Terminal 2
```
$ exit
```
Terminal 1は「ctrl + c」を押してください。<br><br>

# Raspimouseのネットワーク(特にWifi)設定
ネットワーク設定はpapandaさんのブログを参考にしました。
papanndaさんのブログ : https://papanda925.com/?p=698<br>
作業はRaspimouseに搭載しているRaspberryPiで行います。<br>
## Raspimouse
/etc/netplan フォルダにネットワーク設定のファイルを置くことで設定が可能になります。<br>
注意するのは、先にある「50-cloud-init.yaml」は触らないということなので、新しくファイルを作って編集します。<br>
IPアドレス、wifiのアクセスポイントとパスワードは皆さんの環境に合わせてください。
```
$ cd /etc/netplan
$ ls
50-cloud-init.yaml
$ sudo vi 1-cloud-init.yaml

 network:
   version: 2
   renderer: networkd
   ethernets:
     eth0:
          dhcp4: false
          dhcp6: false
          addresses: [192.168.1.2/24]
          gateway4: 192.168.1.1
          nameservers:
          addresses: [192.168.1.1, 8.8.8.8, 8.8.4.4]
   wifis:
     wlan0:
          dhcp4: false
          dhcp6: false
          addresses: [192.168.1.3/24]
          gateway4: 192.168.1.1
          nameservers:
          addresses: [192.168.1.1, 8.8.8.8, 8.8.4.4] 
          access-points:
            アクセスポイント:
            password: パスワード
	    
$ sudo netplan apply
```
再起動は不要です。これで無線LANも有線LANも固定IPで運用が可能になります。


