#!/usr/bin/env python

import struct
import perfmon
import random
import threading
from subprocess import PIPE, Popen
import sys
import os
import subprocess
import time
import signal

#BASE_PATH="/root/"
#SPEC_PATH=BASE_PATH+"/benchspec/CPU2006/"
BASE_PATH="/afs/cs.pitt.edu/usr0/vpetrucci/"
SPEC_PATH=BASE_PATH+"/disk1/cpu2006/benchspec/CPU2006/"
RUN_PATH="/run/run_base_ref_amd64-m64-gcc42-nn.0000/"
EXE_SUFIX="_base.amd64-m64-gcc42-nn"
cmd_list = {'soplex-ref.mps.ref': ('450.soplex/exe/soplex'+EXE_SUFIX +' -m3500 ref.mps', '450.soplex'+RUN_PATH),
            #'gamess-h2ocu2+.gradient.ref': ("416.gamess/exe/gamess"+EXE_SUFIX +'  < h2ocu2+.gradient.config', '416.gamess'+RUN_PATH),
            'milc-su3imp.in.ref': ('433.milc/exe/milc'+EXE_SUFIX +' < su3imp.in', '433.milc'+RUN_PATH),
            #'zeusmp-.ref':('434.zeusmp/exe/zeusmp'+EXE_SUFIX +' ', '434.zeusmp'+RUN_PATH),
            'astar-BigLakes2048.cfg.ref':('473.astar/exe/astar'+EXE_SUFIX +' BigLakes2048.cfg', '473.astar'+RUN_PATH),
            'calculix-hyperviscoplastic.ref':('454.calculix/exe/calculix'+EXE_SUFIX +' -i  hyperviscoplastic', '454.calculix'+RUN_PATH),
            'lbm-reference.dat.ref':('470.lbm/exe/lbm'+EXE_SUFIX +' 3000 reference.dat 0 0 100_100_130_ldc.of', '470.lbm'+RUN_PATH),
            'bwaves-.ref':('410.bwaves/exe/bwaves'+EXE_SUFIX +' ', '410.bwaves'+RUN_PATH),
            'gobmk-nngs.tst.ref':('445.gobmk/exe/gobmk'+EXE_SUFIX +' --quiet --mode gtp < nngs.tst', '445.gobmk'+RUN_PATH),
            'bzip2-input.source.ref':('401.bzip2/exe/bzip2'+EXE_SUFIX +' input.source 280', '401.bzip2'+RUN_PATH),
            'cactusADM-benchADM.ref':('436.cactusADM/exe/cactusADM'+EXE_SUFIX +' benchADM.par', '436.cactusADM'+RUN_PATH),
            'mcf-inp.in.ref':('429.mcf/exe/mcf'+EXE_SUFIX +' inp.in', '429.mcf'+RUN_PATH),
            'namd-.ref':('444.namd/exe/namd'+EXE_SUFIX +' --input namd.input --iterations 38 --output namd.out', '444.namd'+RUN_PATH),
            'GemsFDTD-ref.ref':('459.GemsFDTD/exe/GemsFDTD'+EXE_SUFIX +' > ref.log', '459.GemsFDTD'+RUN_PATH),
            'sjeng-.ref':('458.sjeng/exe/sjeng'+EXE_SUFIX +' ref.txt', '458.sjeng'+RUN_PATH),
            'tonto-.ref':('465.tonto/exe/tonto'+EXE_SUFIX +' > tonto.out', '465.tonto'+RUN_PATH)}

