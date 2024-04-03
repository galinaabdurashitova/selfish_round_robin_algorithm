# selfish_round_robin_algorithm
The script reads the processes data from a datafile and applies the Selfish Round-Robin scheduling algorithm to them. The output of the algorithm shows the statuses for all the processes for every timestamp.

Usage: ./srr.sh <filename> <a> <b> <q>
where <filename> - the name of a text file with processes
<a> - the increment integer value of new queue
<b> - the increment integer value of accepted queue
<q> - optional parameter, the quanta number

Additional comments:
There is a TEST_PRINT variable added, which allows to show an extended output
