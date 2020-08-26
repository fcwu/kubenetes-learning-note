

### PostgreSQL

```shell
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install postgresql

pg_lsclusters
pg_ctlcluster 12 main restart
sudo -u postgres createuser --interactive
createdb sammy
alter database k3s owner to k3s
ALTER USER gtwang WITH PASSWORD 'new_password';
```

At this point, unless you configured DRBD to automatically recover from split brain, you must manually intervene by selecting one node whose modifications will be discarded (this node is referred to as the split brain victim). This intervention is made with the following commands:


# drbdadm secondary resource
# drbdadm disconnect resource
# drbdadm -- --discard-my-data connect resource

On the other node (the split brain survivor), if its connection state is also StandAlone, you would enter:


# drbdadm connect resource

You may omit this step if the node is already in the WFConnection state; it will then reconnect automatically.

If all else fails and the machines are still in a split-brain condition then on the secondary (backup) machine issue:

drbdadm invalidate resource


curl -sfL https://get.k3s.io | sh -s - server \
  --datastore-endpoint="postgres://k3s:k3s@192.168.5.10:5432/k3s"

fio --directory=./ --name=randrw --ioengine=posixaio --rw=randwrite --bs=4k --numjobs=1 --size=1g --iodepth=1 --runtime=60 --time_based --end_fsync=1

- fio usage: https://www.twblogs.net/a/5d13ff63bd9eee1ede04fb27