#!/usr/bin/env bash

# 모든 test를 실행한다.
# normal dpos tx test
# syncer test
# reorg test
# crash recover test

# raft server boot & down test
pushd $ARG_TEST_DIR/raft/server


echo "kill_svr & clean 11004~11007"
kill_svr.sh
for i in  11004 11005 11006 11007; do
	rm -rf ./data/$i
	rm -rf ./BP$i.toml
done

clean.sh all #remove log
# tx
test_tx.sh 100
# up & down
test_up_down.sh
test_leader_change.sh 10
# slow follower/leader
test_slow_follower.sh
test_slow_leader.sh
test_syncer_crash.sh 0
test_syncer_crash.sh 1
# membership add/remove
test_member.sh
popd
