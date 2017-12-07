
workflow hic {
    Array[Array[String]] fastqs
    Array[Array[String]] bams
    Array[String] filtered_deduped_bam
    
    # not sure if these have to be arrays
    String merged_nodups_pairs
    String hic_file

    String genome_tsv 		# reference genome data TSV file including
							# all important genome specific data file paths
							# and parameters


    # optional may be we add in the future
	Boolean? align_only 	# disable downstream analysis
							# after alignment
    Boolean? hic_only # disable downstream analysis
					  # after hic matrix creation
    
    call inputs { input:
        genome_tsv = genome_tsv,
        fastqs = fastqs,
		bams = bams,
		filtered_deduped_bam = filtered_deduped_bam

    }

    if ( inputs.is_before_bam ) {
        # scatter mapping of fastq pairs (if there are multiple pairs from the same library)
        scatter( i in range(length(fastqs)) ) {
            call align { input:
                idx_tar = inputs.genome['bwa_idx_tar'],
                fastqs_pair = fastqs[i]
            }
        }
    }

    if ( inputs.is_before_deduped_filtered ) {

        collisions_log_bam_array = 

        # scatter merging of all the BAM files that are not aligned.bam
        scatter( bam_type in [ if defined(align.collisions_log_bam) then align.collisions_log_bam else bams[0], 
                                ####> same as the line of collisions_log_bam in the next three lines
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
    }

    # generate .hic from pairs file (could be easily switched to BAM file)
    call generate_hic { input:
        pairs_file = filter_dedup_merge.pairs_file
    }

    # generate loops.bedpe
    # generate TADs.bedpe

}

task inputs {
    File genome_tsv
    Array[Array[String]] fastqs
    Array[Array[String]] bams
    Array[String] filtered_deduped_bam

    command <<<
		python <<CODE
		name = ['fastq','bam','deduped_filtered']
		arr = [${length(fastqs)},${length(bams)},
		       ${length(deduped_filtered)}]
		num_rep = max(arr)
		type = name[arr.index(num_rep)]

		with open('type.txt','w') as fp:
		    fp.write(type)		    
		CODE
	>>>

    outputs {
        Map[String,String] genome = read_map(genome_tsv)
        String type = read_string("type.txt")
        Boolean is_before_bam =
			type=='fastq'
		Boolean is_before_deduped_filtered =
			type=='fastq' || type=='bam'
		Boolean is_before_hic =
			type=='fastq' || type=='bam' ||	type=='deduped_filtered'
    }
}

task align {
    Array[File] fastqs_pair # [end_id]
    File idx_tar            #reference bwa index tar file
    
    # resource
	Int? cpu
	Int? mem_mb

    command {
        align using bwa fastq_pair
    }

    output {
        File collisions_log_bam = glob('*type_1.bam')[0]
        File mapq0_bam = glob('*type_2.bam')[0]
        File collisions_bam = glob('*type_3.bam')[0]
        File unmapped_bam = glob('*type_4.bam')[0]
        File aligned_bam = glob('*type_5.bam')[0]

        File quality_metric = glob('*alignment_qc.log')[0]
    }

    runtime {
        # here we will specify the docker download path
		cpu : select_first([cpu,2])
		memory : "${select_first([mem_mb,'10000'])} MB"
		
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

    runtime {
        # here we will specify the docker download path
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
        
        File quality_metric = glob('*merge_qc.log')[0]
    }
    
    runtime {
        # here we will specify the docker download path
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
