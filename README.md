# docker-rclone-mount

Docker for Rclone FUSE mount (exposable to host and other containers)

Documentation can be found here: https://forums.lime-technology.com/topic/56921-support-rclone-mount-with-exposable-fuse-support-for-plex-beta/

NOTE: Updated for Rclone v1.50.2

```
--cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfine -v /mnt/disks/rclone_volume/:/data:shared
```
