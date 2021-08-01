#[derive(Eq, PartialEq, Debug)]
pub struct Serial {
    year: i32,
    month: i32,
    day: i32,
    version: i32,
}

#[derive(Eq, PartialEq, Debug)]
pub struct SoaData {
    pub primary: String,
    pub mail: String,
    pub serial: Serial,
    pub refresh: i32,
    pub retry: i32,
    pub expire: i32,
    pub nttl: i32,
}

fn parse_soa(s: &str) -> SoaData {
    todo!()
}

#[cfg(test)]
mod test {
    use crate::soa::{parse_soa, Serial, SoaData};

    #[test]
    fn test_parse_soa_data() {
        let sample = "ns.inwx.de hostmaster.dyn.athmer.org 2021072902 3600 900 1209600 300";

        let expected = SoaData {
            primary: "ns.inwx.de".to_string(),
            mail: "hostmaster.dyn.athmer.org".to_string(),
            serial: Serial {
                year: 2021,
                month: 7,
                day: 29,
                version: 2,
            },
            refresh: 3600,
            retry: 900,
            expire: 1209600,
            nttl: 300,
        };

        let actual = parse_soa(sample);
        assert_eq!(actual, expected);
    }
}
