use std::net::{AddrParseError, Ipv6Addr};

use ipnet::Ipv6Net;
use thiserror::Error;

#[derive(Error, Debug, PartialEq)]
pub enum AddrMergeError {
    #[error(transparent)]
    AddrParseError(#[from] AddrParseError),
    #[error(transparent)]
    NetmaskParseError(#[from] ipnet::AddrParseError),
}

///
///
/// # Errors
///
/// if `address` or `prefix` is not a valid IPv6 address or prefix, an error is returned.
pub fn merge(address: &str, prefix: &str) -> Result<Ipv6Addr, AddrMergeError> {
    let address: Ipv6Addr = address.parse()?;
    let prefix: Ipv6Net = prefix.parse()?;

    // "remove"/zero-out the prefix by applying the hostmask
    let host_only = u128::from(address) & u128::from(prefix.hostmask());
    // now set the network-bits
    let merged = u128::from(prefix.network()) | host_only;

    Ok(Ipv6Addr::from(merged))
}

#[cfg(test)]
mod test {
    use crate::addresses::{merge, AddrMergeError};

    #[test]
    fn test_merge() {
        let sample_address = "2001:9e8:3771:d800:96c6:91ff:fea5:2dff";
        let sample_prefix = "2001:16b8:328e:ab00::/64";

        assert_eq!(
            merge(sample_address, sample_prefix),
            "2001:16b8:328e:ab00:96c6:91ff:fea5:2dff"
                .parse()
                .map_err(AddrMergeError::from)
        );
    }
}
