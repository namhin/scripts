# Makefile for working (compiling, running etc) with java program.
#
# Fill the "Mandatory" and "Optional" (if needed) section below and:
#    make compile
#    make run
#    make serial
#    make jar  (Without a manifest file)
#    make mjar (With    a manifest file)
#    make backup
#    make clean

######################################################################################
#----------
# Mandatory
#~~~~~~~~~~

# Java home directory. Example: /path/to/jdk/bin
java_bin=/usr/lib/jvm/java/bin
#java_bin=/usr/lib/jvm/java-1.5.0/bin

# Location of all source files (No trailing slash). Example: "." or "./src:./test" or "./src"
src_path=./src

# Location of main file (No trailing slash). Example: "." or "./test"
main_src_path=./src

# Path to the java file containing the 'main' (No trailing slash). Example: org/kaz/main
main_pkg=io

# Name (without extension) of the java file containing the 'main'. Example: MainClass
main_file_name=MainClass

# Location of generated class (No trailing slash). Example: "." or "./bin"
cp_out=./bin

# Location of the JavaDoc files (No trailing slash). Example: "./doc"
doc_path=./doc

#---------
# Optional
#~~~~~~~~~

# Arguments to the program. Example: arg1 arg2 arg3
args=

# Name of the jar file (including the extension). Example: foo.jar
out_jar=

# Path to the Manifest file. Example: mymanifest
manifest=

# Dependency JARs. Example: /path/to/dependency/*.jar
dep_jars=./dep/*.jar

#
#
######################################################################################

######################################################################################
# Define some special characters.
comma=,
empty=
space=$(empty) $(empty)
pwd=$(shell pwd)

######################################################################################
# Derive default value of the Optional variables.

# Output JAR file name (including the extension).

ifeq "$(out_jar)" ""
out_jar=$(shell basename $(pwd)).jar
$(warning Value of "out_jar" not found. "make jar" or "make mjar" will produce "$(out_jar)".)
endif

# Dependency JARs.
# $(cp_dep) will be empty or "/path/to/1.jar:/path/to/2.jar:...:"
cp_dep=
ifneq "$(dep_jars)" ""
#all_jars=$(shell ls $(dep_jars))
all_jars=$(wildcard $(dep_jars))
cp_dep1=$(foreach one_jar,$(all_jars),$(one_jar):)
cp_dep=$(subst :$(space),:,$(cp_dep1))
endif

# Java-Convention-Name of the class containing the main.
main_pkg_dot=$(subst /,.,$(main_pkg))
main_class=$(main_pkg_dot).$(main_file_name)

######################################################################################
# Verify necessary variables.

ifeq "$(java_bin)" ""
$(error Please specify the value of "java_bin")
endif

ifeq "$(main_pkg)" ""
$(error Please specify the value of "main_pkg")
endif

ifeq "$(main_file_name)" ""
$(error Please specify the value of "main_file_name")
endif

ifeq "$(cp_out)" ""
$(error Please specify the value of "cp_out")
endif

ifeq "$(src_path)" ""
$(error Please specify the value of "src_path")
endif

ifeq "$(main_src_path)" ""
$(error Please specify the value of "main_src_path")
endif

ifeq "$(manifest)" ""
$(warning Value of "manifest" not found. "make mjar" will not work.)
endif

ifeq "$(doc_path)" ""
$(warning Value of "doc_path" not found. "make doc" will not work.)
endif

######################################################################################
# Default target.
foo:
	@echo "Usage:"
	@echo "   make compile"
	@echo "   make run"
	@echo "   make serial"
	@echo "   make jar  (Without a manifest file)"
	@echo "   make mjar (With    a manifest file)"
	@echo "   make doc"
	@echo "   make backup"
	@echo "   make clean"

######################################################################################
# clean:
#    Remove the unnecessary backup files, classes etc.
#
clean:
# DANGEROUS: $(cp_out) can't be empty anyhow for cleaning.
ifneq "$(cp_out)" ""
	rm -rf $(cp_out)/*
endif
	for i in `echo "$(src_path)" | sed 's/:/ /g'`;\
	do \
		find $$i/ -name "*~" -exec rm -rf '{}' \;; \
	done

######################################################################################
# compile: depend
#    Depends on the target "depend"
#    Build the shell command for compiling the java source.
#
compile:
	if [ ! -d "$(cp_out)" ]; then \
		echo "Creating $(cp_out)"; \
		mkdir -p "$(cp_out)"; \
	fi
	@echo -n "   Compiling: "
ifneq "$(cp_dep)" ""
	$(java_bin)/javac -Xlint:all -d $(cp_out) -classpath $(cp_dep) -sourcepath $(src_path) $(main_src_path)/$(main_pkg)/$(main_file_name).java
else
	$(java_bin)/javac -Xlint:all -d $(cp_out) -sourcepath $(src_path) $(main_src_path)/$(main_pkg)/$(main_file_name).java
endif

######################################################################################
# run:
#    Build the shell command for running the java source.
#    We must "make compile" first before "make run".
#
# Why not "run: compile"?
#    Ans: After compiling the source, in practice we run the code for more times.
#         If all the time of running, compilation process is started, then we
#         will be bored for compile-time consumption.
#
run:
	@echo -n "   Running: "
	$(java_bin)/java -classpath $(cp_out):$(cp_dep) $(main_class) $(args)

######################################################################################
# serial:
#    Build the shell command for finding the serialized number of the classes of
#    the java source.
#    We must "make compile" first before "make serial".
#
# Why not "serial: compile"?
#    Ans: After compiling the source, in practice we see the serial for more times.
#         If all the time of seeing, compilation process is started, then we
#         will be bored for compile-time consumption.
#
serial:
	@echo -n "   Serializing: "
	$(java_bin)/serialver -classpath $(cp_out):$(cp_dep) -show $(main_class)

######################################################################################
# jar:
#    Create a JAR file from the generated class files.
#    This time no manifest file will be supplied.
jar: compile
	@echo -n "   Creating $(out_jar): "
	${java_bin}/jar cf $(out_jar) -C $(cp_out)/ .

######################################################################################
# mjar:
#    Create a JAR file from the generated class files.
#    This time manifest file will be supplied.
mjar: compile
ifneq "$(manifest)" ""
	@echo -n "   Creating $(out_jar): "
	${java_bin}/jar cfm $(out_jar) $(manifest) -C $(cp_out)/ .
endif

######################################################################################
# doc:
#    Create JavaDoc from all the packages.
doc:
ifneq "$(doc_path)" ""
	${java_bin}/javadoc -private -author -sourcepath $(main_src_path) -d $(doc_path) `find $(main_src_path) -type d -print | awk '{ sub("$(main_src_path)", ""); print $0}' | sed "s/^[\/]\+//g" | sed "s/\//./g"`
endif

######################################################################################
# backup:
#    Build a gzipped tar file of the source dir "src".
#    This is for backup purpose.
#
backup:
	@echo -n "   Backing: "
	for i in `echo "$(src_path)" | sed 's/:/ /g'`;\
	do \
		tar czf `basename $$i`-`date +%d-%b-%y_%H-%M-%S`.tgz $$i; \
	done

