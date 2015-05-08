#!/bin/sh

git pull
rm -rf _site
jekyll build
