#!/bin/bash

################################################################################
# EXTRA / HIDDEN-STYLE TEST SUITE - CPU SCHEDULER
################################################################################

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# ==============================================================================
# TEMPORARY ENVIRONMENT SETUP
# ==============================================================================
ORIG_DIR=$(pwd)
TEST_DIR=$(mktemp -d)

cleanup() {
    cd "$ORIG_DIR"
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# Copy all C source files and headers to the temp directory
cp "$ORIG_DIR"/*.c "$TEST_DIR/"
cp "$ORIG_DIR"/*.h "$TEST_DIR/" 2>/dev/null

# Enter the temp directory
cd "$TEST_DIR"

# ==============================================================================
echo "============================================================"
echo "        EXTRA EDGE-CASE TESTS (template_functions.c)"
echo "============================================================"

echo "Compiling your code..."
gcc -Wall -Werror -Wpedantic -o student_scheduler main.c 2> compile_errors.txt
if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    cat compile_errors.txt
    exit 1
fi
echo -e "${GREEN}✓${NC} Compilation successful!"
echo ""

PASS=0
FAIL=0
TOTAL=0

run_log_test() {
    TOTAL=$((TOTAL+1))
    local name="$1"
    local input="$2"
    local algo="$3"
    local expected="$4"

    echo -n "Test $TOTAL: $name ... "
    ./student_scheduler "$input" "$algo" > /dev/null 2>&1

    if diff -w output.txt "$expected" > /dev/null; then
        echo -e "${GREEN}PASS${NC}"
        PASS=$((PASS+1))
    else
        echo -e "${RED}FAIL${NC}"
        echo "Expected:"
        sed 's/^/  /' "$expected"
        echo "Got:"
        sed 's/^/  /' output.txt
        FAIL=$((FAIL+1))
    fi
}

run_stats_test() {
    TOTAL=$((TOTAL+1))
    local name="$1"
    local input="$2"
    local algo="$3"
    local expected="$4"

    echo -n "Test $TOTAL: $name ... "
    ./student_scheduler "$input" "$algo" > stats_out.txt 2>&1
    grep "n processes" stats_out.txt -A 3 > clean.txt

    if diff -w clean.txt "$expected" > /dev/null; then
        echo -e "${GREEN}PASS${NC}"
        PASS=$((PASS+1))
    else
        echo -e "${RED}FAIL${NC}"
        echo "Expected:"
        sed 's/^/  /' "$expected"
        echo "Got:"
        sed 's/^/  /' clean.txt
        FAIL=$((FAIL+1))
    fi

    rm -f stats_out.txt clean.txt
}

###############################################################################
# 1. EMPTY INPUT (no processes at all)
###############################################################################
cat > empty_in.txt << 'EOF'
EOF

cat > empty_stats.txt << 'EOF'
n processes: 0
average turnaround: 0.00
average wait: 0.00
cpu free time: 0
EOF

run_stats_test "Empty input (FCFS)" empty_in.txt FCFS empty_stats.txt

###############################################################################
# 2. ONLY IDLE TIME (newlines only)
###############################################################################
cat > idle_only_in.txt << 'EOF'






EOF

cat > idle_only_stats.txt << 'EOF'
n processes: 0
average turnaround: 0.00
average wait: 0.00
cpu free time: 6
EOF

run_stats_test "Idle-only input (SJF)" idle_only_in.txt SJF idle_only_stats.txt

###############################################################################
# 3. SINGLE PROCESS
###############################################################################
cat > single_proc_in.txt << 'EOF'
5
EOF

cat > single_proc_fcfs_exp.txt << 'EOF'
(1, 0)
(1, 0)
(1, 0)
(1, 0)
(1, 0)
EOF

run_log_test "Single process FCFS" single_proc_in.txt FCFS single_proc_fcfs_exp.txt

###############################################################################
# 4. SJF TIE-BREAKER (same burst, different arrival)
###############################################################################
cat > sjf_tie_in.txt << 'EOF'
3
3
3
EOF

cat > sjf_tie_exp.txt << 'EOF'
(1, 0)
(1, 0)
(1, 0)
(2, 1)
(2, 1)
(2, 1)
(3, 2)
(3, 2)
(3, 2)
EOF

run_log_test "SJF tie-breaking by arrival" sjf_tie_in.txt SJF sjf_tie_exp.txt

###############################################################################
# 5. RR EXACT QUANTUM (should NOT preempt)
###############################################################################
cat > rr_exact_q_in.txt << 'EOF'
3
EOF

cat > rr_exact_q_exp.txt << 'EOF'
(1, 0)
(1, 0)
(1, 0)
EOF

run_log_test "RR exact quantum" rr_exact_q_in.txt RR rr_exact_q_exp.txt

###############################################################################
# 6. RR MULTIPLE PREEMPTIONS
###############################################################################
cat > rr_multi_preempt_in.txt << 'EOF'
10
EOF

cat > rr_multi_preempt_exp.txt << 'EOF'
(1, 0)
(1, 0)
(1, 0)
(1, 0)
(1, 0)
(1, 0)
(1, 0)
(1, 0)
(1, 0)
(1, 0)
EOF

run_log_test "RR multiple preemptions" rr_multi_preempt_in.txt RR rr_multi_preempt_exp.txt

###############################################################################
# 7. NON-CONTIGUOUS EXECUTION (stats correctness)
###############################################################################
cat > stats_noncontig_in.txt << 'EOF'
4
2
EOF

cat > stats_noncontig_fcfs.txt << 'EOF'
n processes: 2
average turnaround: 4.50
average wait: 1.50
cpu free time: 0
EOF

run_stats_test "Stats non-contiguous execution" stats_noncontig_in.txt FCFS stats_noncontig_fcfs.txt

###############################################################################
# SUMMARY
###############################################################################
echo "============================================================"
echo "Extra Tests Passed: $PASS / $TOTAL"
echo "Extra Tests Failed: $FAIL / $TOTAL"

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ ALL EXTRA TESTS PASSED${NC}"
    exit 0
else
    echo -e "${RED}✗ SOME EXTRA TESTS FAILED${NC}"
    exit 1
fi
