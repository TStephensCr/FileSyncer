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

echo -e "\nCopied all files. Now checking for False Friends(same name, different contents). These conflicts should be manually resolved by the user."

# Loop through files in the first directory
for file1 in "$dir1"/*; do
    filename=$(basename "$file1")
    file2="$dir2/$filename"

    # Check if the file exists in both directories
    if [ -f "$file2" ]; then
        # Compute the hashes of the two files
        hash1=$(sha256sum "$file1" | awk '{ print $1 }')
        hash2=$(sha256sum "$file2" | awk '{ print $1 }')

        # Compare the hashes
        if [ "$hash1" != "$hash2" ]; then
            echo "Files differ: $file1 and $file2"
        fi
    fi
done


echo -e "\nSynchronization complete. Both directories should now contain the same files. Make sure you resolve any conflicts that may have been detected."
