#!/bin/sh

# 0 - no such proc
# 1 - one or more
function check_remote_recv() {
	LIST=`ssh ${REMOTE} "ps aux|grep recvfile| grep ${PORT} |grep -v grep"`	
	# multi fields, not empty line
	if [ `echo ${LIST} | wc | awk '{print $2}'` -gt 1 ] 
	then
		return 1
	else
		return 0
	fi
}

function kill_remote_recv() {
	echo "kill any recv proc on ${REMOTE_ADDR}..." 
	ssh -n ${REMOTE} "killall recvfile 2>/dev/null" 

	# check to see if killed
	check_remote_recv
	if [ $? -eq 0 ]
	then
		echo -e ${INFO} kill_remote_recv OK
	else
		echo -e ${ERROR} kill_remote_recv... FAIL
		exit 1	
	fi		
}

# return:
# 1 - terminated
# 0 - failed to terminate
function wait_remote_recv_terminate() {
	KILLED=0
	#for T in {1..30}
	for (( T=1; T<${RECV_TIMEOUT}; T++ ))
	do
		check_remote_recv
		if [ $? -eq 0 ]
		then		
			KILLED=1
			break
		else
			#echo "Waiting for recv to terminate for $T sec..."
			echo "Have waited for recv to terminate for $T sec(s)..."
			sleep 1
		fi
	done
		
	return ${KILLED}
}

function rm_remote_recv() {
	ssh ${REMOTE} "rm -f ${REMOTE_TOP}/testfiles/*.recv"
}

# $1 file name
#
# return 
# 0 - same 
# 1 - diff
function check_md5sum() {
	R=`ssh -n ${REMOTE} "md5sum ${REMOTE_TOP}/testfiles/$1.recv" | awk '{print $1}'`
	L=`md5sum ${LOCAL_TOP}/testfiles/$1 | awk '{print $1}'`
	if [ "$R" = "$L" ]
	then
		return 0
	else
		echo $R, $L
		return 1
	fi
}

FILES="testfiles/1k.random testfiles/1m.random testfiles/300m.bigfile"
#FILES="testfiles/300m.bigfile"

#ssh -n ${REMOTE} "sh -c \"nohup ${REMOTE_TOP}/recvfile -p ${PORT} > /dev/null 2>&1 &\"" 
#ssh -n ${REMOTE} "nohup ${REMOTE_TOP}/recvfile -p ${PORT} > /dev/null 2>&1 &" 
#ssh ${REMOTE} "ps aux|grep ${REMOTE_TOP}/recvfile|grep -v grep"

# cleaning...
TESTLOG=test.log
PROGLOG=prog.log
PROGERR=prog.err

SEND_TIMEOUT=300
RECV_TIMEOUT=3000

LOCAL_TOP=`pwd`

rm -f ${TESTLOG} ${PROGLOG} ${PROGERR}  

kill_remote_recv

for PARAM in " " "--delay 10" "--drop 10" "--reorder 10" "--mangle 10" "--delay 10 --drop 10 --reorder 10 --mangle 10" "--delay 50 --drop 50 --reorder 50 --mangle 50"
do
	for F in ${FILES}
	do			
		wait_remote_recv_terminate
		
		if [ $? -eq 0 ]
		then
			kill_remote_recv
			echo -e "${WARN} Remote recv failed to terminated... Killed" | tee -a ${TESTLOG}
			#exit 1
		else
			echo -e "${INFO} Remote recv terminated"
		fi		

		echo "---------------------------------" | tee  -a ${TESTLOG}
		echo TEST: $F netsim: ${PARAM} timeout tx/rx: ${SEND_TIMEOUT}/${RECV_TIMEOUT} | tee -a ${TESTLOG}
		echo "---------------------------------" | tee -a ${TESTLOG}		
	
		rm_remote_recv
		
		# setting up remote net
		echo -e ${INFO} "set remote netsim ..."		
		#set -x
		ssh ${REMOTE} "/usr/bin/netsim ${PARAM} > /dev/null"
		#set +x
		
		# launch remote recv
		echo -e ${INFO} "launch remote recv ..."		
		set -x
		ssh ${REMOTE} "cd ${REMOTE_TOP} && ${REMOTE_TOP}/recv_nohup.sh ${PORT}"
		set +x
		check_remote_recv
	
		if [ $? -eq 1 ]
		then
			echo -e "${INFO} check_remote_recv"
		else
			echo -e "${ERROR} check_remote_recv"
			exit 1
		fi
		#sleep 1
		
		# XXX sendfile never terminate?
		echo -e ${INFO} "launch local send ..."
		
		set -x
		#time ./sendfile -r ${REMOTE_ADDR}:${PORT} -f $F > prog.log 2>prog.err
		#(time ./sendfile -r ${REMOTE_ADDR}:${PORT} -f $F > prog.log 2>prog.err) 2>> ${TESTLOG}
		#~/spring12/felix/bin/timeout ${SEND_TIMEOUT} -k (time ./sendfile -r ${REMOTE_ADDR}:${PORT} -f $F > ${PROGLOG} 2>${PROGERR}) 2>> ${TESTLOG}
		~/spring12/felix/bin/timeout ${SEND_TIMEOUT} /usr/bin/time -o /tmp/time-res -p ${LOCAL_TOP}/sendfile -r ${REMOTE_ADDR}:${PORT} -f $F > ${PROGLOG} 2>${PROGERR}
		set +x		
		cat /tmp/time-res >> ${TESTLOG}
		#~/spring12/felix/bin/timeout ${SEND_TIMEOUT} /usr/bin/time "./sendfile -r ${REMOTE_ADDR}:${PORT} -f $F"
		
		if [ $? -eq 124 ] # timeout, got killed
		then
			echo -e "${ERROR} local send failed to terminate, killed" | tee -a ${TESTLOG}
			#echo "failed: local send failed to terminate" >> ${TESTLOG}
		fi
		
		wait_remote_recv_terminate

		if [ $? -eq 0 ]
		then
			kill_remote_recv
			echo -e "${WARN} Remote recv failed to terminated... Killed" | tee -a ${TESTLOG}
			#exit 1
		else
			echo -e "${INFO} Remote recv terminated"
		fi
		
		# even if remote recv forced to end, still chk md5sum...
		check_md5sum `basename $F`
		if [ $? -eq 0 ] 
		then
			echo -e "${OK} md5sum checked" | tee -a ${TESTLOG}
		else
			echo -e "${ERROR} bad md5sum" | tee -a ${TESTLOG}
		fi
		
	done
done

echo "All Done"



