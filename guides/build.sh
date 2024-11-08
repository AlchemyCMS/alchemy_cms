#!/bin/sh

bun run guides:build
cp guides/_redirects guides/.vitepress/dist/_redirects
