#!/bin/bash
# set -xueEo pipefail
#
# Clone the dotfiles repository as a bare repo.
# A bare repository stores the git history but doesn't have a working tree,
# which is perfect for managing dotfiles in the home directory.
git clone --bare https://github.com/xuex1x/dotfiles.git $HOME/.dotfiles

# Define an alias function for git operations on the dotfiles repo.
# This avoids polluting the global git command and makes commands cleaner.
function dot() {
  /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
}

# Create a backup directory for any existing dotfiles that would conflict.
mkdir -p .dotfiles-backup
echo "Looking for pre-existing dotfiles to back up..."
has_backed_up=false
# Assumes the default branch is 'main'. Change to 'master' if needed.
dot ls-tree -r main --name-only | while read -r file; do
  if [ -e "$HOME/$file" ]; then
    if ! $has_backed_up; then
      printf "\033[33mFound conflicting files. Moving them to .dotfiles-backup\033[0m\n"
      has_backed_up=true
    fi
    printf "\033[32m  -> Backing up $file\033[0m\n"
    # Ensure the parent directory exists in the backup folder to support nested files
    mkdir -p ".dotfiles-backup/$(dirname "$file")"
    mv "$HOME/$file" ".dotfiles-backup/$file"
  fi
done

# Now that all conflicting files have been moved, we can safely perform the checkout.
echo "Checking out dotfiles from the bare repository..."
dot checkout

# Final check to ensure the checkout was successful.
if [ $? = 0 ]; then
  printf "\033[32mChecked out dotfiles successfully.\033[0m\n"
else
  # If checkout still fails here, there's a more serious problem.
  printf "\033[31mFailed to checkout dotfiles. Please check the fail infomation.\033[0m\n"
  exit 1
fi

# Configure git to not show untracked files in `git status`.
dot config status.showUntrackedFiles no
printf "\033[32mSetup complete! Dotfiles now managed by dot.\033[0m\n"
