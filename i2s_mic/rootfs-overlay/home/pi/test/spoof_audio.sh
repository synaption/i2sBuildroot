while true
do
    pv -L 320k input.file > /dev/shm/output.file
    mv /dev/shm/output.file /dev/shm/output2.file
done
