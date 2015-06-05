#RepeatRunner
![RepeatRunner](http://www.yandell-lab.org/images/RepRun-Logo.png)

RepeatRunner is a CGL-based program that integrates RepeatMasker with BLASTX to provide a comprehensive means of identifying repetitive elements. Because RepeatMasker identifies repeats by means of similarity to a nucleotide library of known repeats, it often fails to identify highly divergent repeats and divergent portions of repeats, especially near repeat edges. To remedy this problem, RepeatRunner uses BLASTX to search a database of repeat encoded proteins (reverse transcriptases, gag, env, etc...). Because protein homologies can be detected across larger phylogenetic distances than nucleotide similarities, this BLASTX search allows RepeatRunner to identify divergent protein coding portions of retro-elements and retro-viruses not detected by RepeatMasker. RepeatRunner merges its BLASTX and RepeatMasker results to produce a single, comprehensive XML-based output. It also masks the input sequence appropriately. In practice RepeatRunner has been shown to greatly improve the efficacy of repeat identifcation1. RepeatRunner can also be used in conjunction with PILER-DF - a program designed to identify novel repeats - and RepeatMasker to produce a comprehensive system for repeat identification, characterization, and masking in the newly sequenced genomes.

#Important Note:
* repeat_runner IS ALPHA SOFTWARE. THERE ARE NO WARRANTIES OR GUARENTEES AS TO ITS UTILITY, CORRECTNESS, OR VALUE OF ITS OUTPUTS. USE AT YOUR OWN RISK.

#Installing
To run repeat_runner do the following:

1 - Download and install CGL from (www.yandell-lab.org/cgl);

2 - Set the REPEAT_RUNNER_LIB environment varible to point at the repeat_runner/lib directory

3 - If you havent' done so already, install wu-blast and set the necessary enviroment varibles, 
   such as WUBLASTFILTER, WUBLASTMATRIX

4 - If you are using the te_protein.fasta as a blastx database (by default this is true), format it using
   the wu-blast setdb command, e.g. setdb repeat_runner/sample_data/te_proteins.fasta

5 - Customize the paramters.cfg file in repeat_runner/config. To do this set the paths to the various executables
   and databases on your machine.

6 - type ./bin/repeat_runner for a usage statement. 
