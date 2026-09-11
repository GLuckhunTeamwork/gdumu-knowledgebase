#!/usr/bin/env bash
#
# generate-devcontainer.sh
#
# Interactively scaffolds a .devcontainer/devcontainer.json using the
# mcr.microsoft.com/devcontainers/base:alpine image.
#
# Usage:
#   ./generate-devcontainer.sh
#
# Run it from the root of the project you want the devcontainer added to.

set -euo pipefail

BOLD="$(tput bold 2>/dev/null || true)"
RESET="$(tput sgr0 2>/dev/null || true)"

ask() {
  local prompt="$1" default="$2" var
  read -r -p "${BOLD}${prompt}${RESET} [${default}]: " var
  echo "${var:-$default}"
}

ask_yn() {
  local prompt="$1" default="$2" var
  while true; do
    read -r -p "${BOLD}${prompt}${RESET} (y/n) [${default}]: " var
    var="${var:-$default}"
    case "$var" in
      y|Y) echo "y"; return ;;
      n|N) echo "n"; return ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

echo "=============================================="
echo " Alpine Devcontainer Generator"
echo "=============================================="
echo

# --- Basic project info -----------------------------------------------------
PROJECT_NAME="$(ask "Project / container name" "infrastructure")"
REMOTE_USER="$(ask "Remote user (root recommended for apk installs)" "root")"

# --- Base packages -----------------------------------------------------------
echo
echo "Base tools (git, bash, curl, wget) are always installed."
EXTRA_APK="$(ask "Any additional apk packages? (space separated, blank for none)" "")"

# --- Optional tool toggles ----------------------------------------------------
echo
WANT_PYTHON="$(ask_yn "Install Python3 + pip?" "y")"
WANT_ANSIBLE="$(ask_yn "Install Ansible?" "n")"
WANT_TERRAFORM="$(ask_yn "Install Terraform (via HashiCorp binary release)?" "n")"
if [ "$WANT_TERRAFORM" = "y" ]; then
  TERRAFORM_VERSION="$(ask "Terraform version" "1.15.8")"
fi
WANT_OPENTOFU="$(ask_yn "Install OpenTofu instead of / in addition to Terraform (apk package)?" "n")"
WANT_AWSCLI="$(ask_yn "Install AWS CLI?" "n")"
WANT_GIT_REMOTE_CODECOMMIT="$(ask_yn "Install git-remote-codecommit (requires Python/pip)?" "n")"
if [ "$WANT_GIT_REMOTE_CODECOMMIT" = "y" ]; then
  WANT_PYTHON="y"
fi
WANT_WATCH="$(ask_yn "Install procps (adds 'watch', 'ps', 'top', etc.)?" "n")"

# --- AWS credentials mount ----------------------------------------------------
echo
WANT_AWS_MOUNT="$(ask_yn "Mount an .aws folder into the container?" "n")"
if [ "$WANT_AWS_MOUNT" = "y" ]; then
  echo "  1) Project-local (e.g. ./.aws next to this devcontainer)"
  echo "  2) Home directory (~/.aws)"
  AWS_MOUNT_CHOICE="$(ask "Choose 1 or 2" "1")"
  AWS_READONLY="$(ask_yn "Mount .aws as read-only?" "n")"
fi

# --- VS Code extensions --------------------------------------------------------
echo
echo "Default VS Code extensions: eamodio.gitlens, timonwong.shellcheck"
EXTRA_EXTENSIONS="$(ask "Any additional extension IDs? (space separated, blank for none)" "")"

# ================================================================================
# Build package list
# ================================================================================
APK_PACKAGES="git bash curl wget"
[ "$WANT_PYTHON" = "y" ] && APK_PACKAGES="$APK_PACKAGES python3 py3-pip"
[ "$WANT_ANSIBLE" = "y" ] && APK_PACKAGES="$APK_PACKAGES ansible"
[ "$WANT_TERRAFORM" = "y" ] && APK_PACKAGES="$APK_PACKAGES unzip"
[ "$WANT_OPENTOFU" = "y" ] && APK_PACKAGES="$APK_PACKAGES opentofu"
[ "$WANT_AWSCLI" = "y" ] && APK_PACKAGES="$APK_PACKAGES aws-cli"
[ "$WANT_WATCH" = "y" ] && APK_PACKAGES="$APK_PACKAGES procps"
if [ -n "$EXTRA_APK" ]; then
  APK_PACKAGES="$APK_PACKAGES $EXTRA_APK"
