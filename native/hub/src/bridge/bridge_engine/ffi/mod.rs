#[cfg(target_family = "wasm")]
pub type DartAbi = wasm_bindgen::JsValue;
#[cfg(not(target_family = "wasm"))]
pub type DartAbi = allo_isolate::ffi::DartCObject;
#[cfg(not(target_family = "wasm"))]
use dart_sys::Dart_PersistentHandle;

use std::{mem, ops, sync::Arc, thread::ThreadId};

#[cfg(not(target_family = "wasm"))]
pub use allo_isolate::IntoDart;

#[cfg(target_family = "wasm")]
pub type MessagePort = web::PortLike;
#[cfg(not(target_family = "wasm"))]
pub type MessagePort = i64;

#[cfg(target_family = "wasm")]
pub type OpaqueMessagePort = wasm_bindgen::JsValue;
#[cfg(not(target_family = "wasm"))]
pub type OpaqueMessagePort = i64;

#[cfg(target_family = "wasm")]
pub type DartWrapObject = wasm_bindgen::JsValue;
#[cfg(not(target_family = "wasm"))]
pub type DartWrapObject = DartHandleWrap;

#[cfg(target_family = "wasm")]
pub type DartObject = wasm_bindgen::JsValue;
#[cfg(not(target_family = "wasm"))]
pub type DartObject = Dart_PersistentHandle;

#[cfg(target_family = "wasm")]
pub mod web;
#[cfg(target_family = "wasm")]
pub use web::*;

#[cfg(not(target_family = "wasm"))]
pub type Channel = allo_isolate::Isolate;

#[cfg(not(target_family = "wasm"))]
pub mod io;

#[cfg(not(target_family = "wasm"))]
pub use io::*;

use crate::bridge::bridge_engine::DartSafe;

/// A wrapper to transfer ownership of T to Dart.
///
/// This type is equivalent to an [`Option<Arc<T>>`]. The inner pointer may
/// be None if a nullptr is received from Dart, signifying that this pointer
/// has been disposed.
///
/// Extensions for [`sync::RwLock`] and [`sync::Mutex`] are provided.
///
/// ## Naming the inner type
///
/// When an `RustOpaque<T>` is transformed into a Dart type, T's string
/// representation undergoes some transformations to become a valid Dart type:
/// - Rust keywords (dyn, 'static, DartSafe, etc.) are automatically removed.
/// - ASCII alphanumerics are kept, all other characters are ignored.
///
/// ## Trait objects
///
/// Trait objects may be put behind opaque pointers, but they must implement
/// [`DartSafe`] to be safely sent to Dart. For example, this declaration can
/// be used across the FFI border:
///
/// ```rust
/// use crate::*;
/// use std::fmt::Debug;
/// use std::panic::{UnwindSafe, RefUnwindSafe};
///
/// // Rust does not allow multiple non-auto traits in trait objects, so this
/// // is one workaround.
/// pub trait DartDebug: DartSafe + Debug {}
///
/// impl<T: DartSafe + Debug> DartDebug for T {}
///
/// pub struct DebugWrapper(pub RustOpaque<Box<dyn DartDebug>>);
///
/// // creating a DebugWrapper using the opaque_dyn macro
/// let wrap = DebugWrapper(opaque_dyn!("foobar"));
/// // it's possible to name it directly
/// pub struct DebugWrapper2(pub RustOpaque<Box<dyn Debug + Send + Sync + UnwindSafe + RefUnwindSafe>>);
/// ```
#[repr(transparent)]
#[derive(Debug)]
pub struct RustOpaque<T: ?Sized + DartSafe> {
    ptr: Option<Arc<T>>,
}

impl<T: DartSafe> RustOpaque<T> {
    pub fn try_unwrap(self) -> Result<T, Self> {
        if let Some(ptr) = self.ptr {
            Arc::try_unwrap(ptr).map_err(RustOpaque::from)
        } else {
            panic!("Use after free.")
        }
    }
}

impl<T: ?Sized + DartSafe> Clone for RustOpaque<T> {
    fn clone(&self) -> Self {
        Self {
            ptr: self.ptr.clone(),
        }
    }
}

