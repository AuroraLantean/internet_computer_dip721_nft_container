#[macro_use]
extern crate ic_cdk_macros;
#[macro_use]
extern crate serde;

//use std::borrow::Cow;
use std::cell::RefCell;
use std::collections::HashSet;
use std::result::Result as StdResult;

use candid::{CandidType, Principal};
use ic_cdk::{
    api,
    export::candid::{self, candid_method},
};

thread_local! {
  static STATE: RefCell<State> = RefCell::default();
}
#[derive(CandidType, Deserialize, Default)]
struct State {
    custodians: HashSet<Principal>,
    name: String,
    price: u64,
}
#[derive(CandidType, Deserialize)]
struct InitArgs {
    custodians: Option<HashSet<Principal>>,
    name: String,
    price: u64,
}

#[candid_method(update)]
#[init]
fn init(args: InitArgs) {
    STATE.with(|state| {
        let mut state = state.borrow_mut();
        state.custodians = args
            .custodians
            .unwrap_or_else(|| HashSet::from_iter([api::caller()]));
        state.name = args.name;
        state.price = args.price;
    });
}
#[candid_method(query)]
#[query]
fn greet(name: String) -> String {
    format!("Hello, {}!", name)
}
#[candid_method(query)]
#[query]
fn get_name() -> String {
    STATE.with(|state| state.borrow().name.clone())
}
#[candid_method(query)]
#[query]
fn get_price() -> u64 {
    STATE.with(|state| state.borrow().price.clone())
}

#[derive(CandidType, Deserialize)]
enum Error {
    Unauthorized,
    InvalidTokenId,
    ZeroAddress,
    Other,
}
type Result<T = u64, E = Error> = StdResult<T, E>;

#[candid_method(update)]
#[update]
fn set_name(name: String) -> Result<()> {
    STATE.with(|state| {
        let mut state = state.borrow_mut();
        state.name = name;
        Ok(())
        /*if state.custodians.contains(&api::caller()) {
            state.name = name;
            Ok(())
        } else {
            Err(Error::Unauthorized)
        }*/
    })
}
#[candid_method(update)]
#[update]
fn set_price(price: u64) -> Result<()> {
    STATE.with(|state| {
        let mut state = state.borrow_mut();
        state.price = price;
        Ok(())
        /*if state.custodians.contains(&api::caller()) {
            state.price = price;
            Ok(())
        } else {
            Err(Error::Unauthorized)
        }*/
    })
}
