#!/usr/bin/env bash
# All the commands used to get from ubuntu-mate-16.04-desktop-armhf-raspberry-pi.img to 2017-fall-duckiebot.img

# This version prepares the duckiebot image for a robot with the following features:
# - Raspberry Pi 3
# - Ubuntu 16.04
# - ROS Kinetic
# - Duckiebot Shield v2.0

# ==== Create swap ====#
echo "Creating swap..."
echo
sudo dd if=/dev/zero of=/swap0 bs=1M count=512 # This is for a 512 MB swap space.
sudo mkswap /swap0
printf '/swap0 swap swap' | sudo tee -a /etc/fstab
sudo swapon -a

# === Update ==== #
echo "Updating system..."
echo
sudo apt-get update -y
sudo apt-get upgrade -y

# ==== Networking stuff ==== #
echo "Installing networking stuff..."
echo
# Install openssh-server for ssh
sudo apt-get install openssh-server -y

# Install avahi for hostname.local access
sudo apt-get install avahi-daemon avahi-discover avahi-utils -y

# Sync the time
#sudo ntpdate -u us.pool.ntp.org

# === Extra stuff ===
echo "Installing more packages..."
echo
sudo apt-get install -y build-essential git python python-dev ipython python-pip
sudo apt-get install -y vim htop byobu libav-tools curl

# === Install ROS Kinetic ==== #
# Following the usual installation instructions from http://wiki.ros.org/kinetic/Installation/Ubuntu
echo "Installing ROS kinetic..."
echo

# Setup locale, deb, and keys
sudo update-locale LANG=C LANGUAGE=C LC_ALL=C LC_MESSAGES=POSIX
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116

# Install ROS
sudo apt-get update
sudo apt-get install ros-kinetic-ros-base -y
# Update rosdep
sudo apt-get install python-rosdep
sudo rosdep init
rosdep update

# source setup.bash
echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
source ~/.bashrc

# === Bus and i2c ===
#sudo apt-get install -y i2c-tools python-smbus
#sudo usermod -a -G i2c ubuntu
# Trigger the rule (reboot will do this too)
#sudo udevadm trigger 

# ==== Arduino Serial Comm ==== #
echo "Configuring serial ports..."
echo
sudo usermod -a -G dialout $USER
sudo chmod a+rw /dev/ttyS0

# This is for RPi3 only
printf 'core_freq=250\n' | sudo tee -a /boot/config.txt
printf 'enable_uart=1\n' | sudo tee -a /boot/config.txt

# === PiCamera Stuff === #
echo "Installing Pi Camera stuff..."
echo

sudo apt-get install --reinstall libraspberrypi0 libraspberrypi-{bin,dev,doc} -y
# Append lines to /boot/config.txt to enable the PiCamera
printf '#Enable PiCamera Interface\n%s\n%s\n' 'start_x=1' 'gpu_mem=256' | sudo tee -a /boot/config.txt
# Create custom rule to enable camera
printf 'SUBSYSTEM=="vchiq",GROUP="video",MODE="0660"' | sudo tee /etc/udev/rules.d/10-vchiq-permissions.rules
# Add user to the video group
sudo usermod -a -G video ubuntu

# Install python picamera drivers
sudo pip install picamera
sudo pip install "picamera[array]"

# ==== Wireless settings ==== #
#echo "Installing and configuring wireless settings..."
#echo

# Install firmware and tools
#sudo apt-get install wireless-tools wpasupplicant linux-firmware -y
# Setup /etc/network/interfaces
#printf 'allow-hotplug wlan0\n auto wlan0\n iface wlan0 inet manual\n wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf\n iface default inet dhcp' | sudo tee -a /etc/network/interfaces
# Setup /etc/wpa_supplicat.conf header
#printf 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\n update_config=1' | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
# Setup duckietown network SSID
#printf 'network={\n ssid="duckietown"\n scan_ssid=1\n psk="quackquack"\n priority=10\n}' | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf

# Setup authorized keys for ssh access for duckietown
#cd ~
#mkdir .ssh
#chmod g-rwx,o-rwx .ssh 
#wget -O .ssh/authorized_keys https://www.dropbox.com/s/pxyou3qy1p8m4d0/duckietown_key1.pub?dl=1

#Add passwordless sudo for user ubuntu:
# $ sudo visudo
# Add line at the end:
# ubuntu ALL=(ALL) NOPASSWD: ALL 
# Select option (1) for byobu.

# ==== ROS Packages ==== #
echo "Installing additional ROS packages..."
echo

# Install additional ROS pkgs to apt-get
sudo apt-get install ros-kinetic-{opencv3,tf-conversions,cv-bridge,image-transport,camera-info-manager,theora-image-transport,image-geometry,image-proc,joy} -y

# List of additional system pkgs
sudo apt-get install libyaml-cpp-dev -y

# sklearn dependencies
sudo apt-get install libblas-dev liblapack-dev libatlas-base-dev gfortran -y 
sudo apt-get install python-numpy python-scipy -y
sudo apt-get install python-sklearn -y

# Remove the net rules to forget the mac address of ethernet and wireless cards
rm /etc/udev/rules.d/70-persistent-net.rules

# === Duckietown Img ==== #
