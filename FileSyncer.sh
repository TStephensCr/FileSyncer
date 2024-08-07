#!/bin/bash

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory1> <directory2>"
    exit 1
fi

dir1="$1"
dir2="$2"

# Check if both arguments are directories
if [ ! -d "$dir1" ] || [ ! -d "$dir2" ]; then
    echo "Both arguments must be directories."
    exit 1
fi

# List of files in both directories
common_files=$(comm -12 <(ls "$dir1" | sort) <(ls "$dir2" | sort))
only_in_dir1=$(comm -23 <(ls "$dir1" | sort) <(ls "$dir2" | sort))
only_in_dir2=$(comm -13 <(ls "$dir1" | sort) <(ls "$dir2" | sort))

echo "Files in both directories:"
echo "$common_files"

echo -e "\nFiles only in $dir1:"
echo "$only_in_dir1"

echo -e "\nFiles only in $dir2:"
echo "$only_in_dir2"

# Copy files from dir1 to dir2 that are only in dir1
for file in $only_in_dir1; do
    if [ -f "$dir1/$file" ]; then
        echo "Copying $file from $dir1 to $dir2"
        cp "$dir1/$file" "$dir2/"
    fi
done

# Copy files from dir2 to dir1 that are only in dir2
for file in $only_in_dir2; do
    if [ -f "$dir2/$file" ]; then
        echo "Copying $file from $dir2 to $dir1"
        cp "$dir2/$file" "$dir1/"
    fi
done

echo -e "\nSynchronization complete. Both directories should now contain the same files."
