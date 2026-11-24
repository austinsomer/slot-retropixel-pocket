//! Wi-Fi owned by the operating system (the RetroPixel Pocket's connman).
//!
//! Slot only reports what the system has joined; it never powers the radio, scans, or
//! changes networks, so SSH over Wi-Fi keeps working while Slot runs.

use std::process::Command;

use super::{Backend, Saved, Scanned, State, Status};

const IFACE: &str = "wlan0";

#[derive(Default)]
pub struct SystemWifi {
    last: Option<(State, Option<String>, Option<String>)>,
}

fn output(program: &str, args: &[&str]) -> Option<String> {
    let out = Command::new(program).args(args).output().ok()?;
    out.status
        .success()
        .then(|| String::from_utf8_lossy(&out.stdout).into_owned())
}

/// The IPv4 address in `ip -4 -o addr show <iface>` output.
pub fn ipv4(text: &str) -> Option<String> {
    let mut words = text.split_whitespace();
    words.find(|w| *w == "inet")?;
    let addr = words.next()?;
    Some(addr.split('/').next()?.to_string())
}

/// The SSID in `iw dev <iface> link` output.
pub fn ssid(text: &str) -> Option<String> {
    text.lines()
        .find_map(|l| l.trim().strip_prefix("SSID: "))
        .map(str::to_string)
}

impl Backend for SystemWifi {
    fn start(&mut self) -> bool {
        eprintln!("slot: wifi (system) held");
        true
    }
    fn stop(&mut self) {}
    fn block(&mut self) {}
    fn scan(&mut self) -> Vec<Scanned> {
        Vec::new()
    }
    /// The network connman has joined, as Slot's one saved network: Slot only holds Wi-Fi
    /// (and so reports it connected for Gamebit, art and link) when something is saved.
    fn saved(&mut self) -> Vec<Saved> {
        output("/usr/sbin/iw", &["dev", IFACE, "link"])
            .as_deref()
            .and_then(ssid)
            .map(|ssid| Saved {
                id: 0,
                ssid,
                auto_join: true,
            })
            .into_iter()
            .collect()
    }
    fn status(&mut self) -> Status {
        let ip = output("/sbin/ip", &["-4", "-o", "addr", "show", IFACE])
            .as_deref()
            .and_then(ipv4);
        let ssid = output("/usr/sbin/iw", &["dev", IFACE, "link"])
            .or_else(|| output("/usr/bin/iw", &["dev", IFACE, "link"]))
            .as_deref()
            .and_then(ssid);
        let state = match (&ip, &ssid) {
            (Some(_), _) => State::Completed,
            (None, Some(_)) => State::Handshake,
            (None, None) => State::Idle,
        };
        let seen = Some((state, ssid.clone(), ip.clone()));
        if seen != self.last {
            eprintln!("slot: wifi (system) {state:?} ssid {ssid:?} ip {ip:?}");
            self.last = seen;
        }
        Status { state, ssid, ip }
    }
    fn temp_disabled(&mut self, _id: u32) -> bool {
        false
    }
    fn add(&mut self, _ssid: &str, _password: &str, _hidden: bool) -> Option<u32> {
        None
    }
    fn connect(&mut self, _id: u32) {}
    fn finish_connect(&mut self) {}
    fn disconnect(&mut self) {}
    fn set_auto_join(&mut self, _id: u32, _on: bool) {}
    fn forget(&mut self, _id: u32) {}
}
