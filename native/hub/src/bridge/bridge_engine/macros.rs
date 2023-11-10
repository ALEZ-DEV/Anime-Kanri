#[macro_export]
macro_rules! spawn_bridge_task {
    ($($tt:tt)*) => {{
        let bridge_task = $crate::transfer!($($tt)*);
        #[cfg(not(target_family = "wasm"))]
        {
            bridge_task();
        }
        #[cfg(target_family = "wasm")]
        {
            $crate::bridge::bridge_engine::wasm_bindgen_src::worker::WEB_WORKER.with(|worker| {
                let _ = bridge_task.apply(worker);
            });
        }
    }};
}

/// On WASM, [JsValue][wasm_bindgen::JsValue]s cannot be shared between scopes
/// but instead can be ["transferred"].
/// Rust however is not aware of transferables and therefore cannot capture these values.
/// This macro wraps a closure and returns a [TransferClosure][crate::ffi::TransferClosure]
/// on WASM platforms which will capture these special values,
/// or a normal [FnOnce] on other platforms.
/// Note that the parameter names must match available variables/bindings from the outer scope.
///
/// ["transferred"]: https://developer.mozilla.org/en-US/docs/Glossary/Transferable_objects
#[macro_export]
macro_rules! transfer {
    (|| $block:block) => {{
        #[cfg(not(target_family = "wasm"))]
        { move || $block }
        #[cfg(target_family = "wasm")]
        {
            $crate::ffi::TransferClosure::new(vec![], vec![], move |_: &[JsValue]| $block)
        }
    }};
    (|$($param:ident: $ty:ty),*| $block:block) => {{
        #[cfg(not(target_family = "wasm"))]
        {
            move || $block
        }
        #[cfg(target_family = "wasm")]
        {
            use wasm_bindgen::JsValue;
            use $crate::bridge::bridge_engine::ffi::Transfer;
            #[allow(unused_variables)]
            let worker = move |transfer: &[JsValue]| {
                let idx = 0;
                $(
                    let $param = <$ty>::deserialize(&transfer[idx]);
                    let idx = idx + 1;
                )*
                $block
            };
            let transferables = [$($param.transferables()),*].concat();
            $crate::bridge::bridge_engine::ffi::TransferClosure::new(
                vec![$($param.serialize()),*],
                transferables,
                worker,
            )
        }
    }};
}

#[macro_export]
macro_rules! console_error {
    ($lit:literal) => {
        $crate::error($lit)
    };
    ($($tt:tt)*) => {
        $crate::bridge::bridge_engine::error(&format!($($tt)*))
    };
}
