#!/bin/sh
cd /app/app
pnpm build
cd /app/server
pnpm build
