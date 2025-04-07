#!/bin/bash

# Create the web assets directory if it doesn't exist
mkdir -p web/assets/images

# Copy the logo to the web assets directory
cp assets/images/logo.png web/assets/images/

# Copy the logo as favicon
cp assets/images/logo.png web/favicon.png

# Copy the logo to the icons directory
mkdir -p web/icons
cp assets/images/logo.png web/icons/Icon-192.png
cp assets/images/logo.png web/icons/Icon-512.png
cp assets/images/logo.png web/icons/Icon-maskable-192.png
cp assets/images/logo.png web/icons/Icon-maskable-512.png 