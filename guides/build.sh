#!/bin/sh

pnpm run guides:build
cp _redirects .vitepress/dist/_redirects
