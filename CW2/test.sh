#!/bin/bash

################################################################################
# PUBLIC TEST SUITE - CPU SCHEDULER
################################################################################

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Check valgrind availability
VALGRIND_AVAILABLE=0
if command -v valgrind &> /dev/null; then
    VALGRIND_AVAILABLE=1
fi

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

echo "================================================================================"
echo "                    PUBLIC TEST SUITE - CPU SCHEDULER"
echo "================================================================================"
echo ""

echo "Compiling your code..."
gcc -Wall -Werror -Wpedantic -o student_scheduler main.c 2> compile_errors.txt

if [ $? -ne 0 ]; then
    echo "COMPILATION FAILED"
    cat compile_errors.txt
    exit 1
fi
echo -e "${GREEN}✓${NC} Compilation successful!"
echo ""

if [ $VALGRIND_AVAILABLE -eq 0 ]; then
    echo -e "${PURPLE}NOTICE: Valgrind not found. Memory tests will FAIL.${NC}"
    echo ""
fi

# ==============================================================================
# LOGIC TEST DATA
# ==============================================================================
cat > fcfs1_in.txt << 'EOF'
5
3
7

EOF
cat > fcfs1_exp.txt << 'EOF'
(1, 0)
(1, 0)
(1, 0)
(1, 0)
(1, 0)
(2, 1)
(2, 1)
(2, 1)
(3, 2)
(3, 2)
(3, 2)
(3, 2)
(3, 2)
(3, 2)
(3, 2)
EOF

cat > fcfs2_in.txt << 'EOF'
2



3



1
EOF

cat > fcfs2_exp.txt << 'EOF'
(1, 0)
(1, 0)


(2, 4)
(2, 4)
(2, 4)

(3, 8)
EOF

cat > sjf1_in.txt << 'EOF'
8
5
3
EOF

cat > sjf1_exp.txt << 'EOF'
(1, 0)
(1, 0)
(1, 0)
(1, 0)
(1, 0)
(1, 0)
(1, 0)
(1, 0)
(3, 2)
(3, 2)
(3, 2)
(2, 1)
(2, 1)
(2, 1)
(2, 1)
(2, 1)
EOF

cat > sjf2_in.txt << 'EOF'
2



4

1
EOF

cat > sjf2_exp.txt << 'EOF'
(1, 0)
(1, 0)


(2, 4)
(2, 4)
(2, 4)
(2, 4)
(3, 6)
EOF

cat > rr1_in.txt << 'EOF'
8
6
9
EOF

cat > rr1_exp.txt << 'EOF'
(1, 0)
(1, 0)
(1, 0)
(2, 1)
(2, 1)
(2, 1)
(3, 2)
(3, 2)
(3, 2)
(1, 0)
(1, 0)
(1, 0)
(2, 1)
(2, 1)
(2, 1)
(3, 2)
(3, 2)
(3, 2)
(1, 0)
(1, 0)
(3, 2)
(3, 2)
(3, 2)
EOF

cat > rr2_in.txt << 'EOF'
2



4

1
EOF

cat > rr2_exp.txt << 'EOF'
(1, 0)
(1, 0)


(2, 4)
(2, 4)
(2, 4)
(3, 6)
(2, 4)
EOF

# ==============================================================================
# STATISTICS TEST DATA
# ==============================================================================

cat > stats1_in.txt << 'EOF'
6
6
2
EOF

cat > stats1_fcfs_out.txt << 'EOF'
n processes: 3
average turnaround: 9.67
average wait: 5.00
cpu free time: 0
EOF

cat > stats1_sjf_out.txt << 'EOF'
n processes: 3
average turnaround: 8.33
average wait: 3.67
cpu free time: 0
EOF

cat > stats1_rr_out.txt << 'EOF'
n processes: 3
average turnaround: 10.00
average wait: 5.33
cpu free time: 0
EOF

cat > stats2_in.txt << 'EOF'


6
6
2













2
EOF

cat > stats2_fcfs_out.txt << 'EOF'
n processes: 4
average turnaround: 7.75
average wait: 3.75
cpu free time: 4
EOF

cat > stats2_sjf_out.txt << 'EOF'
n processes: 4
average turnaround: 6.75
average wait: 2.75
cpu free time: 4
EOF

cat > stats2_rr_out.txt << 'EOF'
n processes: 4
average turnaround: 8.00
average wait: 4.00
cpu free time: 4
EOF

echo -e "${GREEN}✓${NC} Test cases created"
echo ""

# ==============================================================================
# RUN TESTS
# ==============================================================================

TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

compare_logs() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    local desc="$1"
    local input_file="$2"
    local algorithm="$3"
    local expected_log="$4"
    
    echo -n "  Test ${TOTAL_TESTS}: ${desc} ... "
    ./student_scheduler "$input_file" "$algorithm" > /dev/null 2>&1
    
    if diff -w output.txt "$expected_log" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}FAIL${NC}"
        echo "      ----------------------------------------------------------------"
        echo "      INPUT FILE ($input_file):"
        sed 's/^/        /' "$input_file"
        echo ""
        echo "      EXPECTED LOG:"
        sed 's/^/        /' "$expected_log"
        echo ""
        echo "      YOUR LOG:"
        sed 's/^/        /' output.txt
        echo "      ----------------------------------------------------------------"
        echo ""
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

compare_stats() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    local desc="$1"
    local input_file="$2"
    local algorithm="$3"
    local expected_stats="$4"
    
    echo -n "  Test ${TOTAL_TESTS}: ${desc} ... "
    
    ./student_scheduler "$input_file" "$algorithm" > student_out.txt 2>&1
    grep "n processes" student_out.txt -A 3 > clean_student_stats.txt
    
    if diff -w clean_student_stats.txt "$expected_stats" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}FAIL${NC}"
        echo "      ----------------------------------------------------------------"
        echo "      EXPECTED STATS:"
        sed 's/^/        /' "$expected_stats"
        echo ""
        echo "      YOUR STATS:"
        sed 's/^/        /' clean_student_stats.txt
        echo "      ----------------------------------------------------------------"
        echo ""
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    rm -f student_out.txt clean_student_stats.txt
}

run_valgrind() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    local input="$1"
    local algo="$2"
    echo -n "  Test ${TOTAL_TESTS}: Memory Leaks ($algo) ... "

    if [ $VALGRIND_AVAILABLE -eq 0 ]; then
        echo -e "${PURPLE}FAIL (Valgrind not installed)${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return
    fi

    valgrind --leak-check=full --error-exitcode=1 --log-file=valgrind.log \
        ./student_scheduler "$input" "$algo" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# --- Execution ---

echo "FCFS LOGIC TESTS"
compare_logs "Sequential" "fcfs1_in.txt" "FCFS" "fcfs1_exp.txt"
compare_logs "Sparse" "fcfs2_in.txt" "FCFS" "fcfs2_exp.txt"
run_valgrind "fcfs1_in.txt" "FCFS"
echo ""

echo "SJF LOGIC TESTS"
compare_logs "Sequential" "sjf1_in.txt" "SJF" "sjf1_exp.txt"
compare_logs "Sparse" "sjf2_in.txt" "SJF" "sjf2_exp.txt"
run_valgrind "sjf1_in.txt" "SJF"
echo ""

echo "ROUND ROBIN LOGIC TESTS"
compare_logs "Sequential" "rr1_in.txt" "RR" "rr1_exp.txt"
compare_logs "Sparse" "rr2_in.txt" "RR" "rr2_exp.txt"
run_valgrind "rr1_in.txt" "RR"
echo ""

echo "COMPUTE_STATS TESTS (Dense Input)"
compare_stats "FCFS Stats" "stats1_in.txt" "FCFS" "stats1_fcfs_out.txt"
run_valgrind "stats1_in.txt" "FCFS"
compare_stats "SJF Stats"  "stats1_in.txt" "SJF"  "stats1_sjf_out.txt"
run_valgrind "stats1_in.txt" "SJF"
compare_stats "RR Stats"   "stats1_in.txt" "RR"   "stats1_rr_out.txt"
run_valgrind "stats1_in.txt" "RR"
echo ""

echo "COMPUTE_STATS TESTS (Sparse Input)"
compare_stats "FCFS Stats" "stats2_in.txt" "FCFS" "stats2_fcfs_out.txt"
compare_stats "SJF Stats"  "stats2_in.txt" "SJF"  "stats2_sjf_out.txt"
compare_stats "RR Stats"   "stats2_in.txt" "RR"   "stats2_rr_out.txt"
echo ""

# ==============================================================================
# SUMMARY
# ==============================================================================
echo "================================================================================"
echo "Tests Passed: $TESTS_PASSED / $TOTAL_TESTS"
echo "Tests Failed: $TESTS_FAILED / $TOTAL_TESTS"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓✓✓ ALL TESTS PASSED! ✓✓✓${NC}"
    exit 0
else
    echo -e "${RED}✗ SOME TESTS FAILED${NC}"
    exit 1
fi