fi
# Deduplicate
APK_PACKAGES="$(echo "$APK_PACKAGES" | tr ' ' '\n' | awk '!seen[$0]++' | tr '\n' ' ' | sed 's/ *$//')"

# ================================================================================
# Build postCreateCommand
# ================================================================================
POST_CREATE="apk update && apk add $APK_PACKAGES"

if [ "$WANT_TERRAFORM" = "y" ]; then
  POST_CREATE="$POST_CREATE && curl -LO https://releases.hashicorp.com/terraform/\${TERRAFORM_VERSION}/terraform_\${TERRAFORM_VERSION}_linux_amd64.zip"
  POST_CREATE="$POST_CREATE && unzip terraform_\${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin"
  POST_CREATE="$POST_CREATE && rm terraform_\${TERRAFORM_VERSION}_linux_amd64.zip"
  POST_CREATE="$POST_CREATE && terraform -version"
fi

if [ "$WANT_GIT_REMOTE_CODECOMMIT" = "y" ]; then
  POST_CREATE="$POST_CREATE && pip install git-remote-codecommit --break-system-packages"
fi

# ================================================================================
# Build extensions list
# ================================================================================
EXTENSIONS='"eamodio.gitlens", "timonwong.shellcheck"'
[ "$WANT_ANSIBLE" = "y" ] && EXTENSIONS="$EXTENSIONS, \"redhat.vscode-yaml\", \"redhat.ansible\""
[ "$WANT_TERRAFORM" = "y" ] && EXTENSIONS="$EXTENSIONS, \"hashicorp.terraform\""
[ "$WANT_AWSCLI" = "y" ] && EXTENSIONS="$EXTENSIONS, \"amazonwebservices.aws-toolkit-vscode\""
if [ -n "$EXTRA_EXTENSIONS" ]; then
  for ext in $EXTRA_EXTENSIONS; do
    EXTENSIONS="$EXTENSIONS, \"$ext\""
  done
fi
# Deduplicate while preserving order
EXTENSIONS="$(echo "$EXTENSIONS" | tr ',' '\n' | sed 's/^ *//;s/ *$//' | awk '!seen[$0]++' | paste -sd, - | sed 's/,/, /g')"

# ================================================================================
# Build mounts / containerEnv blocks
# ================================================================================
MOUNTS_BLOCK=""
if [ "$WANT_AWS_MOUNT" = "y" ]; then
  if [ "$AWS_MOUNT_CHOICE" = "2" ]; then
    AWS_SOURCE='${localEnv:HOME}/.aws'
  else
    AWS_SOURCE='${localWorkspaceFolder}/.aws'
  fi
  READONLY_FLAG=""
  [ "$AWS_READONLY" = "y" ] && READONLY_FLAG=",readonly"
  TARGET_HOME="/root"
  [ "$REMOTE_USER" != "root" ] && TARGET_HOME="/home/$REMOTE_USER"
  MOUNTS_BLOCK="
  \"mounts\": [
    \"source=${AWS_SOURCE},target=${TARGET_HOME}/.aws,type=bind,consistency=cached${READONLY_FLAG}\"
  ],"
fi

CONTAINER_ENV_BLOCK=""
if [ "$WANT_TERRAFORM" = "y" ]; then
  CONTAINER_ENV_BLOCK="
  \"containerEnv\": {
    \"TERRAFORM_VERSION\": \"${TERRAFORM_VERSION}\"
  },"
fi

# ================================================================================
# Write the devcontainer.json
# ================================================================================
OUT_DIR=".devcontainer"
mkdir -p "$OUT_DIR"
OUT_FILE="$OUT_DIR/devcontainer.json"

cat > "$OUT_FILE" <<EOF
{
  "name": "${PROJECT_NAME}",
  "image": "mcr.microsoft.com/devcontainers/base:alpine",
  "runArgs": ["--name=${PROJECT_NAME}"],${CONTAINER_ENV_BLOCK}${MOUNTS_BLOCK}
  "customizations": {
    "vscode": {
      "extensions": [${EXTENSIONS}]
    }
  },
  "postCreateCommand": "${POST_CREATE}",
  "remoteUser": "${REMOTE_USER}"
}
EOF

echo
echo "=============================================="
echo " Done! Wrote ${OUT_FILE}"
echo "=============================================="
echo
cat "$OUT_FILE"
echo
echo "Next steps:"
echo "  1. Review the file above, especially the postCreateCommand."
if [ "$WANT_AWS_MOUNT" = "y" ]; then
  echo "  2. Make sure your .aws folder is gitignored if it's project-local."
fi
echo "  - Open this folder in VS Code and run 'Dev Containers: Reopen in Container'."
