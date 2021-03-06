task -ip -e PERF_COUNT_HW_CPU_CYCLES -e PERF_COUNT_HW_INSTRUCTIONS -e PERF_COUNT_HW_CACHE_REFERENCES -e PERF_COUNT_HW_CACHE_MISSES parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e PERF_COUNT_HW_BRANCH_INSTRUCTIONS -e PERF_COUNT_HW_BRANCH_MISSES -e PERF_COUNT_SW_CPU_CLOCK -e PERF_COUNT_SW_TASK_CLOCK parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e PERF_COUNT_SW_PAGE_FAULTS -e PERF_COUNT_SW_CONTEXT_SWITCHES -e PERF_COUNT_SW_CPU_MIGRATIONS -e PERF_COUNT_SW_PAGE_FAULTS_MIN parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e PERF_COUNT_SW_PAGE_FAULTS_MAJ -e PERF_COUNT_HW_CACHE_L1D -e PERF_COUNT_HW_CACHE_L1I -e PERF_COUNT_HW_CACHE_LL parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e PERF_COUNT_HW_CACHE_DTLB -e PERF_COUNT_HW_CACHE_ITLB -e PERF_COUNT_HW_CACHE_BPU -e DISPATCHED_FPU parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e CYCLES_NO_FPU_OPS_RETIRED -e DISPATCHED_FPU_OPS_FAST_FLAG -e RETIRED_SSE_OPERATIONS -e RETIRED_MOVE_OPS parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e RETIRED_SERIALIZING_OPS -e FP_SCHEDULER_CYCLES -e SEGMENT_REGISTER_LOADS -e PIPELINE_RESTART_DUE_TO_SELF_MODIFYING_CODE parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e PIPELINE_RESTART_DUE_TO_PROBE_HIT -e LS_BUFFER_2_FULL_CYCLES -e LOCKED_OPS -e RETIRED_CLFLUSH_INSTRUCTIONS parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e RETIRED_CPUID_INSTRUCTIONS -e CANCELLED_STORE_TO_LOAD_FORWARD_OPERATIONS -e SMIS_RECEIVED -e DATA_CACHE_ACCESSES parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e DATA_CACHE_MISSES -e DATA_CACHE_REFILLS -e DATA_CACHE_REFILLS_FROM_SYSTEM -e DATA_CACHE_LINES_EVICTED parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e L1_DTLB_MISS_AND_L2_DTLB_HIT -e L1_DTLB_AND_L2_DTLB_MISS -e MISALIGNED_ACCESSES -e MICROARCHITECTURAL_LATE_CANCEL_OF_AN_ACCESS parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e MICROARCHITECTURAL_EARLY_CANCEL_OF_AN_ACCESS -e SCRUBBER_SINGLE_BIT_ECC_ERRORS -e PREFETCH_INSTRUCTIONS_DISPATCHED -e DCACHE_MISSES_BY_LOCKED_INSTRUCTIONS parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e L1_DTLB_HIT -e INEFFECTIVE_SW_PREFETCHES -e GLOBAL_TLB_FLUSHES -e MEMORY_REQUESTS parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e DATA_PREFETCHES -e SYSTEM_READ_RESPONSES -e QUADWORDS_WRITTEN_TO_SYSTEM -e CPU_CLK_UNHALTED parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e REQUESTS_TO_L2 -e L2_CACHE_MISS -e L2_FILL_WRITEBACK -e INSTRUCTION_CACHE_FETCHES parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e INSTRUCTION_CACHE_MISSES -e INSTRUCTION_CACHE_REFILLS_FROM_L2 -e INSTRUCTION_CACHE_REFILLS_FROM_SYSTEM -e L1_ITLB_MISS_AND_L2_ITLB_HIT parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e L1_ITLB_MISS_AND_L2_ITLB_MISS -e PIPELINE_RESTART_DUE_TO_INSTRUCTION_STREAM_PROBE -e INSTRUCTION_FETCH_STALL -e RETURN_STACK_HITS parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e RETURN_STACK_OVERFLOWS -e INSTRUCTION_CACHE_VICTIMS -e INSTRUCTION_CACHE_LINES_INVALIDATED -e ITLB_RELOADS parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e ITLB_RELOADS_ABORTED -e RETIRED_INSTRUCTIONS -e RETIRED_UOPS -e RETIRED_BRANCH_INSTRUCTIONS parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e RETIRED_MISPREDICTED_BRANCH_INSTRUCTIONS -e RETIRED_TAKEN_BRANCH_INSTRUCTIONS -e RETIRED_TAKEN_BRANCH_INSTRUCTIONS_MISPREDICTED -e RETIRED_FAR_CONTROL_TRANSFERS parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e RETIRED_BRANCH_RESYNCS -e RETIRED_NEAR_RETURNS -e RETIRED_NEAR_RETURNS_MISPREDICTED -e RETIRED_INDIRECT_BRANCHES_MISPREDICTED parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e RETIRED_MMX_AND_FP_INSTRUCTIONS -e RETIRED_FASTPATH_DOUBLE_OP_INSTRUCTIONS -e INTERRUPTS_MASKED_CYCLES -e INTERRUPTS_MASKED_CYCLES_WITH_INTERRUPT_PENDING parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e INTERRUPTS_TAKEN -e DECODER_EMPTY -e DISPATCH_STALLS -e DISPATCH_STALL_FOR_BRANCH_ABORT parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e DISPATCH_STALL_FOR_SERIALIZATION -e DISPATCH_STALL_FOR_SEGMENT_LOAD -e DISPATCH_STALL_FOR_REORDER_BUFFER_FULL -e DISPATCH_STALL_FOR_RESERVATION_STATION_FULL parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e DISPATCH_STALL_FOR_FPU_FULL -e DISPATCH_STALL_FOR_LS_FULL -e DISPATCH_STALL_WAITING_FOR_ALL_QUIET -e DISPATCH_STALL_FOR_FAR_TRANSFER_OR_RSYNC parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e FPU_EXCEPTIONS -e DR0_BREAKPOINT_MATCHES -e DR1_BREAKPOINT_MATCHES -e DR2_BREAKPOINT_MATCHES parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e DR3_BREAKPOINT_MATCHES -e DRAM_ACCESSES_PAGE -e MEMORY_CONTROLLER_PAGE_TABLE_OVERFLOWS -e MEMORY_CONTROLLER_SLOT_MISSES parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e MEMORY_CONTROLLER_TURNAROUNDS -e MEMORY_CONTROLLER_BYPASS -e THERMAL_STATUS_AND_ECC_ERRORS -e CPU_IO_REQUESTS_TO_MEMORY_IO parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e CACHE_BLOCK -e SIZED_COMMANDS -e PROBE -e GART parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e MEMORY_CONTROLLER_REQUESTS -e CPU_TO_DRAM_REQUESTS_TO_TARGET_NODE -e IO_TO_DRAM_REQUESTS_TO_TARGET_NODE -e CPU_READ_COMMAND_LATENCY_TO_TARGET_NODE_0_3 parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e CPU_READ_COMMAND_REQUESTS_TO_TARGET_NODE_0_3 -e CPU_READ_COMMAND_LATENCY_TO_TARGET_NODE_4_7 -e CPU_READ_COMMAND_REQUESTS_TO_TARGET_NODE_4_7 -e CPU_COMMAND_LATENCY_TO_TARGET_NODE_0_3_4_7 parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e CPU_REQUESTS_TO_TARGET_NODE_0_3_4_7 -e HYPERTRANSPORT_LINK0 -e HYPERTRANSPORT_LINK1 -e HYPERTRANSPORT_LINK2 parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e HYPERTRANSPORT_LINK3 -e READ_REQUEST_TO_L3_CACHE -e L3_CACHE_MISSES -e L3_FILLS_CAUSED_BY_L2_EVICTIONS parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e L3_EVICTIONS -e PAGE_SIZE_MISMATCHES -e RETIRED_X87_OPS -e IBS_OPS_TAGGED parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
task -ip -e LFENCE_INST_RETIRED -e SFENCE_INST_RETIRED -e MFENCE_INST_RETIRED parsecmgmt -a run -p ferret -c gcc-serial -i simlarge >> output/ferret.txt
#this is where I will call the pfm_data_parser 
perl pfm_data_parser.pl -f output/ferret.txt -o output/ferret.csv
