#!/bin/bash
#
# The script reads the processes data from a datafile and applies
# the Selfish Round-Robin scheduling algorithm to them. The output
# of the algorithm shows the statuses for all the processes for
# every timestamp.
#
# Usage: ./srr.sh <filename> <a> <b> <q>
# where <filename> - the name of a text file with processes
# <a> - the increment integer value of new queue
# <b> - the increment integer value of accepted queue
# <q> - optional parameter, the quanta number
#
# Author:   Galina Abdurashitova
# Date:     13/12/2023
# Version:  1.0
#
# Additional comments:
# There is a TEST_PRINT variable added, which allows to show an extended output
#

# >>>>>> Allows to show extended output, used for testing while coding <<<<<<
# >> TEST_PRINT=0 to have output as in the requirements of the coursework
# >> TEST_PRINT=1 to have extended output with showing the processes in the queues with all the parameters for each timestamp (does not work with writing to a file)
# >> TEST_PRINT = other - there will be no output
TEST_PRINT=0

# >>> 1. PARAMETER CHECKS <<<

echo "Completing positional parameters checks"

# 1.1) Check the number of parameters - it should be between 3 and 4
echo "Number of parameters entered: $#"
if [[ $# < 3 || $# > 4 ]]
then
    echo "ERROR! Wrong number of positional parameters"
    exit 0          # Display an error and exit the programme if not
fi

# 1.2) The data types of parameters - it should be a positive int number
# 1.2.1) Priority parameters
if [[ $2 =~ ^[0-9]+$ && $3 =~ ^[0-9]+$ ]]
then
    echo "Priority Increment in New_Queue = $2 and in Accepted_Queue = $3"
else
    echo "ERROR! Wrong priority increment"
    exit 0          # Display an error and exit the programme if 2nd and 3rd pos parameters are not positive int numbers
fi

# 1.2.2) Quanta number
if [[ $# = 4 && $4 =~ ^[0-9]+$ ]]
then
    echo "The Quanta number = $4"
elif [[ $# = 3 ]]   # If the 4th pos parameter (the quanta number) was not entered
then
    echo "The Quanta number is set by default = 1" # Set it by default
    set $1 $2 $3 1  # Quanta 4th pos parameter is set to 1
else
    echo "ERROR! Wrong Quanta number"
    exit 0          # Display an error and exit the programme if 4th pos parameter is not a positive int number
fi

# 1.2.3) Data file exists
if test -f $1       # Check if processes data file is a regular file
then
    echo "Data file entered"
else
    echo "ERROR! Wrong file"
    exit 0          # Display an error and exit the programme if not
fi

# 1.3) Data file contents

# >>>>> TO BE DONE <<<<<

# Display the success status for all checks completed
echo "Checks completed"
echo

# >>> 2. PREPARATIONS FOR THE ALGORITHM <<<
# 2.1) Read the data file to array of all processes and display the processes entered tabulated

# The block of code reads each line of datafile and adds them to a "all_processes" array
# The data of a process is stored as line in the array, every parameter is separated with a blank space, so that it is easier to convert a line to an array if needed
i=0
while read line
do
    # After a line with process name, NUT and AT a status and priority are added
    # 1) The status is set to "-" (not accepted) as the algorithm is not started yet
    # 2) The priority is set to 0 as the algorithm is not started yet
    all_processes[i]="$line - 0"
    (( i=i+1 ))
done < $1

# The block of code displays the process entered tabulated
echo "Entered processes:"
echo "Processes\tName\tNUT\tAT"             # Display headers for the processes table
echo "-----------------------------------"

i=1
while [ "$i" -le ${#all_processes[*]} ]     # For every element in an "all_processes" array
do
    process=(${all_processes[i-1]})         # For a one cycle of loop set "process" array for a single process from "all_processes" array
    echo "Process $i |\t\c"
    
    # Display the data for the process except for last 2 elements - the elements that were added as status and priority are not displayed
    j=2
    while [ "$j" -lt ${#process[*]} ]
    do
        echo " ${process[j-2]}\t\c"
        (( j=j+1 ))
    done
    echo
    
    (( i=i+1 ))
done

# 2.2) Ask a user about the preferred output option
echo
echo "Please enter the output option:"
echo "1 - output to standard output only"
echo "2 - output to a named text file"
echo "3 - output to both"

read -p "Enter output option: " output  # First read of the chosen option

while [[ !($output =~ ^[1-3]$) ]]       # If the option entered by a user does not exist
do
    echo "Wrong output option"          # Ask a user to enter an option again
    read -p "Enter output option again: " output
done                                    # The cycle will run until a user enters a proper option

# If the option entered by a user considers writing to a datafile - ask a user to enter a name for the file
if [[ $output =~ ^[23]$ ]]
then
    read -p "Enter the filename for output: " output_filename
fi
echo

# 2.3) Declaring variables for the algorithm
t=0                     # The number of a timeframe

# The queues store only numbers of processes in the array with all processes (all_processes) - so that to avoid possible mistakes with data inconsistency and to save some space not storing the same data twice
new_queue=()            # The array for the queue for numbers of newly arrived processes
accpt_queue=()          # The array for the queue for numbers of the accepted processes

finished_processes=0    # The number of finished processes - to stop the loop when all the processes are finished
q_counter=$4            # The quanta counter to understand if the quanta timeframe is finished or not

# >>> 3. SELFISH ROUND-ROBIN ALGORITHM <<<

echo "Starting the SRR algorithm"

# Output block - the headers
if [[ $TEST_PRINT = 0 ]]
then
    if [[ $output =~ ^[13]$ ]]              # If the output option considers output to the command line
    then
        echo "T\t\c"
        i=0
        while [ "$i" -lt ${#all_processes[*]} ] # For every process in the "all_processes" array
        do
            process=(${all_processes[i]})   # Split the process line to the array
            echo "${process[0]}\t\c"        # Take the first element (process name) and display it in the output
            (( i=i+1 ))
        done
    fi
    
    if [[ $output =~ ^[23]$ ]]              # If the output option considers output to the text file
    then
        echo "T\t\c" > $output_filename     # All output in the block goes to file named by user
        i=0
        while [ "$i" -lt ${#all_processes[*]} ] # For every process in the "all_processes" array
        do
            process=(${all_processes[i]})   # Split the process line to the array
            # Take the first element (process name) and display it in the output
            echo "${process[0]}\t\c" >> $output_filename
            (( i=i+1 ))
        done
    fi
fi

# Start the loop over time
while [ "$finished_processes" -lt ${#all_processes[*]} ]    # The loop runs while not all processes are finished
do

    # 3.1) Set the quanta counter again if the quanta timeframe is finished
    if test $q_counter -eq 0
    then
        q_counter=$4
    fi

    # 3.2) Check if there is a processes starting at T - if yes, add them to the queue
    i=0
    while [ "$i" -lt ${#all_processes[*]} ]     # The loop for all processes
    do
        process=(${all_processes[i]})           # Place a process line to an array
        if test ${process[2]} -eq $t            # If the process AT == T
        then
            process[3]="W"                      # Set this process status to "W" (waiting)
            all_processes[i]="${process[*]}"    # Write the process with new status to the array with all processes
            # Test if both queues are empty
            if test ${#new_queue[*]} -eq 0 -a ${#accpt_queue[*]} -eq 0
            then
                accpt_queue[0]=$i               # If yes - write the new process number right to the accepted queue
            else
                new_queue[${#new_queue[*]}]=$i  # If no - write the new process number to the end of the new queue
            fi
        fi
        
        (( i=i+1 ))
    done

    # 3.3) Check if the first process in the New queue has the priority greater or equal to the smallest priority of processes in the Accepted queue - if yes, add it to the accepted queue
    
    # First count the min priority in the accepted queue
    # Set the min priority as the priority of the last element in the accepted queue - it is sorted later in the cycle, so that the last process has the min priority
    last_process=${accpt_queue[${#accpt_queue[*]}]}
    min_accpt_priority=${all_processes[last_process]##*" "}
    
    # Then run the cycle - test if the new queue is not empty and the priority of the first element in the new queue is greater or equal to the min priority of the accepted queue
    while [ ${all_processes[new_queue[0]]##*" "} -ge $min_accpt_priority -a ${#new_queue[*]} -gt 0 ]
    do
        # If yes - add the first process from the new queue to the end of the accepted queue
        accpt_queue[${#accpt_queue[*]}]=${new_queue[0]}
        
        # Run a cycle over new queue starting from the second place to shift it
        i=1
        while [ "$i" -lt ${#new_queue[*]} ]
        do
            new_queue[i-1]=${new_queue[i]}  # Set every element in the queue to the previous one
            (( i=i+1 ))
        done
        
        unset new_queue[${#new_queue[*]}-1] # Unset the last element in the queue
    done

    # If the quanta counter == quanta, the algorithm:
    # - finishes running of the previously running process
    # - sort the accepted queue by the priorities
    # - run the first process in the accepted queue
    if test $q_counter -eq $4
    then
    
        # 3.4) Finish the previously run process
        # Check if the first process in the accepted queue was run previously - in other case there is nothing to finish
        if [[ "${running_process[3]}" = "R" ]]
        then
            # Place a process line to an array
            running_process=(${all_processes[accpt_queue[0]]})
            
            if [[ "${running_process[1]}" > 0 ]]    # If the process NUT is not finished
            then
                running_process[3]="W"              # Set the status to "W" (waiting)
                all_processes[${accpt_queue[0]}]=${running_process[*]}  # Save the process with the changed status
                
                pr=${accpt_queue[0]}                # Store the run process to the temp variable, while shifting
                
                # Then shift the accepted queue
                i=1
                while [ "$i" -lt ${#accpt_queue[*]} ]
                do
                    accpt_queue[i-1]=${accpt_queue[i]}  # Set every element in the queue to the previous one
                    (( i=i+1 ))
                done
                accpt_queue[$i-1]=$pr                   # Save the previously run process to the end of the queue
            else                                        # If the process NUT is finished
                running_process[3]="F"                  # Set the status to "W" (waiting)
                (( finished_processes=finished_processes+1 ))       # Add 1 to the counter of finished processes
                all_processes[accpt_queue[0]]=${running_process[*]} # Save the process with the changed status
                
                # Then shift the accepted queue
                i=1
                while [ "$i" -lt ${#accpt_queue[*]} ]
                do
                    accpt_queue[i-1]=${accpt_queue[i]}  # Set every element in the queue to the previous one
                    (( i=i+1 ))
                done
                unset accpt_queue[$i-1]                 # Unset the last element in the queue
            fi
        fi
        
        # 3.5) Sort the accepted queue by priorities - so that the process with the greatest priority will run next
        i=1
        while [[ $i < ${#accpt_queue[*]} ]]     # For every process in the accepted queue except the first (№0)
        do
            j=1
            while [[ $j+$i < ${#accpt_queue[*]} ]]  # For every process in the accepted queue except the first (№0) and except the one ($i) that has already been sorted
            do
                # If the previous process's priority is less than the priority of the selected process
                if test ${all_processes[accpt_queue[j-1]]##*" "} -lt ${all_processes[accpt_queue[j]]##*" "}
                then
                    temp=${accpt_queue[j-1]}    # Save the num of the previous process to the temp variable
                    accpt_queue[j-1]=${accpt_queue[j]}  # Save the num of the selected process instead of the previous one
                    accpt_queue[j]=$temp        # Save the num of the prev process stored in a temp var to the selected place in the queue
                fi
                (( j=j+1 ))
            done
            (( i=i+1 ))
        done

        # Check if the accepted queue is not empty after the previous steps - all the processes can be finished now, so we do not have to run another process
        if [[ ${#accpt_queue[*]} > 0 ]]
        then
            # 3.6) Start running the process - change the status of the first element in the Accepted queue to "R"
            running_process=(${all_processes[accpt_queue[0]]})  # Place a process line to an array
            running_process[3]="R"                              # Change its status to "R" (running)
                
            # 3.7) Check the q_counter
            if test ${running_process[1]} -lt $4                # Check if the process's NUT is less then the quanta N
            then
                # If yes - change the quanta counter to process's NUT, so that the timeframe will be shorter than quanta, because the running process will not take the whole time
                q_counter=${running_process[1]}
            fi
                
            all_processes[accpt_queue[0]]=${running_process[*]} # Save the new data for the running process
        fi
    fi

    # 3.8) Decrement NUT by 1
    # Check if the accepted queue is not empty after the previous steps - all the processes can be finished now, so we do not have to decrement NUT
    if [[ ${#accpt_queue[*]} > 0 ]]
    then
        running_process=(${all_processes[accpt_queue[0]]})  # Place a process line to an array
        (( running_process[1]=${running_process[1]}-1 ))    # Decrement process's NUT by 1
        all_processes[accpt_queue[0]]=${running_process[*]} # Save the new data for the running process
    fi
        
    # 3.9) Add priorities
    for process in ${new_queue[*]}          # For every process in a new queue
    do
        p=(${all_processes[process]})       # Place a process line to an array
        (( p[4]=p[4]+$2 ))                  # Add new queue priority value to the process's priority
        all_processes["$process"]=${p[*]}   # Save the new data for the process
    done
        
    for process in ${accpt_queue[*]}        # For every process in a accepted queue
    do
        p=(${all_processes[process]})       # Place a process line to an array
        (( p[4]=p[4]+$3 ))                  # Add accepted queue priority value to the process's priority
        all_processes["$process"]=${p[*]}   # Save the new data for the process
    done
    
    # Output block - print the result at the end of each timestamp
    if [[ $TEST_PRINT = 1 ]]    # The TEST_PRINT variable with value of 1 is used for extended print used while coding
    then
        echo "Time stamp: $t"
        echo "New-queue\tAccpt-queue\tAll processes"
        i=0
        while [ "$i" -lt ${#all_processes[*]} ]
        do
            if [[ ${#new_queue[*]} > $i ]]
            then
                str_new="${all_processes[new_queue[i]]}"
            else
                str_new="\t"
            fi
            
            if [[ ${#accpt_queue[*]} > $i ]]
            then
                str_accpt="${all_processes[accpt_queue[i]]}"
            else
                str_accpt="\t"
            fi
            
            str_all="${all_processes[i]}"
            
            echo "$str_new\t$str_accpt\t$str_all"
            (( i=i+1 ))
        done
        echo "---------------------------------------------"
    elif [[ $TEST_PRINT = 0 ]]      # The TEST_PRINT variable with value of 0 is used for output required for the coursework
    then
        if [[ $output =~ ^[13]$ ]]  # If the output option considers output to the command line
        then
            echo    # Blank echo as the previous output line was with "\c" - the symbol that inhibits the line feed
            echo "$t\t\c"           # Print a timestamp
            i=0
            while [ "$i" -lt ${#all_processes[*]} ] # Loop for each process
            do
                process=(${all_processes[i]})       # Place a process line to an array
                echo "${process[3]}\t\c"            # Print a status of the process
                (( i=i+1 ))
            done
        fi
        
        if [[ $output =~ ^[23]$ ]]          # If the output option considers output to the text file
        then
            echo >> $output_filename        # Blank echo as the previous output line was with "\c" - the symbol that inhibits the line feed
            echo "$t\t\c" >> $output_filename       # Print a timestamp
            i=0
            while [ "$i" -lt ${#all_processes[*]} ] # Loop for each process
            do
                process=(${all_processes[i]})       # Place a process line to an array
                echo "${process[3]}\t\c" >> $output_filename     # Print a status of the process
                (( i=i+1 ))
            done
        fi
    fi
    
    (( t=t+1 ))                 # Add 1 to a timestamp at the end of the cycle
    (( q_counter=q_counter-1 )) # Decrement quanta counter by 1 at the end of the cycle
done

echo
echo "Algorithm completed"      # Print the status at the end of the algorithm
