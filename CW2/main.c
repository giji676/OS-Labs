#include <stdio.h>
#include <stdlib.h>
#include "template_functions.c"

#define MAX_SIMULATION_TIME 1000
#define AVG_TURNAROUND_IDX 0
#define AVG_WAIT_IDX 1
#define CPU_FREE_IDX 2

int main(int argc, char **argv)
{
	if (argc < 2)
	{
		printf("Usage: ./scheduler INPUT_FILE FCFS|SJF|RR\n");
		return -1;
	}

	// Open input and output files
	FILE *input = fopen(argv[1], "r");
	FILE *execution_log = fopen("output.txt", "w");

	int method = method_selector(argc, argv);
	
	// Simulation state variables
	int time = 0;       // Current simulation time step
	int id = 1;         // Auto-incrementing process ID
	int burst = 0;      // Buffer for reading burst times from file
	
	// ready_list: Points to the list of processes in the READY state (waiting for CPU)
	// selected:   Points to the process currently in the RUNNING state (on the CPU)
	// preempted:  Temporary holding pointer for a process just preempted by RR (needs to return to READY)
	struct process *ready_list = NULL;
	struct process *selected = NULL;
	struct process *preempted = NULL;

	// MAIN SIMULATION LOOP
	// Continues while there is work to do (input remaining or processes in any state)
	while ((burst = read_integer(input)) != -1 || selected || ready_list || preempted)
	{
		// If a valid burst time (>0) is read, a new process arrives at this time step.
		if (burst > 0)
		{
			// New processes are inserted at the HEAD of the ready list.
			struct process *new_proc = malloc(sizeof(struct process));
			new_proc->ID = id;
			id++;
			new_proc->arrival = time;
			new_proc->remaining = burst;
			new_proc->next = ready_list;
			ready_list = new_proc;
		}

		// If the CPU is idle AND there are processes waiting to be scheduled:
		if (!selected && (ready_list || preempted))
		{
			// Call the appropriate scheduler function.
			if (method == 0)
				selectFCFS(&ready_list, &selected);
			if (method == 1)
				selectSJF(&ready_list, &selected);
			if (method == 2)
				selectRR(&ready_list, &selected, &preempted);
		}
		
		// Decrement remaining time of 'selected' and log to file.
		execute(&selected, execution_log); 
		
		time++;

		// Stop simulation if max simulation time reached
		if (time > MAX_SIMULATION_TIME)
		{
			// Cleanup memory before exit
			if (selected) free(selected);
			if (preempted) free(preempted);
			
			while (ready_list)
			{
				struct process *temp = ready_list;
				ready_list = ready_list->next;
				free(temp);
			}

			fclose(input);
			fclose(execution_log);
			printf("Max simulation time reached. Exiting...\n");
			return -1;
		}
	}

	// Cleanup file handles
	fclose(input);
	fclose(execution_log);


	// Re-open the log file in read mode to calculate metrics
	execution_log = fopen("output.txt", "r");
	float stats[3];
	int n_proc = compute_stats(execution_log, stats); 
	fclose(execution_log);

	// Output results to console
	printf("n processes: %d\n", n_proc);
	printf("average turnaround: %.2f\n", stats[AVG_TURNAROUND_IDX]);
	printf("average wait: %.2f\n", stats[AVG_WAIT_IDX]);
	printf("cpu free time: %d\n", (int) stats[CPU_FREE_IDX]);

	return 0;
}