#!/usr/bin/env python
#
# Copyright (c) 2008 Google, Inc.
# Contributed by Arun Sharma <arun.sharma@google.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
# 
# Self monitoring example. Copied from self.c

import os
import optparse
import random
import errno
import struct
import perfmon
import sys
import time

def main(*args):
  pid = 0;
  ticks = 0;

  if len(args) <= 2:
    
    #get the pid of the process to monitor
    if len(args) == 2:
      try:
        pid = int(args[1]);
      except ValueError:
        print "Invalid PID, using this programs PID";
        pid = int(os.getpid());
    else:
      pid = int(os.getpid());
    


    parser = optparse.OptionParser()
    parser.add_option("-e", "--events", help="Events to use",
                      action="store", dest="events")
    parser.set_defaults(events="PERF_COUNT_HW_CPU_CYCLES,PERF_COUNT_HW_INSTRUCTIONS,INSTRUCTION_CACHE_MISSES,RETIRED_INSTRUCTIONS,PERF_COUNT_HW_CACHE_LL,DISPATCHED_FPU")
    (options, args) = parser.parse_args()

    if options.events:
      events = options.events.split(",")
    else:
      raise "You need to specify events to monitor"

    s = perfmon.PerThreadSession(pid, events)
    s.start()
      
    while ticks < 10:
      '''
      # code to be measured
      #
      # note that this is not identical to what examples/self.c does
      # thus counts will be different in the end
      for i in range(1, 1000000):
        random.random()
      '''

      # read the counts
      for i in range(0, len(events)):
        count = struct.unpack("L", s.read(i))[0]
        #print """%40s\t\t%s""" % (events[i], bin(count))
        print """%40s\t\t%ld""" % (events[i], count)
      
      print "-------------";
      time.sleep(1);
      ticks = ticks + 1;
    
    
    return 0;

if __name__ == '__main__':
  sys.exit(main(*sys.argv));