#cmd_list = {'astar-BigLakes2048.cfg.ref':('473.astar/exe/astar'+EXE_SUFIX +' BigLakes2048.cfg', '473.astar'+RUN_PATH)}
#perf_events=['RETIRED_INSTRUCTIONS','L3_CACHE_MISSES','RETIRED_MMX_AND_FP_INSTRUCTIONS','DATA_CACHE_LINES_EVICTED','RETURN_STACK_HITS','PIPELINE_RESTART_DUE_TO_INSTRUCTION_STREAM_PROBE','CPU_CLK_UNHALTED','CPU_READ_COMMAND_REQUESTS_TO_TARGET_NODE_0_3','PERF_COUNT_HW_CPU_CYCLES']
#all counters
perf_events=['DISPATCH_STALL_FOR_BRANCH_ABORT','CPU_READ_COMMAND_LATENCY_TO_TARGET_NODE_0_3','PIPELINE_RESTART_DUE_TO_INSTRUCTION_STREAM_PROBE','SEGMENT_REGISTER_LOADS','RETURN_STACK_OVERFLOWS','L3_CACHE_MISSES','DISPATCH_STALL_WAITING_FOR_ALL_QUIET','MEMORY_CONTROLLER_TURNAROUNDS','RETIRED_SSE_OPERATIONS','CPU_IO_REQUESTS_TO_MEMORY_IO','PERF_COUNT_SW_TASK_CLOCK','RETIRED_MMX_AND_FP_INSTRUCTIONS','CPU_CLK_UNHALTED','INTERRUPTS_MASKED_CYCLES_WITH_INTERRUPT_PENDING','INSTRUCTION_CACHE_MISSES','SMIS_RECEIVED','FP_SCHEDULER_CYCLES','CPU_READ_COMMAND_REQUESTS_TO_TARGET_NODE_0_3','CPU_READ_COMMAND_REQUESTS_TO_TARGET_NODE_4_7','RETIRED_CLFLUSH_INSTRUCTIONS','RETIRED_TAKEN_BRANCH_INSTRUCTIONS_MISPREDICTED','HYPERTRANSPORT_LINK3','DISPATCH_STALL_FOR_SERIALIZATION','DISPATCH_STALL_FOR_RESERVATION_STATION_FULL','INEFFECTIVE_SW_PREFETCHES','PERF_COUNT_HW_CACHE_MISSES','GLOBAL_TLB_FLUSHES','RETIRED_MOVE_OPS','DISPATCHED_FPU_OPS_FAST_FLAG','RETIRED_BRANCH_INSTRUCTIONS','MEMORY_REQUESTS','PERF_COUNT_HW_CPU_CYCLES','HYPERTRANSPORT_LINK1','L1_DTLB_MISS_AND_L2_DTLB_HIT','DATA_CACHE_LINES_EVICTED','MEMORY_CONTROLLER_PAGE_TABLE_OVERFLOWS','LOCKED_OPS','CPU_REQUESTS_TO_TARGET_NODE_0_3_4_7','L2_FILL_WRITEBACK','PERF_COUNT_HW_BRANCH_MISSES','INTERRUPTS_MASKED_CYCLES','INSTRUCTION_CACHE_LINES_INVALIDATED','DISPATCH_STALL_FOR_SEGMENT_LOAD','ITLB_RELOADS','GART','SIZED_COMMANDS','RETIRED_INSTRUCTIONS','HYPERTRANSPORT_LINK0','DR2_BREAKPOINT_MATCHES','RETIRED_X87_OPS','INSTRUCTION_CACHE_VICTIMS','DATA_CACHE_ACCESSES','DATA_PREFETCHES','CPU_COMMAND_LATENCY_TO_TARGET_NODE_0_3_4_7','DATA_CACHE_REFILLS_FROM_SYSTEM','PERF_COUNT_HW_CACHE_REFERENCES','PERF_COUNT_HW_BRANCH_INSTRUCTIONS','PIPELINE_RESTART_DUE_TO_SELF_MODIFYING_CODE','REQUESTS_TO_L2','RETIRED_TAKEN_BRANCH_INSTRUCTIONS','PERF_COUNT_SW_PAGE_FAULTS','RETIRED_BRANCH_RESYNCS','PREFETCH_INSTRUCTIONS_DISPATCHED','PERF_COUNT_HW_CACHE_ITLB','CANCELLED_STORE_TO_LOAD_FORWARD_OPERATIONS','LFENCE_INST_RETIRED','RETIRED_MISPREDICTED_BRANCH_INSTRUCTIONS','MEMORY_CONTROLLER_REQUESTS','RETIRED_SERIALIZING_OPS','PERF_COUNT_SW_PAGE_FAULTS_MIN','FPU_EXCEPTIONS','PERF_COUNT_SW_CPU_MIGRATIONS','RETIRED_FAR_CONTROL_TRANSFERS','LS_BUFFER_2_FULL_CYCLES','L2_CACHE_MISS','DISPATCHED_FPU','INTERRUPTS_TAKEN','PROBE','MFENCE_INST_RETIRED','L1_ITLB_MISS_AND_L2_ITLB_HIT','RETIRED_FASTPATH_DOUBLE_OP_INSTRUCTIONS','CYCLES_NO_FPU_OPS_RETIRED','IO_TO_DRAM_REQUESTS_TO_TARGET_NODE','DISPATCH_STALL_FOR_REORDER_BUFFER_FULL','PERF_COUNT_SW_PAGE_FAULTS_MAJ','MISALIGNED_ACCESSES','DECODER_EMPTY','L3_FILLS_CAUSED_BY_L2_EVICTIONS','PERF_COUNT_HW_CACHE_BPU','DISPATCH_STALL_FOR_FAR_TRANSFER_OR_RSYNC','RETIRED_NEAR_RETURNS','RETIRED_NEAR_RETURNS_MISPREDICTED','L3_EVICTIONS','PERF_COUNT_SW_CONTEXT_SWITCHES','MEMORY_CONTROLLER_SLOT_MISSES','INSTRUCTION_CACHE_FETCHES','DISPATCH_STALL_FOR_FPU_FULL','PERF_COUNT_HW_INSTRUCTIONS','L1_ITLB_MISS_AND_L2_ITLB_MISS','RETIRED_CPUID_INSTRUCTIONS','SFENCE_INST_RETIRED','HYPERTRANSPORT_LINK2','RETIRED_UOPS','CPU_READ_COMMAND_LATENCY_TO_TARGET_NODE_4_7','DR3_BREAKPOINT_MATCHES','INSTRUCTION_CACHE_REFILLS_FROM_SYSTEM','L1_DTLB_AND_L2_DTLB_MISS','THERMAL_STATUS_AND_ECC_ERRORS','PERF_COUNT_HW_CACHE_L1I','ITLB_RELOADS_ABORTED','DISPATCH_STALLS','PERF_COUNT_HW_CACHE_L1D','PERF_COUNT_SW_CPU_CLOCK','PAGE_SIZE_MISMATCHES','SCRUBBER_SINGLE_BIT_ECC_ERRORS','DATA_CACHE_MISSES','L1_DTLB_HIT','PERF_COUNT_HW_CACHE_LL','MICROARCHITECTURAL_LATE_CANCEL_OF_AN_ACCESS','CPU_TO_DRAM_REQUESTS_TO_TARGET_NODE','RETIRED_INDIRECT_BRANCHES_MISPREDICTED','IBS_OPS_TAGGED','MICROARCHITECTURAL_EARLY_CANCEL_OF_AN_ACCESS','CACHE_BLOCK','DR1_BREAKPOINT_MATCHES','MEMORY_CONTROLLER_BYPASS','READ_REQUEST_TO_L3_CACHE','QUADWORDS_WRITTEN_TO_SYSTEM','DCACHE_MISSES_BY_LOCKED_INSTRUCTIONS','PIPELINE_RESTART_DUE_TO_PROBE_HIT','INSTRUCTION_CACHE_REFILLS_FROM_L2','SYSTEM_READ_RESPONSES','INSTRUCTION_FETCH_STALL','PERF_COUNT_HW_CACHE_DTLB','DR0_BREAKPOINT_MATCHES','RETURN_STACK_HITS','DRAM_ACCESSES_PAGE','DATA_CACHE_REFILLS','DISPATCH_STALL_FOR_LS_FULL']

