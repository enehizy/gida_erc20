use starknet::ContractAddress;

#[starknet::interface]
pub trait IERC20<TContractState> {
    fn get_name(self: @TContractState) -> ByteArray;
    fn get_symbol(self: @TContractState) -> ByteArray;
    fn get_decimals(self: @TContractState) -> u8;
    fn get_total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(
        self: @TContractState, owner: ContractAddress, spender: ContractAddress
    ) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn transfer_from(
        ref self: TContractState,
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: u256
    );
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256);
    fn increase_allowance(ref self: TContractState, spender: ContractAddress, added_value: u256);
    fn decrease_allowance(
        ref self: TContractState, spender: ContractAddress, subtracted_value: u256
    );
}

#[starknet::contract]
mod Erc20{
   
use super::IERC20;
use super::ContractAddress;
    use starknet::storage::{Map,StorageMapReadAccess,StorageMapWriteAccess};
    #[storage]
    struct Storage {
        //name of the token
        name: ByteArray,
         //token symbol
        symbol: ByteArray,
        //token decimals e.g 18
        decimals: u8,
        //token max supply
        total_supply: u256,
        //balances of each user
        balances: Map::<ContractAddress, u256>,
        // allownaces for third party contracts
        allowances: Map::<(ContractAddress, ContractAddress), u256>,
    }
    
     // todo :Events and A constructor ,make function external

    impl ERC20IMPL of super::IERC20<ContractState>{
        //get the name of the contract
        fn get_name(self:@ContractState ) -> ByteArray{
          self.name.read()
        }
         //get the symbol of the contract
        fn get_symbol(self: @ContractState) -> ByteArray{
            self.symbol.read()
        }
         //get the decimals
        fn get_decimals(self: @ContractState) -> u8{
          self.decimals.read()
        }
         //get the max/total supply
        fn get_total_supply(self: @ContractState) -> u256{
            self.total_supply.read()
        }
        // get the balance of a contract
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256{
            self.balances.read(account)
        }
        //transfer a token to a recipient
        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            let sender = starknet::get_caller_address();
            self.transfer_from(sender,recipient,amount)
          
        }
        //transfer with two argument sender and recipient
        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) {
            //get the address of the person calling the contract
            let caller = starknet::get_caller_address();
            // panics if caller not equal to sender
            assert!(caller == sender ,"INVALID CALLER");
            let sender_balance= self.balances.read(sender);
            let recipient_balance= self.balances.read(recipient);
            assert!(sender_balance >= amount || self.allowance(caller,recipient) >= 0, "ERROR INSUFFICIENT BALANCE/ALLOWANCE");
            self.balances.write(sender,sender_balance - amount);
            self.balances.write(recipient,recipient_balance + amount);
           
        }
       // approve a contract to spend your token
        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) {
            let caller =starknet::get_caller_address();
            let allowed_person=(caller,spender);
           let previous_allowance= self.allowances.read(allowed_person);
           self.allowances.write(allowed_person,previous_allowance + amount);
        }
          
            
        //Increases the allowance
        fn increase_allowance(
            ref self: ContractState, spender: ContractAddress, added_value: u256
        ) {
            let caller =starknet::get_caller_address();
            let allowed_person=(caller,spender);
           let previous_allowance= self.allowances.read(allowed_person);
           self.allowances.write(allowed_person,previous_allowance + added_value);
            
        }
        //reduces  the allowance
        fn decrease_allowance(
            ref self: ContractState, spender: ContractAddress, subtracted_value: u256
        ) {
            let caller =starknet::get_caller_address();
            let allowed_person=(caller,spender);
           let previous_allowance= self.allowances.read(allowed_person);
           self.allowances.write(allowed_person,previous_allowance - subtracted_value);
        }
        //gets the amount a thirs party contract is allowed to spend
        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress
        ) -> u256{
           self.allowances.read((owner,spender))
        }
    }
}
