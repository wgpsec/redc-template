# Linux Basic Setup

This is a userdata template for basic system setup and installing common tools.

## Features

This template automatically executes the following when the Linux system starts:

1. **Update System Packages** - Runs `apt-get update -y` and `apt-get upgrade -y` to update system packages
2. **Install Common Tools** - Installs the following commonly used tools:
   - curl
   - wget
   - git
   - vim

## Usage

Use this template through RedC GUI's "Specialized Modules" or "Custom Deployment" feature:

1. Select the "Linux Basic Setup" template
2. Click the "Copy Script" button
3. Paste it in the cloud server's userdata

## Compatible Systems

- Ubuntu / Debian based Linux distributions
