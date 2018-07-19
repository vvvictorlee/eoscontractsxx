#!/bin/bash
WORK_DIR="$( dirname "$0"  )"
cd $WORK_DIR
WORK_DIR=`pwd`
OS=`uname`

KEY_PRIVATE_1=5KUrsPXLdoFT3vFWyx83tkXKAbmK3q8UduHU5sYih8qPjauu6R4
KEY_PUB_1=EOS7EocEsUr72X5ti9yaiazmebtZk278cDXhrFXMEoNMJAVqZiLTc

#KEY_PRIVATE_1=5HzZMHGcYY1PEhf37uzECRBXeBHiRQ75LY5ya85kMMr36hCaLHW
#KEY_PUB_1=EOS8jpkUrHmL65iYxTwDQCETuKHq1K5C4N6dTSQsccC5bWjtMQv5Y

#KEY_PRIVATE_2=5KjjufiVnLcXULyyBeFzZRzHywtT1MbNfvsfWDEby3WQ9nhNzzg
#KEY_PUB_2=EOS5i7zvW5oUdkyrwSN8VnxX38uwB7U3HvSHZMuUhNgQF6P8H3M4V
KEY_PRIVATE_2=5JQv2aXyRUg2j8N1eFAtsTzj1bYcEg6CS9xkRg3rnAKdQsdHJso
KEY_PUB_2=EOS4xYmgQW4gUnMJy2neftCFdZCK9Ps2i6MPVcB5rK4eezoJ1HSWz

#build code
cd $WORK_DIR/ping
eosiocpp -o ping.wast ping.cpp
eosiocpp -g ping.abi ping.cpp
cd -
rm -rf .tmpdata/eosio/*

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
nohup nodeos -e -p eosio --contracts-console --plugin eosio::chain_api_plugin --plugin eosio::history_api_plugin --config-dir ./ --data-dir ./.tmpdata/eosio  2>&1 1>nodeos.log &
sleep 2
cleos create account eosio ping.ctr $KEY_PUB_1 $KEY_PUB_1
cleos set contract ping.ctr ./ping -p ping.ctr
cleos create account eosio tester $KEY_PUB_2 $KEY_PUB_2

echo ""
echo ""
echo "********run test case **********"
echo ""
echo 'cleos push action ping.ctr ping '[ "tester" ]' -p ping.ctr'
cleos push action ping.ctr ping '[ "tester" ]' -p ping.ctr
echo 'cleos push action ping.ctr ping '[ "tester" ]' -p pint.ctr'
cleos push action ping.ctr ping '[ "tester" ]' -p tester
