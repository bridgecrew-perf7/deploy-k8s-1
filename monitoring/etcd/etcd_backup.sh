#! /bin/bash


ETCDCTL_PATH='/usr/local/bin/etcdctl'
ENDPOINTS='172.31.0.21:2379'
ETCD_DATA_DIR="/var/lib/etcd"
BACKUP_DIR="/var/backups/kube_etcd/etcd-$(date +%Y-%m-%d_%H:%M:%S)"

ETCDCTL_CERT="/etc/ssl/etcd/ssl/admin-ks-allinone.pem"
ETCDCTL_KEY="/etc/ssl/etcd/ssl/admin-ks-allinone-key.pem"
ETCDCTL_CA_FILE="/etc/ssl/etcd/ssl/ca.pem"


[ ! -d $BACKUP_DIR ] && mkdir -p $BACKUP_DIR


export ETCDCTL_API=2;$ETCDCTL_PATH backup --data-dir $ETCD_DATA_DIR --backup-dir $BACKUP_DIR

sleep 3

{
export ETCDCTL_API=3;$ETCDCTL_PATH --endpoints="$ENDPOINTS" snapshot save $BACKUP_DIR/snapshot.db \
                                   --cacert="$ETCDCTL_CA_FILE" \
                                   --cert="$ETCDCTL_CERT" \
                                   --key="$ETCDCTL_KEY"
} > /dev/null 

sleep 3

cd $BACKUP_DIR/../;ls -lt |awk '{if(NR>(5+1)){print "rm -rf "$9}}'|sh