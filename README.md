
repeat_runner IS ALPHA SOFTWARE. THERE ARE NO WARRANTIES OR GUARENTEES AS TO ITS UTILITY, 
CORRECTNESS, OR VALUE OF ITS OUTPUTS. USE AT YOUR OWN RISK.

To run repeat_runner do the following:

0. download and install CGL from (www.yandell-lab.org/cgl);

1. set the REPEAT_RUNNER_LIB environment varible to point at the repeat_runner/lib directory

2. If you havent' done so already, install wu-blast and set the necessary enviroment varibles, 
   such as WUBLASTFILTER, WUBLASTMATRIX

3. If you are using the te_protein.fasta as a blastx database (by default this is true), format it using
   the wu-blast setdb command, e.g. setdb repeat_runner/sample_data/te_proteins.fasta

4. Customize the paramters.cfg file in repeat_runner/config. To do this set the paths to the various executables
   and databases on your machine.

5. type ./bin/repeat_runner for a usage statement. 
