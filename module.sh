#!/bin/bash

# Prompt for the name
read -p "Enter the name for the new template part: " name

# Convert the name to a slug (lowercase, replace spaces with hyphens)
slug=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-')

# Convert the name to upper camel case with spaces
camel_case_name=$(echo "$name" | sed -r 's/(^| )(\w)/\U\2/g')

# Define the path
path="./template-parts/$slug"

# Create the folder
mkdir -p "$path"

# Create slug.php, settings.php, and style.scss files
touch "$path/$slug.php"
touch "$path/settings.php"
touch "$path/style.scss"

# Initialize fields array
fields=""

# Ask if the user wants to add fields
read -p "Would you like to add fields? (yes/no): " add_fields

while [[ "$add_fields" == "yes" ]]; do
    # Choose field type
    echo "Choose field type:"
    echo "1) Text"
    echo "2) Textarea"
    echo "3) Image"
    read -p "Enter the number of the field type: " field_type

    # Choose display name for the field
    read -p "Enter the display name for the field: " display_name

    # Add the chosen field to the fields array
    case $field_type in
        1)
            fields="${fields}Text::make('$display_name'),\n"
            ;;
        2)
            fields="${fields}Textarea::make('$display_name'),\n"
            ;;
        3)
            fields="${fields}Image::make('$display_name')->returnFormat('url'),\n"
            ;;
        *)
            echo "Invalid field type selected."
            ;;
    esac

    # Ask if the user wants to add another field
    read -p "Would you like to add another field? (yes/no): " add_fields
done

# Remove the trailing comma and newline from the fields array
fields=$(echo -e "$fields" | sed 's/,\n$//')

# Add content to settings.php
cat <<EOL > "$path/settings.php"
<?php
// See https://github.com/vinkla/extended-acf#fields for information on available fields.

use Extended\ACF\Fields\Text;
use Extended\ACF\Fields\Textarea;
use Extended\ACF\Fields\Image;

\$fields = array(
$fields
);

register_flexible_layout('$name', '$slug', \$fields);
EOL

# Add require_once line to ./libs/flexible.php
echo "require_once get_template_directory() . '/template-parts/$slug/settings.php';" >> ./libs/flexible.php

# Confirm creation
echo "Folder and files created at: $path"