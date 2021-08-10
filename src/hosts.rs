use ipnet::Ipv6Net;
use lazy_static::lazy_static;

pub struct Host {
    pub name: String,
    pub ii: String,
}

impl Host {
    pub fn new<S: Into<String>>(name: S, ii: S) -> Self {
        Host {
            name: name.into(),
            ii: ii.into(),
        }
    }

    pub fn quad_a(&self, net: &Ipv6Net) -> String {
        format!("{} IN AAAA {}{}", self.name, net.network(), self.ii)
    }
}

lazy_static! {
    pub static ref HOSTS: Vec<Host> = vec![
        Host::new("al", "ba27:ebff:fef9:5ff3"),
        Host::new("conduct", "dea6:32ff:fe5a:b84"),
        Host::new("eric", "3e4a:92ff:fe77:ad36"),
        Host::new("ike", "225:4bff:febc:d2ac"),
        Host::new("mackey", "dea6:32ff:feea:1a1f"),
        Host::new("mooncake", "ba27:ebff:feb0:b582"),
    ];
}
