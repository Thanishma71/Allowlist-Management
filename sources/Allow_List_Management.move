module thanishma_addr::AllowlistManager {
    
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use std::vector;
    
   
    const E_ALLOWLIST_NOT_FOUND: u64 = 1;
    const E_ADDRESS_NOT_IN_ALLOWLIST: u64 = 2;
    const E_ALLOWLIST_EXPIRED: u64 = 3;
    const E_UNAUTHORIZED: u64 = 4;
    
   
    struct AllowlistEntry has store {
        address: address,
        expiration_time: u64,
    }
    
   
    struct AllowlistManager has store, key {
        owner: address,
        entries: vector<AllowlistEntry>,
    }
    
    
    public fun initialize_allowlist(owner: &signer) {
        let owner_addr = signer::address_of(owner);
        let allowlist = AllowlistManager {
            owner: owner_addr,
            entries: vector::empty<AllowlistEntry>(),
        };
        move_to(owner, allowlist);
    }
    
    
    public fun add_to_allowlist(
        owner: &signer, 
        target_address: address, 
        expiration_timestamp: u64
    ) acquires AllowlistManager {
        let owner_addr = signer::address_of(owner);
        let allowlist = borrow_global_mut<AllowlistManager>(owner_addr);
        
       
        assert!(allowlist.owner == owner_addr, E_UNAUTHORIZED);
        
        let new_entry = AllowlistEntry {
            address: target_address,
            expiration_time: expiration_timestamp,
        };
        
        vector::push_back(&mut allowlist.entries, new_entry);
    }
    
   
    public fun is_address_allowed(owner_addr: address, target_address: address): bool acquires AllowlistManager {
        if (!exists<AllowlistManager>(owner_addr)) {
            return false
        };
        
        let allowlist = borrow_global<AllowlistManager>(owner_addr);
        let current_time = timestamp::now_seconds();
        let entries_len = vector::length(&allowlist.entries);
        let i = 0;
        
        while (i < entries_len) {
            let entry = vector::borrow(&allowlist.entries, i);
            if (entry.address == target_address && entry.expiration_time > current_time) {
                return true
            };
            i = i + 1;
        };
        
        false
    }

}
