use ipnet::Ipv6Net;
use std::net::Ipv6Addr;

#[must_use]
pub fn merge(address: Ipv6Addr, prefix: Ipv6Net) -> Ipv6Addr {
    // "remove"/zero-out the prefix by applying the hostmask
    let host_only = u128::from(address) & u128::from(prefix.hostmask());
    // now set the network-bits
    let merged = u128::from(prefix.network()) | host_only;

    Ipv6Addr::from(merged)
}

#[cfg(test)]
mod test {
    use crate::addresses::merge;
    use std::net::Ipv6Addr;

    #[test]
    fn test_merge() {
        let sample_address = "2001:9e8:3771:d800:96c6:91ff:fea5:2dff".parse().unwrap();
        let sample_prefix = "2001:16b8:328e:ab00::/64".parse().unwrap();

        assert_eq!(
            merge(sample_address, sample_prefix),
            "2001:16b8:328e:ab00:96c6:91ff:fea5:2dff"
                .parse::<Ipv6Addr>()
                .unwrap()
        );
    }
}
