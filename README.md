# pega-pipeline
A Continuous Integration/Continuous Delivery pipeline for Pega Platform is an automated process to quickly move applications from development through testing to deployment.

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

Continuous Integration:
-----------------------
Pipeline invokes Pega OOTB functionality to check Compliance/Guardrail score and executes PegaUnit Test suite/cases. This can be used in the early stages of pipeline - Dev to QA. 
UI/API based regression testing is not part of this project and hasn't been explored. 

Continuous Delivery: 
--------------------
Pipeline performs both the export and import of Pega Rule-Admin-Product (RAP) file. It saves the exported RAP file to JFrog Artifactory and uses the same file to perform import operation incrementally. 

Contributing
------------

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.
