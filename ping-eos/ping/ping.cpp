#include <eosiolib/eosio.hpp>
#include <eosiolib/print.hpp>
using namespace eosio;

class hello_world : public eosio::contract {
public:
    using contract::contract;
    
    /// @abi action
    void ping( account_name receiver ) {
        require_auth(receiver);
        print( "Hello, ", name{receiver} );
    }
};

EOSIO_ABI( hello_world, (ping) )
