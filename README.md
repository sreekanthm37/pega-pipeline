# pega-pipeline
A Continuous Integration/Continuous Delivery pipeline is an automated process to quickly move applications from development through testing to deployment.

You can use Jenkins to automate exporting and importing Pega 7 Platform applications. Download prpcServiceUtils tool provided by Pega to perform both export and import of Pega RAP files.

Requirements
------------

Ensure that your system includes the following items:

Jenkins 1.651.1 or later
Jenkins Plugins:
  Ant Plugin
  Environment Injector Plugin
  Build with Parameters Plugin
  Email ext plugin
  Junit Publish plugin

Ant version 1.9 or later
JDK version 1.7 or later

Pega pipeline does following tasks that cover both the continuous integration and delivery aspects. 

Continuous Integration: Pipeline invokes Pega OOTB functionality to check Compliance/Guardrail score and executes PegaUnit Test suite/cases. 
Continuous Delivery: Pipeline performs both the export and import of Pega Rule-Admin-Product (RAP) file. It saves the exported RAP file to JFrog Artifactory and uses the same file to perform import operation incrementally. 
