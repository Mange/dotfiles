extern crate glob;

use std::fmt;
use std::fs::File;
use std::io::Read;
use std::path::{Path, PathBuf};

use pest::iterators::{Pair, Pairs};
use pest::Parser;

use prelude::*;
use target::{Target, TargetBuilder};

#[derive(Debug)]
pub struct Manifest {
    entries: Vec<Entry>,
}

#[derive(Debug, PartialEq)]
pub enum Entry {
    Path(PathBuf, PathBuf, Option<String>),
    Glob(String, PathBuf, Option<String>),
}

impl Manifest {
    pub fn load(path: &Path) -> Result<Manifest, Error> {
        let contents = {
            let mut file = File::open(path).context("Could not open manifest file")?;
            let mut contents = String::new();
            file.read_to_string(&mut contents)?;
            contents
        };
        let base = path.parent().unwrap();
        Ok(Manifest::parse(&contents, base)
            .with_context(|_| format!("Failed to parse manifest file {}", path.display()))?)
    }

    pub fn parse(contents: &str, base: &Path) -> Result<Manifest, Error> {
        let pairs = ManifestParser::parse(Rule::manifest, &contents)
            // Format err as a string to fix lifetime issues; the error type returned needs to live
            // longer than the string inside this method. We don't do anything more fancy with it
            // than just displaying it anyway.
            .map_err(|e| format_err!("{}", e))?;

        let mut entries: Vec<Entry> = Vec::new();

        for pair in pairs {
            if pair.as_rule() == Rule::manifest {
                for entry in manifest(pair.into_inner())? {
                    entries.push(entry.normalize(base).context("Failed to normalize path")?);
                }
            }
        }

        Ok(Manifest { entries })
    }

    pub fn entries(&self) -> &Vec<Entry> {
        &self.entries
    }
}

pub enum TargetError {
    SourceNotFound,
    DestinationIsNotDirectory(PathBuf),
    InvalidGlob(String, self::glob::PatternError),
    GlobIterationError(self::glob::GlobError),
}

impl Entry {
    pub fn installable_targets(&self) -> Result<Vec<Target>, TargetError> {
        match self {
            Entry::Path(ref from, ref to, ref shell_callback) => {
                if from.exists() {
                    Ok(vec![new_file_target(from, to, shell_callback.clone())])
                } else {
                    Err(TargetError::SourceNotFound)
                }
            }
            Entry::Glob(ref glob_str, ref dest_dir, ref shell_callback) => {
                if dest_dir.exists() && dest_dir.metadata().map(|md| md.is_file()).unwrap_or(false)
                {
                    return Err(TargetError::DestinationIsNotDirectory(
                        dest_dir.to_path_buf(),
                    ));
                }

                self::glob::glob(&glob_str)
                    .map_err(|e| TargetError::InvalidGlob(glob_str.clone(), e))?
                    .map(|entry| match entry {
                        Ok(path) => Ok(new_dir_target(path, &dest_dir, shell_callback.clone())),
                        Err(err) => Err(TargetError::GlobIterationError(err)),
                    })
                    .collect()
            }
        }
    }

    fn normalize(self, base: &Path) -> Result<Self, Error> {
        Ok(match self {
            Entry::Path(from, to, callback) => Entry::Path(
                normalize_path(from, base, true)?,
                normalize_path(to, base, false)?,
                callback,
            ),
            Entry::Glob(pattern, dir, callback) => Entry::Glob(
                normalize_pattern(pattern, base)?,
                normalize_path(dir, base, false)?,
                callback,
            ),
        })
    }
}

impl fmt::Display for Entry {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Entry::Path(ref from, _, _) => write!(f, "path {}", from.display()),
            Entry::Glob(ref pattern, _, _) => write!(f, "glob {}", pattern),
        }
    }
}

fn normalize_pattern(pattern: String, base: &Path) -> Result<String, Error> {
    if Path::new(&pattern).is_absolute() {
        Ok(pattern)
    } else {
        base.to_str()
            .ok_or_else(|| format_err!("Could not represent base directory as UTF-8"))
            .map(|base_str| format!("{}/{}", base_str, pattern))
    }
}

