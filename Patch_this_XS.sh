NFS='yourserver@yourdomain.com'
# have to give out a list of hostnames to Patch.
for host in $(cat $1);
do
# Mount the NFS Dir first
        sshpass -p [Root Password] ssh -o StrictHostKeyChecking=no root@$host "/root/install-scripts/xenserver/xs61_patch.sh $host [Root Password] XS61E001.xsupdate 7fd1ba20-1582-4b02-a61d-c251ad0b637c XS61E001 $NFS mountnfs"
        sshpass -p [Root Password] ssh -o StrictHostKeyChecking=no root@$host "/root/install-scripts/xenserver/xs61_patch.sh $host [Root Password] XS61E001.xsupdate 7fd1ba20-1582-4b02-a61d-c251ad0b637c XS61E001 $NFS install"
        sshpass -p [Root Password] ssh -o StrictHostKeyChecking=no root@$host "/root/install-scripts/xenserver/xs61_patch.sh $host [Root Password] XS61E003.xsupdate c5354c77-4643-4e79-8cdf-fac914fc6c85 XS61E003 $NFS install"
done
