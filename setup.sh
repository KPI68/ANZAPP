#!/QOpenSys/usr/bin/qsh
# #!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <target_library>"
  exit 1
fi

# Assign arguments to variables
TARGET_LIBRARY=$1

# Get source directory (current)
source_dir=$(pwd)
app_name="${source_dir##*/}"
# Or appName=$(basename "source_dir")

# Create SRCPF in target library
system "CRTSRCPF $TARGET_LIBRARY/$app_name"

# List files (if not touch can't cat for some reason)
rm file.list
touch file.list
ls -l > file.list

# Define the file to read
file="file.list"

# Check if the file exists
if [ -f "$file" ]; then
    # Read the file line by line
    while IFS= read -r line
    do
        #echo "$line" - cat file.list to find the actual position of the file name
        #and change below
        file_name="${line:39:21}"
        #echo "file_name: $file_name"
        base_name="${file_name%.*}"
        #echo "base_name: $base_name"
        mbr_type="${file_name##*.}"
        #echo "mbr_type: $mbr_type"
        system "CPYFRMSTMF FROMSTMF('$source_dir/$file_name') \
           TOMBR('/QSYS.LIB/$TARGET_LIBRARY.LIB/$app_name.FILE/$base_name.mbr') \
           MBROPT(*REPLACE)"
        if [ "$mbr_type" != "$base_name" ]; then
           system "CHGPFM FILE($TARGET_LIBRARY/$app_name) MBR($base_name) \
                          SRCTYPE($mbr_type)"
        fi
    done < "$file"
else
    echo "File not found: $file"
fi

