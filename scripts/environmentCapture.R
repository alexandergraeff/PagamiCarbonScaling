# Snapshot the current R package environment using renv
# ----------------------------------------
# This script captures the current environment. This should
# only be needed when modifying the scripts during development.

  message("Preparing to snapshot the environment...")

# 1. Activate renv for this project
  # This should automatically happen when opening the .Rproj
  # but doesn't hurt to do it here in case it doesn't

  message("Activating renv...")
  renv::activate()
  message("Renv activated!")

# 2. Snapshot the environment

  message("Creating/updating renv.lock...")
  renv::snapshot(prompt = FALSE)
  
  message("Snapshot complete! The renv.lock file is now up to date.")
  message("Commit renv.lock to version control so collaborators can restore the same environment.")
