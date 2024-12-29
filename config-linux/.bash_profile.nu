#!/usr/bin/env nu

if (which nvidia-settings | is-not-empty) {
  nvidia-settings --load-config-only
}
