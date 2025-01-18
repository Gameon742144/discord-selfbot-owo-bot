#!/bin/bash

# Variables
PANEL5_REPO="https://github.com/achul123/panel5.git"
PTERODACTYL_REPO="https://github.com/pterodactyl/panel.git"
PUFFERPANEL_REPO="https://github.com/pufferpanel/pufferpanel.git"
WORK_DIR="panel5_enhanced"
PANEL5_DIR="$WORK_DIR/panel5"
PTERODACTYL_DIR="$WORK_DIR/pterodactyl"
PUFFERPANEL_DIR="$WORK_DIR/pufferpanel"

# Step 1: Prepare the work directory
echo "Setting up work directory..."
rm -rf $WORK_DIR
mkdir $WORK_DIR
cd $WORK_DIR || exit 1

# Step 2: Clone all repositories
echo "Cloning repositories..."
git clone $PANEL5_REPO panel5 || { echo "Failed to clone panel5 repo"; exit 1; }
git clone $PTERODACTYL_REPO pterodactyl || { echo "Failed to clone Pterodactyl repo"; exit 1; }
git clone $PUFFERPANEL_REPO pufferpanel || { echo "Failed to clone PufferPanel repo"; exit 1; }

# Step 3: Merge Pterodactyl and PufferPanel features into panel5
echo "Merging Pterodactyl and PufferPanel features into panel5..."
cp -r $PTERODACTYL_DIR/* $PANEL5_DIR/ || { echo "Failed to copy Pterodactyl files"; exit 1; }
cp -r $PUFFERPANEL_DIR/* $PANEL5_DIR/ || { echo "Failed to copy PufferPanel files"; exit 1; }

# Step 4: Install dependencies
echo "Installing dependencies..."
cd $PANEL5_DIR || exit 1
composer install --no-dev --optimize-autoloader || { echo "Composer install failed"; exit 1; }
npm install && npm run build || { echo "NPM install/build failed"; exit 1; }

# Step 5: Database migrations and configurations
echo "Setting up database..."
php artisan migrate || { echo "Database migration failed"; exit 1; }
php artisan db:seed || { echo "Database seeding failed"; exit 1; }

# Step 6: Enhance UI/UX
echo "Applying dark theme and UI enhancements..."
# Example of applying a custom dark theme
cp -r ../dark-theme-resources/* public/ || { echo "Failed to copy dark theme resources"; exit 1; }

# Step 7: Integrate PufferPanel-specific configurations
echo "Applying PufferPanel-specific configurations..."
# Include PufferPanel service management and templates
cp -r $PUFFERPANEL_DIR/templates/* resources/views/templates/ || { echo "Failed to copy PufferPanel templates"; exit 1; }
cp $PUFFERPANEL_DIR/config/pufferpanel.php config/ || { echo "Failed to copy PufferPanel config"; exit 1; }

# Step 8: Start application without systemd or Docker
echo "Starting application without systemd or Docker..."
# Run the application using PHP's built-in server
php -S 0.0.0.0:8000 -t public &
# Capture the PID to manage the process manually
echo $! > ../panel5_server.pid

echo "Application is running at http://0.0.0.0:8000"

# Step 9: Testing and cleanup
echo "Running tests..."
php artisan test || { echo "Tests failed"; exit 1; }

echo "Cleaning up..."
rm -rf ../pterodactyl ../pufferpanel

# Step 10: Finalizing
echo "Pushing changes to the panel5 repository..."
git add .
git commit -m "Integrated Pterodactyl and PufferPanel features with enhancements"
git push || { echo "Failed to push changes"; exit 1; }

echo "Enhanced panel5 project with Pterodactyl and PufferPanel features is ready!"