/// # Safety
///
/// This function should never be called manually.
/// Retrieving an opaque pointer from Dart is an implementation detail, so this
/// function is not guaranteed to be API-stable.
pub unsafe fn opaque_from_dart<T: DartSafe>(ptr: *const T) -> RustOpaque<T> {
    // The raw pointer is the same one created from Arc::into_raw,
    // owned and artificially incremented by Dart.
    RustOpaque {
        ptr: (!ptr.is_null()).then(|| Arc::from_raw(ptr)),
    }
}

impl<T: ?Sized + DartSafe> ops::Deref for RustOpaque<T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        if let Some(ptr) = &self.ptr {
            ptr.as_ref()
        } else {
            panic!("Use after free.")
        }
    }
}

impl<T: ?Sized + DartSafe> From<Arc<T>> for RustOpaque<T> {
    fn from(ptr: Arc<T>) -> Self {
        Self { ptr: Some(ptr) }
    }
}

impl<T: DartSafe> RustOpaque<T> {
    pub fn new(value: T) -> Self {
        Self {
            ptr: Some(Arc::new(value)),
        }
    }
}

impl<T: DartSafe> From<RustOpaque<T>> for DartAbi {
    fn from(value: RustOpaque<T>) -> Self {
        let ptr = if let Some(ptr) = value.ptr {
            Arc::into_raw(ptr)
        } else {
            std::ptr::null()
        };
        let size = mem::size_of::<T>();

        vec![ptr.into_dart(), size.into_dart()].into_dart()
    }
}

#[derive(Debug)]
pub struct DartOpaque {
    /// Dart object
    handle: Option<DartOpaqueBase>,

    /// The ID of the thread on which the Dart Object was created.
    thread_id: ThreadId,
}

/// # Safety
///
/// The implementation checks the current thread
/// and delegates it to the Dart thread when it is drops.
unsafe impl Send for DartOpaque {}
unsafe impl Sync for DartOpaque {}

impl DartOpaque {
    /// Creates a new [DartOpaque].
    ///
    /// # Safety
    ///
    /// The [DartObject] must be created on the current thread.
    pub unsafe fn new(handle: DartObject, port: OpaqueMessagePort) -> Self {
        Self {
            handle: Some(DartOpaqueBase::new(handle, Some(port))),
            thread_id: std::thread::current().id(),
        }
    }

    /// Creates a [DartOpaque] for sending to dart.
    ///
    /// # Safety
    ///
    /// The [DartObject] must be created on the current thread.
    ///
    /// The [DartOpaque] created by this method must not be dropped
    /// on a non-parent [DartObject] thread.
    pub unsafe fn new_non_droppable(handle: DartObject) -> Self {
        Self {
            handle: Some(DartOpaqueBase::new(handle, None)),
            thread_id: std::thread::current().id(),
        }
    }

    /// Tries to get a Dart [DartObject].
    /// Returns the [DartObject] if the [DartOpaque] was created on the current thread.
    pub fn try_unwrap(mut self) -> Result<DartWrapObject, Self> {
        if std::thread::current().id() == self.thread_id {
            Ok(self.handle.take().unwrap().unwrap())
        } else {
            Err(self)
        }
    }
}

impl From<DartOpaque> for DartAbi {
    fn from(mut data: DartOpaque) -> Self {
        data.handle.take().unwrap().into_raw().into_dart()
    }
}

impl Drop for DartOpaque {
    fn drop(&mut self) {
        if let Some(inner) = self.handle.take() {
            if std::thread::current().id() != self.thread_id {
                if let Some(channel) = inner.channel() {
                    let ptr = inner.into_raw();

                    if !channel.post(ptr) {
                        println!("Drop DartOpaque after closing the port.");
                    };
                } else {
                    println!("Drop non droppable DartOpaque.");
                }
            }
        }
    }
}

/// Macro helper to instantiate an `RustOpaque<dyn Trait>`, as Rust does not
/// support custom DSTs on stable.
///
/// Example:
/// ```rust
/// use std::fmt::Debug;
/// use crate::*;
///
/// pub trait MyDebug: DartSafe + Debug {}
///
/// impl<T: DartSafe + Debug> MyDebug for T {}
///
/// let opaque: RustOpaque<Box<dyn MyDebug>> = opaque_dyn!("foobar");
/// ```
#[macro_export]
macro_rules! opaque_dyn {
    ($ex:expr) => {
        $crate::RustOpaque::new(::std::boxed::Box::new($ex))
    };
}