#perf_events=['RETIRED_MMX_AND_FP_INSTRUCTIONS','DATA_CACHE_LINES_EVICTED','RETURN_STACK_HITS','PIPELINE_RESTART_DUE_TO_INSTRUCTION_STREAM_PROBE','CPU_CLK_UNHALTED','CPU_READ_COMMAND_REQUESTS_TO_TARGET_NODE_0_3']

def which_core(pid):
    try:
        f = file(os.path.join('/proc', str(pid), 'stat'), 'rb')
        val = f.read()
        f.close()
    except IOError:
        return -1
    return int(val.split(' ')[-9])

def task_set(pid, core):
    os.system('/bin/taskset -pc '+str(core)+' ' +str(pid)+' >/dev/null')
    #schedutils.set_affinity(pid, [core])

def get_children(pid):
    return [int(i) for i in os.popen('ps -o pid --no-headers --ppid '+str(pid)).read().split('\n')[:-1]]

def find_task(ppid):
    c = get_children(ppid)
    if c == []:
        return ppid
    p = c[0]
    while c:
        c = get_children(p)
        if c:
            p = c[0]
    return p

def run_apps(apps):
    procs = []
    task_procs = []
    for a in apps:

        os.chdir(SPEC_PATH + cmd_list[a][1])
        cmd = SPEC_PATH + cmd_list[a][0]

        p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, preexec_fn=os.setsid)
        procs += [p]

        time.sleep(1)

        print 'task pid', find_task(p.pid)
        task_procs += [find_task(p.pid)]

    return procs, task_procs


for app in cmd_list.keys():

  print 'measuring', app

  # big
  map_file = open('alone-'+app+'-'+time.strftime("%Y-%m-%d-%H-%M-%S")+'-big.txt','a')

  procs, task_procs = run_apps([app])
  fpid = task_procs[0]
  print 'fpid', fpid
  task_set(fpid, 0)

  prev_count = [0 for e in range(len(perf_events))]
  mon = perfmon.PerThreadSession(int(fpid), perf_events)
  mon.start()
  
  time.sleep(0.2)

  for i in range(0, len(perf_events)):
    count = struct.unpack("L", mon.read(i))[0]
    prev_count[i] = count

  running = True
  
  #count inconsistant scalling events
  inconsist = 0;

  while running:
    time.sleep(0.1)
    mark = "";
    # read the counts
    vals = []
    for i in range(0, len(perf_events)):
        count = struct.unpack("L", mon.read(i))[0]
        if prev_count[i] > count:
            print '[', i,'] oops', prev_count[i],' >', count,'??'
            inconsist+=1;
            mark = "*";
        val = count - prev_count[i]
        prev_count[i] = count
#        print """\t%s\t%lu""" % (events[i], count),
        #print """\t%s\t%lu""" % (events[i], val),
        vals += [val]

    print >>map_file, "%s %d" % (mark, vals[0]),
    for i in range(1, len(perf_events)):
        print >>map_file, ",%d" % (vals[i]),
    print >>map_file, ''
    
    ret = procs[0].poll()
    if ret != None:
      print 'exiting', app, 'pid', task_procs[0]
      running = False
  
  print "inconsistancy count: " + str(inconsist);
  map_file.close()

  time.sleep(5)
