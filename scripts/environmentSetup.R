# Project Environment Setup Script
# ----------------------------------------
# This script ensures that the correct R packages are installed
# and the renv environment is restored for reproducibility.

# 1. Install renv if not already installed

  if (!requireNamespace("renv", quietly = TRUE)) {
    message("Installing 'renv' package...")
    install.packages("renv")
  }

# 2. Activate renv for this project
  # This should automatically happen when opening the .Rproj
  # but doesn't hurt to do it here in case it doesn't

  renv::activate()

# 3. Restore packages from lockfile

  if (file.exists("renv.lock")) {
    message("Restoring packages from renv.lock...")
    renv::restore(prompt = FALSE)
  } else {
    message("No renv.lock file found. Consider running renv::snapshot() after installing packages.")
  }
