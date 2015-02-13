command! -nargs=* Ack echo "Use :Ag, dummy!" | sleep 1 | :Ag <args>
command! -nargs=* AckFromSearch echo "Use :AgFromSearch, dummy!" | sleep 1 | :AgFromSearch <args>
