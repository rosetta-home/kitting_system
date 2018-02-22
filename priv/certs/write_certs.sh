partprobe -s $1
sleep 5s
partition="3"
device="$1$partition"
mkfs.ext4 -U 3041e38d-615b-48d4-affb-a7787b5c4c39 -F $device
mkdir -p /media/$USER/3041e38d-615b-48d4-affb-a7787b5c4c39
mount -t ext4 -o rw $device /media/$USER/3041e38d-615b-48d4-affb-a7787b5c4c39
cp ./priv/certs/root/certs/cicada.crt /media/$USER/3041e38d-615b-48d4-affb-a7787b5c4c39
cp ./priv/certs/root/keys/cicada.key /media/$USER/3041e38d-615b-48d4-affb-a7787b5c4c39
umount /media/$USER/3041e38d-615b-48d4-affb-a7787b5c4c39
