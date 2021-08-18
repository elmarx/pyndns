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
        Host::new("al", "::ba27:ebff:fef9:5ff3".parse().unwrap()),
        Host::new("conduct", "::dea6:32ff:fe5a:b84".parse().unwrap()),
        Host::new("eric", "::3e4a:92ff:fe77:ad36".parse().unwrap()),
        Host::new("ike", "::225:4bff:febc:d2ac".parse().unwrap()),
        Host::new("mackey", "::dea6:32ff:feea:1a1f".parse().unwrap()),
        Host::new("mooncake", "::ba27:ebff:feb0:b582".parse().unwrap()),
    ];
}
