# ------------------------------------------ PATHS
# PRJ_DIR := $(shell git rev-parse --show-toplevel)
PRJ_DIR	:= $(realpath .)

DIR_SCRIPTS 	:= $(PRJ_DIR)/scripts
DIR_SRC			:= ${PRJ_DIR}/src
DIR_UVC 		:= $(PRJ_DIR)/uvc
DIR_SEQUENCES	:= $(PRJ_DIR)/sequences
DIR_TESTS		:= $(PRJ_DIR)/tests
DIR_RESULTS_DUT	:= $(PRJ_DIR)/sim_dut
DIR_RESULTS_TB	:= $(PRJ_DIR)/bin

# ------------------------------------------ VARIABLES
SHELL 		:= bash

TIME		= 5000000
VERB		= UVM_HIGH
TEST		=
SEED		:= $$(date +%d-%m-%Y_%H:%M:%S)
FILE_NAME	= ${SEED}${TEST}

COMP_OPT	+= +define+VCS +define+RTL_SIM +define+RANDOMIZE_DELAY=2e0 +define+RANDOMIZE_MEM_INIT
COMP_OPT	+= +define+A +define+VPD +define+VCD
COMP_OPT	+= +libext+.v+.sv
COMP_OPT	+= -debug_acc+all -kdb -lca -vcd
COMP_OPT	+= -full64 -q -j20 -fgp
COMP_OPT	+= -timescale=1ns/100ps
COMP_OPT	+= -sverilog
COMP_OPT	+= -error=noMPD
COMP_OPT	+= -l compilation.log
COMP_OPT	+= -cm line+tgl+branch -cm_tgl portsonly
COMP_OPT	+= -ntb_opts uvm-1.2
COMP_OPT	+= '-LDFLAGS -Wl,--no-as-needed'
COMP_OPT	+= +vcs+initreg+random

SIM_OPT		+= -cm line+tgl+branch
SIM_OPT		+= -l simulation_${TEST}.log
SIM_OPT		+= +ntb_random_seed = ${SEED}
SIM_OPT		+= +vcs+initreg+0

TEST_LIST	= alu_arithmetic_add_test alu_arithmetic_div_test

# ------------------------------------------ TARGETS

compile:
	@ echo " "
	@ echo -------------------------- Compiling UVM Testbench -------------------------
	@ echo " "
	@ [[ -d ${DIR_RESULTS_TB} ]] || mkdir ${DIR_RESULTS_TB}
	@ cd ${DIR_RESULTS_TB} && vcs $(COMP_OPT) \
	+incdir+${DIR_UVC} +incdir+${DIR_SEQUENCES} +incdir+${DIR_TESTS} \
	${DIR_SRC}/*.sv \
	${DIR_UVC}/flist.sv ${DIR_UVC}/tb/tb_top.sv
	@ echo ------------------------------------ DONE ----------------------------------
	@ echo " "

sim:
	@ echo " "
	@ echo --------------------------- Running Test ${TEST} ---------------------------
	@ cd ${DIR_RESULTS_TB} && \
	$(DIR_RESULTS_TB)/simv $(SIM_OPT) \
	+UVM_TESTNAME=$(TEST) +UVM_TIMEOUT=$(TIME) +UVM_VERBOSITY=$(VERB)
	@ mkdir ${DIR_RESULTS_TB}/${TEST}
	@ mv ${DIR_RESULTS_TB}/*.log ${DIR_RESULTS_TB}/*.key \
	${DIR_RESULTS_TB}/*.vcd ${DIR_RESULTS_TB}/*.vpd \
	${DIR_RESULTS_TB}/simv* \
	${DIR_RESULTS_TB}/${TEST}
	@ echo "Bin folder: ${DIR_RESULTS_TB}/${TEST}"
	@ echo ------------------------------------ DONE ----------------------------------
	@ echo " "

runtest: compile sim

runall:
	@ echo " "
	@ echo ---------------------------- Running All Tests -----------------------------
	@ bash ${DIR_SCRIPTS}/sim_all.sh
	@ [[ -d ${DIR_RESULTS_TB}/${SEED} ]] || mkdir -p ${DIR_RESULTS_TB}/${SEED}
	@ mv -f ${DIR_RESULTS_TB}/alu_*_test ${DIR_RESULTS_TB}/${SEED}
	@ urg -dir ${DIR_RESULTS_TB}/${SEED}/alu_*_test/*.vdb \
	-report ${DIR_RESULTS_TB}/${SEED}/covrpt_alu_${SEED}
	@ echo " "
	@ echo ----------------------------------------------------------------------------
	@ echo --------------------------- REGRESSION COMPLETE ----------------------------
	@ echo " "
	@ echo "       coverage report: ${DIR_RESULTS_TB}/${SEED}/covrpt_alu_${SEED}      "
	@ echo ----------------------------------------------------------------------------
	@ echo ----------------------------------------------------------------------------
	@ echo " "

clean:
	@ echo " "
	@ echo ------------------------------ CLeaning dumps ------------------------------
	@ rm -rf simv.daidir test.daidir \
	simv test csrc verdiLog \
	verdi_config_file \
	${DIR_RESULTS_TB} \
	DVEfiles \
	*.fsdb *.vcd *.vpd *.log *.conf *.rc *.key
	@ echo ----------------------------------------------------------------------------
	@ echo " "