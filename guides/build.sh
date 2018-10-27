#!/bin/sh

yarn guides:build
cp guides/_redirects guides/.vuepress/dist/_redirects
