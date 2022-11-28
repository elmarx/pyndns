use ipnet::Ipv6Net;
use lazy_static::lazy_static;
use std::net::Ipv6Addr;

pub struct Host {
    pub name: String,
    pub ii: Ipv6Addr,
}

impl Host {
    pub fn new<S: Into<String>>(name: S, ii: Ipv6Addr) -> Self {
        Host {
            name: name.into(),
            ii,
        }
    }

    fn addr(&self, net: &Ipv6Net) -> Ipv6Addr {
        let net = u128::from(net.network()) | u128::from(self.ii);

        net.into()
    }

    pub fn quad_a(&self, net: &Ipv6Net) -> String {
        format!("{} IN AAAA {}", self.name, self.addr(net))
    }
}

lazy_static! {
    pub static ref HOSTS: Vec<Host> = vec![
        Host::new("pikvm", "::dea6:32ff:fe5a:b84".parse().unwrap()),
        Host::new("eric", "::5eba:2cff:fe22:c642".parse().unwrap()),
        Host::new("mackey", "::dea6:32ff:feea:1a1f".parse().unwrap()),
        Host::new("mooncake", "::ba27:ebff:feb0:b582".parse().unwrap()),
        Host::new("terrance", "::96c6:91ff:fea5:2dff".parse().unwrap()),
        Host::new("phillip", "::96c6:91ff:fea5:326d".parse().unwrap()),
    ];
}
