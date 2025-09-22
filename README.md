# Overview
Scripts for checking content quality assurance metrics in asciidoc files.

These scripts were co-created with AI, but tested and tweaked by a human (me) on the Ingress Operator assembly and collection of modules therein. If you encounter any edge case situations please file an issue or open a PR.

These scripts assume you have a directory structure like that of the `openshift-docs` repository.

## How to use

### Initialization

First, make the scripts executable. E.g. the following command makes all scripts in the current directory executable:
```
chmod +x *.sh
```
Then, run the following script on your assembly of choice to get a text file containing all the modules present in that assembly:
```
./extract-modules.sh path/to/your/assembly.adoc
```
This output file, `module-output.txt` will be the input of the other script files.

### Running a script

All of the scripts can take individual modules as an array. E.g.
```
./check-links.sh file1.adoc file2.adoc
```
But you can more efficiently analyze modules you have extracted filenames of from a text file:
```
cat module-output.txt | ./check-links.sh
```
Ensure the path to your modules and to the scripts make sense. For example, you can move your scripts and text file to your `openshift-docs/modules/` directory and remove them when finished.

### Using with Vale

Some CQA metrics dovetail nicely with existing linting checks we already have with Vale. Vale can take input from stdin, so after initialization you can run something like the following if you have your output file within your `/modules` directory. E.g. get the readability grade for your content:
```
xargs vale --filter='.Name=="RedHat.ReadabilityGrade"' < module-output.txt
```
