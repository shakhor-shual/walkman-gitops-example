# walkman-gitops-example
This is a simple Walkman project example showing how a Walkman works.
This project contains some test deployment for GCP  with inlined stages 
structure and deployment scripts for 3 options/environments: 
- dev (in file dev.csh)
- test (in file test.csh)
- prod (in file prod.csh)
This is an external resource for another Walkman example demonstrating 
its GitOps-style capabilities.

# For best example understanding (optional):
## Description of the syntax of Walkman deployment scripts
Deployment script connecting individual stages of project to each other 
(that is, passing parameters between them) in Shell-like syntax and style. 
They have a reserved *.csh extension, which is convenient for comfortable 
working with them in text editors (like VS Code, nano, etc.) with syntax 
highlighting, auto-formatting, etc. 

- The first line of each deployment script should be a shebang looks 
like: #!/usr/local/bin/cw4d

- The script allows the use of an arbitrary number of comments made 
according to the Unix Shell programming rules (i.e. starting with  
the '#' symbol)

- The main syntactic structure of the deployment script language is the
operation of assigning variables, performed according to basic rules 
and using the syntax of Unix shell string operations

- The body of the script consists of one root and (optionally) several 
execution sections

- The root section begins immediately after the shebang line and contains 
a directive area and (optionally) a variable assignment area

- Each executive section begins with a label of the form ~SOME_LABEL_NAME 
and contains only the variable assignment area; the use of directives 
in executive sections is not allowed 

- The absence of executive sections in the script is allowed only if 
this script loads (from any git repo) other deployment scripts which 
containing executive sections

- The number of execution sections in a deployment script (if it have 
execution sections) MUST BE EXACTLY EQUAL to the number of project 
stages (i.e. the number of sub-folders in project folder, which 
containing files of these stages)

- The names of variables in the executive sections MUST BE SAME(*) with 
the names of the variables used in the stage files (as example: for the 
executive section that controls the Terraform used stage, the naming 
for section variables must coincide with the variables names used in 
terraform.tfvars file of stage)

- (*): executive section can contain variables with arbitrary 
names if @@self annotation  was used to assign them. Such variables are 
considered stage return values and are not used by Walkman to initialize 
internal stage variables

- Variable values assigned in the execution section will be used by Walkman 
to set the values of internal stage variables (i.e. for Terraform stages 
this literally means that Walkman will generate a variable.tf file for 
the stage with the specified values)


## Used Extension of standard Shell syntax  
To extend usability of basic shell syntax for describing specific actions
performed by deployment scripts, next additional syntax entities have been 
added to them: 

### Directives
Directives are exclusively an element of the script root section and are 
intended for global control of Walkman operating modes. Directives 
looks like: 

name@@@ parameter-1 [parameter-2 ... parameter-N]. 

A list of available directives and a description of the syntax for their 
parameters ([.] for optional parameters) is given below:

- debug@@@ level - this directive set the level of verbosity
for deployment script execution. Possible values of 'level' are digits 
in range 0..9. If this directive not present used 'level' 0 by default.  

- git@@@ url [^branch] [>path] - this directive clone/pull remote git 
repository from specified 'url' to specified local 'path' with checkout 
to specified  'branch' (or tag) as the first step of every script run.

git-directive implies NESTED updates process i.e. until deployment 
scripts containing git-directives are found in the cloned/updated 
repositories, the process of applying all found git-directives will 
be performed recursively until a synchronous state is achieved with all 
found remote repositories 

git-directive also implies a DELEGATED execution process, i.e. 
if a deployment script contains git directive(s) but does not have 
execution sections, after sync of the repositories is completed, it will 
automatically execute all found deployment scripts with execution 
sections. all found delegated scripts will be launched using the execution 
option that was specified for the delegating script

### Annotations
Annotations (looks like: @@name OR ++name)  are a predefined  macro view of 
frequently used routine operations. They used in script root and execution 
sections for variables assignment operation. Supported annotations are: 

- @@ - skip this variable from  stage tuning process and try use for it 
in-stage internal default value. If the in stage used internal mechanisms 
for assigning default values, these values will be used, otherwise the 
result is undefined. Actually this annotation is a "syntax sugar", and 
this a same like exclude variable with this name from section. 

- @@last - returns the last value assigned by the script for a 
variable with the same name (like var=$var).  If the value of a 
variable with that name was not assigned earlier in the script, the 
behavior and restrictions are the same as for the previous annotation.
 
- ++last - returns "LAST-INDEX-PRE-INCREMENT" for last value 
assigned by the script for variable with the same name. 
"last-index-pre-increment" mean: the last separate group of digits 
in the alphanumeric value will be pre-incremented or value not be 
changed for if no any digits (i.e. value-no-indexes->value-no-indexes,
node01->node02, group-eu2-host-09-master -> group-eu2-host-10-master,
192.168.10.199->192.168.10.200 etc). If the value of a variable with 
that name was not assigned earlier in the script, the behavior and 
restrictions are the same as for the previous annotations. 

- @@this - returns file-name of this script (without file extension)

- @@meta - returns path to Walkman-reserved .meta sub-folder for 
CURRENT executive section, OR path to project-level .meta in root
section of script

- @@self/some_name - returns an output value with the name some_name 
obtained as a result of the stage's operation

###  Helpers
The helpers (look like this: <<<name | value-1 ... | value-N) actually 
are a syntactic wrapper for directly using the Walkman BASH-function 
in deployment scripts. The  "name" of helper in deployment script must 
be a name of an existing function in the Walkman (i.e., an internal 
function programmed in BASH which is part of the Walkman source code). 
The concept of helpers is intended for quick, problem-oriented expansion 
of the functionality of deployment scripts by adding new specialized BASH
functions to the Walkman source code with the possibility of their 
subsequent direct calling in deployment scripts. The Walkman architecture 
allows the helper to return a single string, the contents of which can 
be assigned to a deployment script variable (or ignored if the helper is 
called outside of a variable assignment operation). In the latter case, 
it is assumed that the purpose of calling the helper was to generate 
some artifacts in the file structure of the project. A more detailed 
description of this mechanism and a list of available helpers (with 
their parameters) is given in Walkman project bin/README.MD

