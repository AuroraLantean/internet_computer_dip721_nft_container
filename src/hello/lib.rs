//#[ic_cdk_macros::query]
#[query(name = "greet")]
fn greet(name: String) -> String {
    format!("Hello, {}!", name)
}

#[query(name = "get_price")]
fn get_price(num: u64) -> u64 {
    num * 2
}
