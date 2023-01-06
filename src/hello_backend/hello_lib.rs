use candid::types::number::Nat;
use ic_cdk_macros::*;
use std::cell::RefCell;

thread_local! {
    static COUNTER: RefCell<Nat> = RefCell::new(Nat::from(0));
    //static NEXT_USER_ID: Cell<u64> = Cell::new(0);//flexible -> not persistent upon upgrades
//static BAR: RefCell<f32> = RefCell::new(1.0);
//static ACTIVE_USERS: RefCell<UserMap> = RefCell::new(UserMap::new());
}

/// Get the value of the counter.
#[query]
fn get() -> Nat {
    COUNTER.with(|counter| (*counter.borrow()).clone())
}

/// Set the value of the counter.
#[update]
fn set(n: Nat) {
    ic_cdk::print("Hello World from DFINITY!");
    // COUNTER.replace(n);  // requires #![feature(local_key_cell_methods)]
    COUNTER.with(|count| *count.borrow_mut() = n);
}

/// Increment the value of the counter.
#[update]
fn inc() {
    COUNTER.with(|counter| *counter.borrow_mut() += 1);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_set() {
        let expected = Nat::from(42);
        set(expected.clone());
        assert_eq!(get(), expected);
    }

    #[test]
    fn test_init() {
        assert_eq!(get(), Nat::from(0));
    }

    #[test]
    fn test_inc() {
        for i in 1..10 {
            inc();
            assert_eq!(get(), Nat::from(i));
        }
    }
}
/*

use candid::CandidType;
use serde::Deserialize;

//if the previous deployment did not include this pre_upgrade function, then you need to comment out post_upgrade function to deploy it
#[pre_upgrade]
fn pre_upgrade() {
    let state: &State = ic_cdk::storage::;
    ic_cdk::storage::stable_save((state,)).unwrap(); //arg has to be tuple
}

#[post_upgrade]
fn post_upgrade() {
    let (state,): (State,) = ic_cdk::storage::stable_restore().unwrap();
    *ic_cdk::storage::get_mut() = state;
}

#[query]
fn get_count() -> u32 {
    let state: &State = ic_cdk::storage::get(); //return & parse the value according to the state struct types
    state.count
}

#[derive(CandidType, Deserialize, Default)]
struct State {
    count: u32,
}

#[update]
fn count() -> u32 {
    let state: &mut State = ic_cdk::storage::get_mut(); // &mut and get_mut() !!!
    state.count += 1;
    state.count
}
#[update]
fn reset() {
    let state: &mut State = ic_cdk::storage::get_mut();
    std::mem::take(state); //take that state struct and replace it with the default value
}
*/