fn normalize_path(path: PathBuf, base: &Path, canonicalize: bool) -> Result<PathBuf, Error> {
    let path = if path.is_absolute() {
        path
    } else {
        base.join(path)
    };

    if canonicalize && path.exists() {
        Ok(path.canonicalize()?)
    } else {
        Ok(path)
    }
}

#[derive(Parser)]
#[grammar = "manifest.pest"]
struct ManifestParser;

// To make sure that changing the pest file causes a recompilation
#[cfg(debug_assertions)]
const _GRAMMAR: &str = include_str!("manifest.pest");

fn manifest(pairs: Pairs<Rule>) -> Result<Vec<Entry>, Error> {
    pairs
        .map(|pair| match pair.as_rule() {
            Rule::glob_entry => glob_entry(pair.into_inner()),
            Rule::file_entry => file_entry(pair.into_inner()),
            _ => panic!(
                "Could not generate AST for pair {:?}:\n{:#?}",
                pair.as_rule(),
                pair
            ),
        })
        .collect()
}

fn glob_entry(mut pairs: Pairs<Rule>) -> Result<Entry, Error> {
    Ok(Entry::Glob(
        glob(pairs.next().unwrap())?,
        PathBuf::from(path(pairs.next().unwrap())?),
        shell_callback(pairs.next())?,
    ))
}

fn file_entry(mut pairs: Pairs<Rule>) -> Result<Entry, Error> {
    Ok(Entry::Path(
        PathBuf::from(path(pairs.next().unwrap())?),
        PathBuf::from(path(pairs.next().unwrap())?),
        shell_callback(pairs.next())?,
    ))
}

fn glob(pair: Pair<Rule>) -> Result<String, Error> {
    let mut pattern = String::new();

    for pair in pair.into_inner() {
        match pair.as_rule() {
            Rule::wildcard => pattern.push_str(pair.as_str()),
            Rule::path => pattern.push_str(&path(pair)?),
            other => {
                panic!("Got an {:?} rule: {:#?}", other, pair);
            }
        }
    }

    Ok(String::from(pattern.trim()))
}

fn path(pair: Pair<Rule>) -> Result<String, Error> {
    let mut path = String::new();

    for pair in pair.into_inner() {
        match pair.as_rule() {
            Rule::filename => path.push_str(pair.as_str()),
            Rule::env_var => path.push_str(&env_var(pair)?),
            other => {
                panic!("Got an {:?} rule: {:#?}", other, pair);
            }
        }
    }

    Ok(String::from(path.trim()))
}

fn env_var(pair: Pair<Rule>) -> Result<String, Error> {
    let env_var_name = pair.into_inner().next().unwrap().as_str();
    ::std::env::var(env_var_name)
        .with_context(|_| format_err!("Could not read environment variable {}", env_var_name))
        .map_err(Error::from)
}

fn shell_callback(pair: Option<Pair<Rule>>) -> Result<Option<String>, Error> {
    if let Some(pair) = pair {
        if let Some(inner) = pair.into_inner().next() {
            return Ok(Some(inner.as_str().trim().to_owned()));
        }
    }
    Ok(None)
}

fn new_file_target<P>(source_path: P, destination_path: P, shell_callback: Option<String>) -> Target
where
    P: Into<PathBuf>,
{
    let destination_path = destination_path.into();

    TargetBuilder::default()
        .source_path(source_path)
        .dest_path(destination_path)
        .shell_callback(shell_callback)
        .build()
        .unwrap()
}

