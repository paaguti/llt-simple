# -*- Mode:Makefile; indent-tabs-mode: t; tab-width: 4; -*-
.DEFAULT_GOAL := run

TOP := ../..
OUTDIR := results
RM := rm -vf

SRCS := $(wildcard *.cc *.h)

#
# 5 nodes, ramp with amount of nodes marking
#
run: clean-results $(SRCS) | $(OUTDIR)
	./run-test.bash $(TOP) $(OUTDIR) 10
	rm -rf $(OUTDIR)

#
# ramp BW with 10 nodes
#
ramp: clean-results $(SRCS) | $(OUTDIR)
	./run-ramp-test.bash $(TOP) $(OUTDIR) 10
	rm -rf $(OUTDIR)

check: clean-results $(SRCS) | $(OUTDIR)
	./run-check-test.bash $(TOP) $(OUTDIR)/check-03-05
	rm -rf $(OUTDIR)

$(OUTDIR): ; mkdir -p $@

clean:	clean-results
	rm -vf *~

clean-results:
	( cd $(TOP) && $(RM) *.{txt,pcap,sca} )
	rm -rf $(OUTDIR)
