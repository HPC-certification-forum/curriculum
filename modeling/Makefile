defaultTarget:

SAXON := java -jar "./tools/saxon/saxon9he.jar"



####################################################################################################
# allTargets #######################################################################################
####################################################################################################
#
# Adding a file to the `allTargets` variable has two effects:
#   * The file is added to the default target, so that a simple `make` will build it.
#   * The file is added to the clean target, so that `make clean` will remove it.
#
# Included 'rules.mk' files are supposed to add their targets to this variable.
#
####################################################################################################

allTargets :=



####################################################################################################
# Rules to generate 'rules.mk' files, and their includes. ##########################################
####################################################################################################
#
# A rules.mk file is expected to:
#   * Define additional rules.
#   * Add the targets of these additional rules to the `allTargets` make variable.
#
####################################################################################################

curDir := .
loadRules = $(eval curDir := $(curDir)/$(1)) \
            $(eval include $(curDir)/rules.mk) \
            $(eval curDir := $(shell dirname $(curDir)))

$(call loadRules,skill-tree)
$(call loadRules,visualization)



####################################################################################################
# defaultTarget and clean targets ##################################################################
####################################################################################################
#
# Should be last to ensure that `allTargets` is complete at this point.
#
####################################################################################################

defaultTarget: $(allTargets)

clean:
	rm -f $(allTargets)
