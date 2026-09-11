#!/usr/bin/env bash
# Vercel build script for the Flutter web app.
#
# The Vercel build image does not ship Flutter and the Build Command field
# is capped at 256 characters, so the full pipeline lives here instead:
# install Flutter, generate .env from environment variables, and build.
set -e

git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"

flutter config --enable-web
printf "SUPABASE_URL=%s\nSUPABASE_ANON_KEY=%s\n" "$SUPABASE_URL" "$SUPABASE_ANON_KEY" > .env
flutter pub get
flutter build web --release
