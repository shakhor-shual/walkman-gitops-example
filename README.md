# walkman-gitops-example
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

Look for more details in Walkman documentation
