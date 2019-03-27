#!/bin/bash -e


RAMDISK_FILE=".ramdisk_id"
RAMDISK_VOLUME_NAME="stash"
STASH_FILE="stash.tar.gz.gpg"
STASH_DIR="stash"
ME_FILE=".me"

function mk_ramdisk() {
  if [ -f "$RAMDISK_FILE" ]; then
    echo "Run ./run.sh -r to remove the existing ramdisk";
    exit 1;
  fi

  echo "Making ramdisk...";
  hdiutil attach -nomount ram://65536 > $RAMDISK_FILE;

  cat $RAMDISK_FILE;

  echo "Formatting ramdisk";
  diskutil partitionDisk $(cat $RAMDISK_FILE) 1 GPTFormat APFS "$RAMDISK_VOLUME_NAME" "100%";

  echo "Linking ramdisk to stash dir"
  ln -s "/Volumes/$RAMDISK_VOLUME_NAME" $STASH_DIR;
}



while getopts "miedr" opt; do
  case $opt in
    m)
      if [ -f "$ME_FILE" ]; then
          echo "Remove the existing $ME_FILE if you want to set the recipient key (which should probably be you)";
          exit 1;
      fi
      echo $2 > "$ME_FILE";
      ;;
    i)
      echo "Creating initial stash directory"
      mk_ramdisk
      ;;
    e)
      if [ ! -d "$STASH_DIR" ]; then
          echo "Run ./run.sh -d to decrypt the stash change the contents before encrypting";
          exit 1;
      elif [ ! -f "$ME_FILE" ]; then
          echo "Run ./run.sh -m to set the recipient key before encrypting";
          exit 1;
      fi
    
      echo "Encrypting...";
      ME=$(cat $ME_FILE);
      tar --exclude=".*" -zcv $STASH_DIR/* | gpg2 --encrypt -r $ME - > "$STASH_FILE";
      ;;
    d)
      mk_ramdisk;
      echo "Decrypting...";
      gpg2 --decrypt "$STASH_FILE" | tar -zxvf - -C $STASH_DIR --strip-components=1;
      ;;
    r)
      if [ ! -f "$RAMDISK_FILE" ]; then
          echo "Can't remove ramdisk - $RAMDISK_FILE not found";
          exit 1;
      fi

      echo "Unmounting ramdisk...";
      hdiutil detach -force $(cat $RAMDISK_FILE);
      rm $RAMDISK_FILE $STASH_DIR;
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
