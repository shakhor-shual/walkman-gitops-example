### walkman-gitops-example
This is just a test example of how the Walkman works.
The repository contains one IaC “album” (i.e., a set of actions for 
deploying and configuring a specific cloud infrastructure), consisting 
of stages of deployment of individual elements and stages of their 
configuration. The deployment tool is Terraform, an Ansible configuration
tool. Connecting individual stages to each other (that is, passing 
parameters between them) is done using configuration scripts with 
Shell-like syntax. These files have a reserved *.csh extension, which 
is convenient for comfortable working with them in ordinary text editors 
(for example, VS Code, nano, etc.). Because it provides syntax highlighting,
auto-formatting, etc. using standard Shell tools/components/plugins of 
these editors.
This album contains configuration scripts in 3 options/environments: 
(dev/test/prod; however, the names of the scripts and their number 
in the album can be anything). This example is designed to demonstrate 
the methodology for working with Walkman in Gitops style

### Description of the syntax of Walkman deployment scripts

- Deployment scripts must have the reserved extension *.sch

- The first line of the script should be a shebang like:
#!/usr/local/bin/cw4d

- The script allows the use of an arbitrary number of comments made 
according to the Unix Shell programming rules (i.e. starting with  
the # symbol)

-The main syntactic structure of the deployment script language is the
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


### Syntax extensions over basic Shell syntax 
To simplify the use of basic shell syntax when describing specific actions
 performed by deployment scripts, three additional entities have been 
introduced into them: directives, helpers, annotations.

### Directives
Directives are exclusively an element of the root partition and are 
intended for global control of Walkman operating modes. Directives 
looks like: name@@@ parameter-1 [parameter-2 ... parameter-N]. 
The valid syntax of a directive's set of parameters is specific for each 
type of directive, and is focused on the nature of the actions performed 
by the directive. A list of available directives and a description of the 
syntax of their parameters ([..] for optional parameters) is given below:

- debug@@@ level - this directive set the level of verbosity
for deployment script execution. Possible values of 'level' are digits 
in range 0..9. If this directive not present used 'level' 0 by default.  

- git@@@ url [^branch] [>path] - this directive clone/pull remote git 
repository from specified 'url' to specified local 'path' with checkout 
to specified  'branch' (or tag) as the first step of every script run.

git@@@ directive implies NESTED updates process i.e. UNTIL DEPLOYMENT 
SCRIPTS CONTAINING git@@@ DIRECTIVES ARE FOUND IN THE CLONED/UPDATED 
REPOSITORIES, THE PROCESS OF APPLYING ALL FOUND git@@@ DIRECTIVES WILL 
BE PERFORMED RECURSIVELY UNTIL A SYNCHRONOUS STATE IS ACHIEVED WITH ALL 
FOUND REMOTE REPOSITORIES 

git@@@ directive also implies a DELEGATED execution process, i.e. 
IF A DEPLOYMENT SCRIPT CONTAINS GIT DIRECTIVE(S) BUT DOES NOT HAVE 
EXECUTION SECTIONS, AFTER SYNC OF THE REPOSITORIES IS COMPLETED, IT WILL 
AUTOMATICALLY EXECUTE ALL FOUND DEPLOYMENT SCRIPTS WITH EXECUTION 
SECTIONS. ALL FOUND DELEGATED SCRIPTS WILL BE LAUNCHED USING THE EXECUTION 
OPTION THAT WAS SPECIFIED FOR THE DELEGATING SCRIPT

### Annotations and Helpers
An extension of this basic Shell-like syntax is the use of two additional
syntactic constructs in variable assignment operations: 
- annotations (they looks like @@name or ++name) 
- helpers (they looks like <<<name | value-1 ... | value-N )

### Annotations
 Annotations are a predefined  macro view of frequently used routine
operations, list of supported annotations are:- 

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
"LAST-INDEX-PRE-INCREMENT" mean: THE LAST SEPARATE GROUP OF DIGITS 
IN THE ALPHANUMERIC VALUE WILL BE PRE-INCREMENTED OR VALUE NOT BE 
CHANGED FOR IF NO ANY DIGITS (i.e. value-no-indexes->value-no-indexes,
node01->node02, group-eu2-host-09-master -> group-eu2-host-10-master,
192.168.10.199->192.168.10.200 etc). If the value of a variable with 
that name was not assigned earlier in the script, the behavior and 
restrictions are the same as for the previous annotations. 

- @@this - returns file-name of this script (without file extension)

- @@meta - returns path to Walkman-reserved .meta sub-folder for 
CURRENT executive section, OR path to project-level .meta for ROOT
section

- @@self/some_name - returns an output value with the name some_name 
obtained as a result of the stage's operation




