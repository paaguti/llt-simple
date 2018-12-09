.DEFAULT_GOAL := run

TOP := ../..
OUTDIR := results

SRCS := $(wildcard *.cc *.h)

#
# 20 nodes, ramp with amount of nodes marking
#
run: clean-results $(SRCS) | $(OUTDIR)
	./run-test.bash $(TOP) $(OUTDIR) 20
	# tree $(OUTDIR)

#
# ramp from 1 to 20 marking nodes
#
ramp: clean-results $(SRCS) | $(OUTDIR)
	./run-ramp-test.bash $(TOP) $(OUTDIR)
	# tree $(OUTDIR)

check: clean-results $(SRCS) | $(OUTDIR)
	./run-check-test.bash $(TOP) $(OUTDIR)/check-03-05
	rm -rf $(OUTDIR)

$(OUTDIR): ; mkdir -p $@

clean:	clean-results
	rm -vf *~

clean-results:
	( cd $(TOP) && $(RM) *txt *pcap *sca )
	rm -rf $(OUTDIR)
