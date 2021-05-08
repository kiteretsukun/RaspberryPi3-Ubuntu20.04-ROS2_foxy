# Raspimouse : RapsberryPie3 + Ubuntu 20.04 + ROS2 foxy
これはRaspimouseをRapsberryPie3 + Ubuntu 20.04 + ROS2 foxyで動かすための手順です。
基本的にはRT-Shopさんの下記参考URLの1番と2番の手順をなぞれば良いのですが、ROS2のサンプルであるraspimouse2のソースをRapsberryPie3でビルドするとRaspimouseパッケージが25%で止まってしまう現象があります。
この現象を回避する方法をtshellさんが記載してくれていたのですが、おそらくホストPCもUbuntuだと思われましたので、Windows10のDockerを使ってインストールする手順を記載します。
初心者にもわかるようにUbuntu20.04のインストール方法から順番に記載します。

![IMG_0723](https://user-images.githubusercontent.com/34445043/117532437-7ef08280-b022-11eb-8467-5362277e8733.jpg)

## 参考URL
1. Inastall Ubuntu 20.04 and ROS2 for RasberryPie3 : https://www.rt-shop.jp/blog/archives/11061
2. Build the device driver and raspimouse2.git : https://www.rt-shop.jp/blog/archives/11249
3. tshell's blog(build raspimouse2) : https://tshell.hatenablog.com/entry/2021/03/08/222557
4. tshell's blog(install ROS2) : https://tshell.hatenablog.com/entry/2021/03/07/224537

## raspimouse2のビルドが面倒だという方へ
このGitページに保管している rsp.tar がビルド済みのraspimouse2になります。
こちらを展開すればすぐに使えます。（Linux初心者のため環境が変わると使えるかわかりません。）

# Requirements
* Raspberry Pi Mouse(Raspimouse)
  - https://rt-net.jp/products/raspberrypimousev3/
  - RT Robot Shop
  - 私はRaspimouse V2 を使いました。
* RaspberryPie
  - Raspiemouseのバージョンに合わせて、準備してください。V2の場合はRaspberryPie3、V3の場合はRaspberryPie4。
  - microSD : 16GB 以上が良いと思います。
* Linux for RaspberryPie3
  - ubuntu-20.04.2-preinstalled-server-arm64+raspi.img.xz
  - https://ubuntu.com/download/raspberry-pi
* Device Driver
  - https://github.com/rt-net/RaspberryPiMouse
* ROS2
  - https://docs.ros.org/en/foxy/Installation/Ubuntu-Install-Debians.html
* Windows10 
  - version : 20H2
  - Docker Desktop
  - Visual Studio Code(Docker extentionをインストールしておくこと)
  - Powershell
  - Etcher(https://www.balena.io/etcher/) : microSDにUbuntuイメージを書き込むソフト

# RapsberryPie3 に Ubuntu 20.04 をインストールする
Ubuntu.comからRaspberryPieのArm64bitに対応したイメージがダウンロードできるので、ダウンロードしてください。
2021.05.08時点ではUbuntu Server 20.04.2 LTSが選べました。LTSというタイプを選ぶのが良いそうです。このあたりはLinux系の詳しい情報を調べてください。
ダウンロードしたイメージをEtcherというソフトを使ってイメージを書き込みます。
書き込みが終わったら、microSDカードをRaspberryPieに差し込んで起動させます。
  - 立ち上げる前にUSBキーボード、有線LAN、モニター(HDMI)を接続しておいてください。立ち上げて、後から接続しても検知されないので、その場合は電源を無理やり切りましょう。本当は良くないのですが、大丈夫です。
  - RaspberryPie本体は、まだRaspimouseに搭載しなくても良いですが、デバイスドライバーをビルドする時点では搭載した方が良いです。
 
ubuntu server の場合、最初はlogin idもパスワードも「ubuntu」なので、それでログインしてください。
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

# Windows10からRasberryPieのUbuntuへSSH接続するための準備
Ubuntuが立ち上がったRaspberryPieで作業します。
まず、RaspberryPieのIPアドレスを調べます。IPアドレスはサンプルです。
```
$ ip addr show eth0
3: eth0: ...
   inet 192.168.1.9/24 ...
```
次にSSHの準備です。


# デバイスドライバーのインストール
Ubuntuが立ち上がったRaspberryPieで作業します。


