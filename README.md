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

# Requirements
* Raspberry Pi Mouse(Raspimouse)
  - https://rt-net.jp/products/raspberrypimousev3/
  - RT Robot Shop
  - 私はRaspimouse V2 を使いました。
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

# RapsberryPie3 に Ubuntu 20.04 をインストールする

