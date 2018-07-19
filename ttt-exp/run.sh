#!/bin/bash
echoCmd() {
	echo -e "\033[31;46m"$1"\033[0m"
}
WORK_DIR="$( dirname "$0"  )"
cd $WORK_DIR
WORK_DIR=`pwd`
OS=`uname`

KEY_PRIVATE_11=5HzZMHGcYY1PEhf37uzECRBXeBaddRQ75LY5ya85kMMr36hCaLHW
KEY_PUB_11=EOS8jpkUrHmL65iYxTwDQCETuKHq1K5C4N6dTSQsccC5bWjtMQv5Y

KEY_PRIVATE_2=5KjjufiVnLcXULyyBeFzZRzHywtT1MbNfvsfWDEby3WQ9nhNzzg
KEY_PUB_2=EOS5i7zvW5oUdkyrwSN8VnxX38uwB7U3HvSHZMuUhNgQF6P8H3M4V

KEY_PRIVATE_1=5KZG619Fht23AYGuh3Py8ZapQkrEWrRy3A7bax5eegoCWYfnvTv
KEY_PUB_1=EOS8F9J5oceGUHzJRU63jTxaJ7j4chPEcBLjpAaFpMfqpbLUKKeMM

KEY_PRIVATE_4=5JnX3aENCraodCwALemQR488XnvtYKF3Yjr8UPPuSdqVnJ7Y4j6
KEY_PUB_4=EOS6B3YWEnEk2cNJekvr2cCC8C572F9ZUBkQCU1uK4x6sBmzo95KN



#build code
cd $WORK_DIR/tic_tac_toe
eosiocpp -o tic_tac_toe.wast tic_tac_toe.cpp
#eosiocpp -g tictactoe.abi tic_tac_toe.cpp
cd -


if [ ! -f $WORK_DIR"/../passwd.txt" ];then
	../setup.sh
fi
cat $WORK_DIR/../passwd.txt | cleos wallet unlock -n exp
cleos wallet import -n exp $KEY_PRIVATE_1
cleos wallet import -n exp $KEY_PRIVATE_2

#kill old nodeos
if [ $OS"x" == "Darwinx" ];then
	ps a > ./tmp.txt
	grep "nodeos" ./tmp.txt|awk '{print $1}'|xargs kill -9
	rm ./tmp.txt
else
	ps auxf|grep "nodeos -e"|awk '{print $2}'|xargs kill -9
fi
#launch nodeos --resync 
echo "launch nodeos ......"
nohup nodeos -e -p eosio --plugin eosio::chain_api_plugin --plugin eosio::history_api_plugin  --replay-blockchain --data-dir ./.tmpdata/eosio 2>&1 1>nodeos.log &
sleep 2
cleos create account eosio tictactoe $KEY_PUB_2 $KEY_PUB_2
cleos set contract tictactoe ./tic_tac_toe -p tictactoe
cleos create account eosio itleaks $KEY_PUB_1 $KEY_PUB_1

echo ""
echo ""
echo "********run test case **********"
echo ""



echoCmd "cleos push action tictactoe create '{"challenger":"inita", "host":"initb"}' --permission initb@active"
cleos push action tictactoe create '{"challenger":"inita", "host":"initb"}' --permission initb@active 
echoCmd "cleos push action tictactoe move '{"challenger":"inita", "host":"initb", "by":"initb", "mvt":{"row":0, "column":0} }' --permission initb@active"
cleos push action tictactoe move '{"challenger":"inita", "host":"initb", "by":"initb", "mvt":{"row":0, "column":0} }' --permission initb@active
echoCmd "cleos push action tictactoe move '{"challenger":"inita", "host":"initb", "by":"inita", "mvt":{"row":1, "column":1} }' --permission inita@active"
cleos push action tictactoe move '{"challenger":"inita", "host":"initb", "by":"inita", "mvt":{"row":1, "column":1} }' --permission inita@active
echoCmd "cleos push action tictactoe restart '{"challenger":"inita", "host":"initb", "by":"initb"}' --permission initb@active "
cleos push action tictactoe restart '{"challenger":"inita", "host":"initb", "by":"initb"}' --permission initb@active 
echoCmd "cleos push action tictactoe close '{"challenger":"inita", "host":"initb"}' --permission initb@active"
cleos push action tictactoe close '{"challenger":"inita", "host":"initb"}' --permission initb@active
echoCmd "cleos get table tictactoe initb games"

