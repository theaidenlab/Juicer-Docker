
workflow hic {
    Array[Array[String]] fastqs

    String genome_tsv 		# reference genome data TSV file including
							# all important genome specific data file paths
							# and parameters

    call inputs { input:
        genome_tsv = genome_tsv,

    }

    # scatter mapping of fastq pairs (if there are multiple pairs from the same library)
    scatter( i in range(length(fastqs)) ) {
        call align { input:
            idx_tar = inputs.genome['bwa_idx_tar'],
            fastqs_pair = fastqs[i]
        }
    }

    # scatter merging of all the BAM files that are not aligned.bam
    scatter( bam_type in [ align.collisions_log_bam, 
                           align.mapq0_bam, 
                           align.collisions_bam, 
                           align.aligned_bam] ){
        call merge {input:
            bam_files = bam_type
        }
    }
    # merge filter dedup of the aligned BAMs 
    call filter_dedup_merge { input:
        bam_files = align.aligned_bam
    }

    # generate .hic from pairs file (could be easily switched to BAM file)
    call generate_hic { input:
        pairs_file = filter_dedup_merge.pairs_file
    }

}

task inputs {
    File genome_tsv
    outputs {
        Map[String,String] genome = read_map(genome_tsv)
    }
}

task align {
    Array[File] fastqs_pair # [end_id]
    File idx_tar            #reference bwa index tar file
    
    command {
        align using bwa fastq_pair
    }

    output {
        File collisions_log_bam = glob('*type_1.bam')[0]
        File mapq0_bam = glob('*type_2.bam')[0]
        File collisions_bam = glob('*type_3.bam')[0]
        File unmapped_bam = glob('*type_4.bam')[0]
        File aligned_bam = glob('*type_5.bam')[0]

        File quality_metric = glob('*alignment.qc.log')[0]
    }
}

task merge {
    Array[File] bam_files

    command {
        merge bam_files
    }

    output {
        File merged_bam = glob('*.bam')[0]
    }
}

task filter_dedup_merge {
    Array[File] bam_files

    command {
        filter_dedup_merge bam_files
    }

    output {
        File merged_bam = glob('*.bam')[0]

        # potentially pairs file will be removed later or retained for consistency with 4DN?
        File pairs_file = glob('merged_no_dups.txt')[0]
    }
}

task generate_hic {
    # potentially will change into BAM file
    File pairs_file

    command {

    }
    
    output {
       File hic_matrix = glob('*.hic')[0] 
    }
}