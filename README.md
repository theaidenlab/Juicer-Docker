# Docker version of Juicer
This is the [Docker](https://www.docker.com/) version of [Juicer](https://github.com/theaidenlab/juicer/wiki).  
Juicer is a platform for analyzing kilobase resolution Hi-C data. For general questions, please use 
[the Google Group](https://groups.google.com/forum/#!forum/3d-genomics).

**If you use Juicer in your research, please cite:
Neva C. Durand, Muhammad S. Shamim, Ido Machol, Suhas S. P. Rao, Miriam H. Huntley, Eric S. Lander, and Erez Lieberman Aiden. "Juicer provides a one-click system for analyzing loop-resolution Hi-C experiments." Cell Systems 3(1), 2016.**

# Quick Start
1. Install [Docker](https://www.docker.com/) 
2. Download test fastq files:
```
   cd /path/to/testdir
   wget https://s3.amazonaws.com/juicerawsmirror/opt/juicer/work/HIC003/fastq/HIC003_S2_L001_R1_001.fastq.gz
   wget https://s3.amazonaws.com/juicerawsmirror/opt/juicer/work/HIC003/fastq/HIC003_S2_L001_R2_001.fastq.gz
```
3. Put the fastqs in a folder titled `fastq`:
```
   mkdir fastq
   mv HIC003*.fastq.gz fastq
```
4. Type `docker run aidenlab/juicer:latest`  After downloading the image, the usage message should appear.
5. Run Juicer on the test set via `docker run -v /path/to/testdir:/data aidenlab/juicer:latest -d /data`

# More details
The parameter `-v /path/to/testdir:/data` mounts your directory as /data in the Docker image.  

Everything after `aidenlab/juicer:latest` is a command to Juicer, not a Docker command.  So the parameter `-d /data` tells
Juicer that your files live at the mount point `/data`.  The results of the Juicer run will be written out to this directory;
you will see directories `aligned` and `splits` created underneath your test directory `/path/to/testdir`

In particular, you can call Juicer with all of the usual flags.  We have stored the hg19 reference genome in the image along
with associated restriction site files, but other genomes / restriction site files should be sent in via the `-z` and `-y` flags, 
respectively.  To change the number of threads used by BWA, use the `-t` flag.

Please see [the Juicer documentation](https://github.com/theaidenlab/juicer/wiki) for extensive usage information.

## Test sets
The test set above is the HIC003 fastqs from Rao & Huntley et al. | Cell 2014.  A larger test set, consisting of chromosome 19 from the combined GM12878 map from that paper, is available below.  This test set will produce domains (and theoretically loops, though HiCCUPS requires GPUs and Docker does not support them).

```
    wget  https://s3.amazonaws.com/juicerawsmirror/opt/juicer/work/MBR19/fastq/chr19_R1.fastq.gz
    wget  https://s3.amazonaws.com/juicerawsmirror/opt/juicer/work/MBR19/fastq/chr19_R2.fastq.gz
```


## Macintosh special notes
On a Mac, you might have to change your preferences to add memory for BWA.

Click the Docker whale to edit your Preferences. Then edit your memory and CPUs in the Advanced tab.
![Docker whale](https://github.com/theaidenlab/Juicer-Docker/wiki/images/docker_mac1.png)
![Docker preferences](https://github.com/theaidenlab/Juicer-Docker/wiki/images/docker_mac2.png)
