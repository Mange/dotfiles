command! -buffer -range=% FixRockets exec "<line1>,<line2>s/:\\([0-9a-z_]\\+\\) => /\\1: /g"

let b:splitjoin_trailing_comma = 0
