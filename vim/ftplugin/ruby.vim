setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

command! -buffer FixRockets exec "%s/:\\([0-9a-z_]\\+\\) => /\\1: /g"
