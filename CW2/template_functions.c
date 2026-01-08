#include "utils.c"
#include <stdlib.h>


// Scheduling: First Come First Served
// Parameters:
//   ready_list: pointer to the head of the ready list
//   selected: pointer to a pointer to the process selected to run
void selectFCFS(struct process **ready_list, struct process **selected) {
	// Instructions:
	// 1. Find the process in the ready list with the earliest arrival time. Recall that the ready list is sorted Newest (Head) -> Oldest (Tail).
    struct process *curr = *ready_list;
    struct process *prev = NULL;
    struct process *earliest = curr;
    struct process *earliest_prev = NULL;

    while (curr) {
        if (curr->arrival < earliest->arrival) {
            earliest = curr;
            earliest_prev = prev;
        }
        prev = curr;
        curr = curr->next;
    }

    // 2. Remove that process from the ready list.
    if (earliest_prev) {
        earliest_prev->next = earliest->next;
    } else {
        *ready_list = earliest->next;
    }
    
	// 3. Set *selected to point to that process.
    *selected = earliest;
}

// Scheduling: Shortest Job First
// Parameters:
//   ready_list: pointer to the head of the ready list
//   selected: pointer to a pointer to the process selected to run
void selectSJF(struct process **ready_list, struct process **selected) {
	// Instructions:
	// 1. Find the process in the ready list with the smallest burst time. If there are ties, select the one that arrived earliest (closest to the tail).
    struct process *curr = *ready_list;
    struct process *prev = NULL;
    struct process *smallest_burst = curr;
    struct process *smallest_burst_prev = NULL;

    while (curr) {
        if (curr->remaining < smallest_burst->remaining) {
            smallest_burst = curr;
            smallest_burst_prev = prev;
        } else if (curr->remaining == smallest_burst->remaining) {
            if (curr->arrival < smallest_burst->arrival) {
                smallest_burst = curr;
                smallest_burst_prev = prev;
            }
        }
        prev = curr;
        curr = curr->next;
    }

	// 2. Remove that process from the ready list.
    if (smallest_burst_prev) {
        smallest_burst_prev->next = smallest_burst->next;
    } else {
        *ready_list = smallest_burst->next;
    }
    
	// 3. Set *selected to point to that process.
    *selected = smallest_burst;
}  

// Scheduling: Round Robin
// Parameters:
//   ready_list: pointer to the head of the ready list
//   selected: pointer to a pointer to the process selected to run
//   preempted: pointer to a pointer to the just preempted process (waiting to be re-added)
//
// NOTE: The pointer in 'preempted' acts as temporary storage between function calls.
//       If a process exceeded its quantum in the previous call, it will be stored here
//       You need to added it back to the ready list before selecting the next process.
//
void selectRR(struct process **ready_list, struct process **selected, struct process **preempted) {
	// Instructions:
	// 1. If there is a preempted process, add it at the head of the ready list and clear the preempted pointer (set *preempted = NULL).
    if (*preempted) {
        (*preempted)->next = *ready_list;
        *ready_list = *preempted;
        *preempted = NULL;
    }
	// 2. Select the next process to run from the tail of the ready list (the one that arrived earliest).
    struct process *curr = *ready_list;
    struct process *prev = NULL;
    while (curr->next) {
        prev = curr;
        curr = curr->next;
    }
	// 3. Remove the selected process from the ready list 
    if (prev) {
        prev->next = NULL; // tail
    } else {
        *ready_list = NULL;
    }
	// 4. Set *selected to point to that process.
    *selected = curr;
	// 5. Check if the selected process needs to be preempted, that is, if its remaining time is greater than RR_QUANTUM. If so,
    if ((*selected)->remaining > RR_QUANTUM) {
        // a. Allocate a new process struct for the preempted continuation.
        struct process *preempted_cont = malloc(sizeof(struct process));
        // b. Copy the ID and arrival time from the selected process.
        // c. Set the new process's remaining time to: (selected's remaining - RR_QUANTUM).
        preempted_cont->ID = (*selected)->ID;
        preempted_cont->arrival = (*selected)->arrival;
        preempted_cont->remaining = (*selected)->remaining - RR_QUANTUM;
        // d. Cap the selected process's remaining time to RR_QUANTUM.
        (*selected)->remaining = RR_QUANTUM;
        // e. Store the new process in *preempted (it will be added to the ready list on the next call).
        *preempted = preempted_cont;
    }
}

// Compute statistics from the execution log file
// Parameters:
//   execution_log: FILE containing the execution log (opened for reading)
//   stats: array of size 3 for storing results
//          stats[0] = average turnaround time
//          stats[1] = average wait time
//          stats[2] = total CPU idle time
// Returns:
//   Number of processes completed
struct process_done *build_process_done_list(FILE *execution_log, int *idle_time);
int compute_stats(FILE *execution_log, float *stats) {
	// Instructions:
	// 1. Read through the execution log line by line
	// 2. Build a linked list of process_done structs to track completed processes:
	//    - For each line: if a process_done with this ID exists, update it; otherwise create one.
	//    - Each process_done node needs to store: the process ID, its arrival time, 
	//      the total number of time units it executed (burst_time), and when it completed (end_time).
    stats[0] = 0;
    stats[1] = 0;
    stats[2] = 0;

    int idle_time = 0;
    struct process_done *node = build_process_done_list(execution_log, &idle_time);

    int n_proc = 0;
    int total_tat = 0;
    int total_wt = 0;

    while (node) {
        int tat = node->end_time - node->arrival + 1; // + 1 because time starts at 0
        total_tat += tat;
        int wt = tat - node->burst_time;
        total_wt += wt;

        node = node->next;
        n_proc++;
    }
    if (n_proc > 0) {
        stats[0] = (float)total_tat / n_proc;
        stats[1] = (float)total_wt / n_proc;
        stats[2] = idle_time;
    }
	// 3. After reading the entire log, traverse the linked list to compute statistics
    // 4. Store results in the stats array and free all allocated memory for the linked list.
    // 5. Return the number of processes completed.

    // Hints:
    // You can use read_integer() from utils.c to parse the file (returns -1 on EOF):
    // - Call it twice to get ID and then arrival time.
    // - Empty lines (CPU idle) will give a return value of 0 on the first call.
	
	return n_proc;
}

struct process_done *build_process_done_list(FILE *execution_log, int *idle_time) {
    struct process_done *head = NULL;
    int time = 0;
    int pid;

    while (1) {
        int c = fgetc(execution_log);
        if (c == EOF) {
            break;
        }
        // empty line (idle cpu)
        if (c == '\n') {
            time++;
            (*idle_time)++;
            continue;
        }
        ungetc(c, execution_log);

        // non-empty line: read Process ID and arrival
        pid = read_integer(execution_log);
        if (pid == -1) {
            break;
        }

        int arrival = read_integer(execution_log);

        // find process in list
        struct process_done *temp = head;
        while (temp && temp->ID != pid) {
            temp = temp->next;
        }

        if (temp) {
            // process found with the same pid
            temp->burst_time++;
            temp->end_time = time;
        } else {
            // new process
            temp = malloc(sizeof(struct process_done));
            temp->ID = pid;
            temp->arrival = arrival;
            temp->burst_time = 1;
            temp->end_time = time;
            temp->next = head;
            head = temp;
        }

        time++;
    }
    return head;
}
