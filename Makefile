.DEFAULT_GOAL := run

TOP := ../..
OUTDIR := results

SRCS := $(wildcard *.cc *.h)

run: clean-results $(SRCS) | $(OUTDIR)
	./run-test.bash $(TOP) $(OUTDIR)
	# tree $(OUTDIR)

ramp: clean-results $(SRCS) | $(OUTDIR)
	./run-ramp-test.bash $(TOP) $(OUTDIR)# 5
	# tree $(OUTDIR)

$(OUTDIR): ; mkdir -p $@

clean:	clean-results
	rm -vf *~

clean-results:
	( cd $(TOP) && $(RM) *txt *pcap *sca )
	rm -rf $(OUTDIR)
