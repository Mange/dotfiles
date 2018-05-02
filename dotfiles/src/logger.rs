extern crate log;
extern crate term;

use std::sync::Mutex;

use log::{set_boxed_logger, set_max_level, Level, LevelFilter, Log, Metadata, Record};
use self::term::{color, StderrTerminal};

pub struct Logger {
    stderr: Mutex<Box<StderrTerminal>>,
}

impl Logger {
    pub fn init() {
        let stderr = term::stderr().expect("Could not get stderr stream");
        let logger = Logger {
            stderr: Mutex::new(stderr),
        };
        set_boxed_logger(Box::new(logger)).expect("Could not initialize logger");
        set_max_level(LevelFilter::Info);
    }

    pub fn change_level(level: LevelFilter) {
        set_max_level(level);
    }
}

impl Log for Logger {
    fn enabled(&self, metadata: &Metadata) -> bool {
        metadata.level() <= log::max_level()
    }

    fn log(&self, record: &Record) {
        let level = record.level();
        if level <= log::max_level() {
            let color = color(level);

            let mut stderr = self.stderr.lock().expect("Stderr stream is poisoned");
            stderr.fg(color).expect("Failed to set fg color");
            write!(
                stderr,
                "{}",
                match level {
                    Level::Error => "Error: ",
                    Level::Warn => "Warning: ",
                    _ => "",
                }
            ).expect("Failed to write log prefix");
            write!(stderr, "{}\n", record.args()).expect("Failed to write log message");
            stderr.reset().expect("Failed to reset color");
        }
    }

    fn flush(&self) {
        let mut stderr = self.stderr.lock().expect("Stderr stream is poisoned");
        stderr.flush().ok();
    }
}

fn color(level: Level) -> color::Color {
    match level {
        Level::Error => color::RED,
        Level::Warn => color::YELLOW,
        _ => color::WHITE,
    }
}
