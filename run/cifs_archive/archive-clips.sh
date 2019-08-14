#!/bin/bash -eu

#For local debug only
#function log(){
#  echo "$1"
#}
#CAM_MOUNT=/mnt/cam
#ARCHIVE_MOUNT=/mnt/archive
#LOG_FILE=/tmp/log.txt

log "Moving clips to archive..."



NUM_FILES_MOVED=0


log "Checking $CAM_MOUNT/TeslaCam/RecentClips/*"
for file_name in "$CAM_MOUNT"/TeslaCam/RecentClips/*; do
  log "Checking file [$file_name]"
  [ -e "$file_name" ] || continue
  log "Moving $file_name ..."
  regex='.*/(2019.*)-.*mp4'
  [[ $file_name =~ $regex ]]
  DATE_DIR="$ARCHIVE_MOUNT/${BASH_REMATCH[1]}"
  if [ ! -d "$DATE_DIR" ]
  then
	  log "$DATE_DIR is not exist..create one"
	  mkdir $DATE_DIR
  else
	  log "$DATE_DIR exist..just copy"
  fi
  mv -f "$file_name" "$DATE_DIR" >> "$LOG_FILE" 2>&1
  if [ $? -eq 0 ]
  then
    log "Moved $file_name to $DATE_DIR"
    NUM_FILES_MOVED=$((NUM_FILES_MOVED + 1))
  else
    log "Failed to move $file_name"
  fi
  
done

log "Checking $CAM_MOUNT/TeslaCam/SavedClips/*"
for file_name in "$CAM_MOUNT"/TeslaCam/SavedClips/*; do
  [ -e "$file_name" ] || continue
  log "Moving $file_name ..."
  mv -f "$file_name" "$ARCHIVE_MOUNT" >> "$LOG_FILE" 2>&1
  if [ $? -eq 0 ]
  then
    log "Moved $file_name to $DATE_DIR"
    NUM_FILES_MOVED=$((NUM_FILES_MOVED + 1))
  else
    log "Failed to move $file_name"
  fi
  
done




log "Moved $NUM_FILES_MOVED file(s)."

if [ $NUM_FILES_MOVED -gt 0 ]
then
/root/bin/send-pushover "$NUM_FILES_MOVED"
fi

log "Finished moving clips to archive."
