# Snapshot the current R package environment using renv
# ----------------------------------------
# This script captures the current environment. This should
# only be needed when modifying the scripts during development.

# 1. Activate renv for this project
  # This should automatically happen when opening the .Rproj
  # but doesn't hurt to do it here in case it doesn't

  renv::activate()

# 2. Snapshot the environment

  renv::snapshot(prompt = FALSE)
  