fn new_dir_target(
    source_path: PathBuf,
    destination_parent: &Path,
    shell_callback: Option<String>,
) -> Target {
    let destination_path = destination_parent.join(source_path.file_name().unwrap());

    TargetBuilder::default()
        .source_path(source_path)
        .dest_path(destination_path)
        .shell_callback(shell_callback)
        .build()
        .unwrap()
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::env;

    #[test]
    fn it_parses_empty_manifest() {
        let manifest = Manifest::parse("", &PathBuf::from("/tmp")).unwrap();
        assert!(manifest.entries.is_empty());
    }

    #[test]
    fn it_parses_manifest_with_a_comment() {
        let manifest = Manifest::parse("# foo bar\n#baz qux", &PathBuf::from("/tmp")).unwrap();
        assert!(manifest.entries.is_empty());
    }

    #[test]
    fn it_parses_simple_filename() {
        let manifest = Manifest::parse("a = b", &PathBuf::from("/tmp")).unwrap();
        assert_eq!(
            manifest.entries,
            vec![Entry::Path(
                PathBuf::from("/tmp/a"),
                PathBuf::from("/tmp/b"),
                None,
            )]
        );
    }

    #[test]
    fn it_parses_multiple_filename() {
        let manifest = Manifest::parse("a = b\nc=d", &PathBuf::from("/tmp")).unwrap();
        assert_eq!(
            manifest.entries,
            vec![
                Entry::Path(PathBuf::from("/tmp/a"), PathBuf::from("/tmp/b"), None),
                Entry::Path(PathBuf::from("/tmp/c"), PathBuf::from("/tmp/d"), None),
            ]
        );
    }

    #[test]
    fn it_parses_filenames_with_paths() {
        let manifest = Manifest::parse("a/b/c = /x/y/z", &PathBuf::from("/tmp")).unwrap();
        assert_eq!(
            manifest.entries,
            vec![Entry::Path(
                PathBuf::from("/tmp/a/b/c"),
                PathBuf::from("/x/y/z"),
                None,
            )]
        );
    }

    #[test]
    fn it_parses_filenames_with_environment_variables() {
        env::set_var("DF_TEST_X1", "/foo");

        let manifest = Manifest::parse("a = $DF_TEST_X1/bar", &PathBuf::from("/tmp")).unwrap();

        assert_eq!(
            manifest.entries,
            vec![Entry::Path(
                PathBuf::from("/tmp/a"),
                PathBuf::from("/foo/bar"),
                None,
            )]
        );
    }

    #[test]
    fn it_parses_simple_globs() {
        let manifest = Manifest::parse("a -> b\nc* -> d", &PathBuf::from("/tmp")).unwrap();

        assert_eq!(
            manifest.entries,
            vec![
                Entry::Glob(String::from("/tmp/a"), PathBuf::from("/tmp/b"), None),
                Entry::Glob(String::from("/tmp/c*"), PathBuf::from("/tmp/d"), None),
            ]
        );
    }

    #[test]
    fn it_parses_globs_with_env() {
        env::set_var("DF_TEST_X2", "bar");

        let manifest = Manifest::parse(
            "foo/$DF_TEST_X2/* -> to/$DF_TEST_X2",
            &PathBuf::from("/tmp"),
        ).unwrap();

        assert_eq!(
            manifest.entries,
            vec![Entry::Glob(
                String::from("/tmp/foo/bar/*"),
                PathBuf::from("/tmp/to/bar"),
                None,
            )]
        );
    }

    #[test]
    fn it_parses_shell_instructions() {
        let manifest = Manifest::parse(
            "foo = bar | cat bar\nbar/* -> drinks | ls .",
            &PathBuf::from("/tmp"),
        ).unwrap();

        assert_eq!(
            manifest.entries,
            vec![
                Entry::Path(
                    PathBuf::from("/tmp/foo"),
                    PathBuf::from("/tmp/bar"),
                    Some(String::from("cat bar")),
                ),
                Entry::Glob(
                    String::from("/tmp/bar/*"),
                    PathBuf::from("/tmp/drinks"),
                    Some(String::from("ls .")),
                ),
            ]
        );
    }

    #[test]
    fn it_parses_shell_instructions_with_trailing_comment() {
        let manifest = Manifest::parse(
            "bar/* -> drinks | ls . # List all drinks in the bar after installing them!",
            &PathBuf::from("/tmp"),
        ).unwrap();

        assert_eq!(
            manifest.entries,
            vec![Entry::Glob(
                String::from("/tmp/bar/*"),
                PathBuf::from("/tmp/drinks"),
                Some(String::from("ls .")),
            )]
        );
    }
}
