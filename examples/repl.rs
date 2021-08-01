use dyndns::soa::SoaData;
use nom::bytes::complete::take_until;
use nom::character::complete::{alphanumeric1, anychar, space1};
use nom::combinator::rest;
use nom::error::{context, ErrorKind, VerboseError};
use nom::multi::many1;
use nom::sequence::terminated;
use nom::{separated_list1, take_until1, AsChar, IResult, InputTakeAtPosition};

type Res<T, U> = IResult<T, U, VerboseError<T>>;

fn myanychar1<T>(i: T) -> Res<T, T>
where
    T: InputTakeAtPosition,
    <T as InputTakeAtPosition>::Item: AsChar,
{
    i.split_at_position1_complete(
        |item| {
            let char_item = item.as_char();
            !(char_item == '.') && !(char_item == '-') && !char_item.is_alphanum()
        },
        ErrorKind::AlphaNumeric,
    )
}

fn primary(input: &str) -> Res<&str, &str> {
    context("primary", terminated(myanychar1, space1))(input)
}

fn main() {
    let sample = "ns.inwx.de hostmaster.dyn.athmer.org 2021072902 3600 900 1209600 300";

    dbg!(primary(sample));
}
