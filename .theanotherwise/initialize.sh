#!/bin/bash

mkdir -p ~/archives
mkdir -p ~/portable
mkdir -p ~/portable/helm
mkdir -p ~/portable/ruby
mkdir -p ~/portable/terraform
mkdir -p ~/portable/node.js
mkdir -p ~/portable/yarn
mkdir -p ~/configurations
mkdir -p ~/configurations/ssh
mkdir -p ~/configurations/ssh/keys
mkdir -p ~/configurations/ssh/sessions
mkdir -p ~/downloads
mkdir -p ~/scripts
mkdir -p ~/git
mkdir -p ~/temporary

if [ "${1}" = "ws" ] ; then
  mkdir -p ~/bluetooth
  mkdir -p ~/captures
  mkdir -p ~/captures/pictures
  mkdir -p ~/captures/videos
  mkdir -p ~/cheat-sheets
  mkdir -p ~/configuration/konsole
  mkdir -p ~/configuration/konsole/tabs
  mkdir -p ~/dashcam
  mkdir -p ~/desktop
  mkdir -p ~/diagrams
  mkdir -p ~/documents
  mkdir -p ~/ebooks
  mkdir -p ~/iso-images
  mkdir -p ~/music
  mkdir -p ~/pictures
  mkdir -p ~/pictures/wallpapers
  mkdir -p ~/projects
  mkdir -p ~/videos
  mkdir -p ~/virtual-machines
  mkdir -p ~/virtual-machines/vmware
  mkdir -p ~/virtual-machines/vmware/archives
  mkdir -p ~/virtual-machines/vmware/templates
  mkdir -p ~/virtual-machines/vmware/workspace
  mkdir -p ~/word-lists
  mkdir -p ~/work
fi