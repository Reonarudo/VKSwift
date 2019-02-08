# VKSwift

This is a project template for Linux Swift apps running the Vulkan SDK.

## Instalation procedure
Everything was built and tested on Xubuntu 18.04
Swift is installed from the official website. This project currently depends on version 4.2.
'''bash
sudo apt-get install clang libicu-dev libcurl4
wget https://swift.org/builds/swift-4.2.2-release/ubuntu1804/swift-4.2.2-RELEASE/swift-4.2.2-RELEASE-ubuntu18.04.tar.gz
tar xvpf swift-4.2-RELEASE-ubuntu18.04.tar.gz
export PATH=~/swift-4.2-RELEASE-ubuntu18.04/usr/bin:$PATH
'''

Vulkan was installed trhough 'apt-get'
'''bash
sudo apt-get install libglm-dev cmake libxcb-dri3-0 libxcb-present0 libpciaccess0 \
libpng-dev libxcb-keysyms1-dev libxcb-dri3-dev libx11-dev \
libmirclient-dev libwayland-dev libxrandr-dev libxcb-ewmh-dev
'''
