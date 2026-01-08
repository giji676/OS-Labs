#include <stdio.h>
#include <stdlib.h>


// Round-Robin time quantum
#define RR_QUANTUM 3

// Represents a process in the simulation
struct process
{
    int ID;               // Process ID
    int arrival;          // Time step when the process arrived
    int remaining;        // Remaining time required to finish
    struct process *next; 
};

// Represents a completed process (used for stats calculation)
struct process_done
{
    int ID;               // Process ID
    int end_time;         // Time step when the process finished
    int burst_time;       // Total CPU time the process required
    int arrival;          // Original arrival time
    struct process_done *next;
};

// Simulates one CPU cycle for the currently running process.
// - Decrements 'remaining' time.
// - Logs the execution to the file.
// - Clears the running process if it finishes.
void execute(struct process **running_process, FILE *execution_log)
{
    // CPU Idle
    if (!(*running_process))
    {
        fprintf(execution_log, "\n");
        return;
    }

    // CPU Busy
    if ((*running_process)->remaining > 0)
    {
        ((*running_process)->remaining)--;
        fprintf(execution_log, "(%d, %d)\n", (*running_process)->ID, (*running_process)->arrival);
    }

    // Process Completion
    if ((*running_process)->remaining == 0)
    {
        free(*running_process);
        *running_process = NULL;
    }
}

// Compare two strings for equality
// Returns 1 if strings are identical, 0 otherwise
int compare(char *s1, char *s2)
{
    if (!s1 || !s2)
        return 0;

    int index = 0;

    while (s1[index] != '\0' && s2[index] != '\0')
    {
        if (s1[index] != s2[index])
        {
            return 0;
        }
        index++;
    }

    return (s1[index] == '\0' && s2[index] == '\0'); 
}

// Parse the next integer from the file, skipping non-digit characters.
// Stops reading at space or newline.
// Returns the integer value, 0 if no digits found, or -1 on EOF.
int read_integer(FILE *input)
{
    int value = 0;
    int cur_char;
    int int_read = 0;

    while (((cur_char = fgetc(input)) != EOF) &&
           (cur_char != '\n') && (cur_char != ' '))
    {
        if (cur_char <= '9' && cur_char >= '0') {
            value = value * 10 + cur_char - '0';
            int_read = 1;
        }
    }

    if (cur_char == EOF && !int_read) 
        return -1;

    return value;
}

// Select scheduling method based on command line arguments
int method_selector(int argc, char **argv)
{
    char *methods[3] = {"FCFS", "SJF", "RR"};
    int method = 0; 

    if (argc >= 3)
    {
        for (int i = 0; i < 3; i++)
        {
            if (compare(argv[2], methods[i]))
            {
                method = i;
                break;
            }
        }
    }
    return method;
}