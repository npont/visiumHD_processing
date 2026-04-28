#!/bin/bash

#SBATCH --job-name cellranger_counts_json_v3
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 72 
#SBATCH --mem=128G
#SBATCH --qos=fast
#SBATCH --mail-user=naomie.pont@pasteur.fr
#SBATCH -o log/%x_%J.out
#SBATCH -e log/%x_%J.err

Help()
{
	echo 'sbatch --array=1-2 1.1spaceranger_counts_with_json.sh samples_manually_aligned.txt'
	echo
	echo 'Where input_samples.txt contains sample names per row, such as Sample_A1 Sample_D1'
	echo
	echo 'This script matches the paths for EOM_VisiumHD'
	echo
	echo 'Adjust the number in --array accordingly to the number of samples'
	echo 
	echo 'This script is used for spaceranger count using the manual alignment of the image to fiducial frame done in Loupe Browser and that provided a json file (because the automatic alignment failed)'
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    Help
    exit 0
fi

## The bin size was set to 10 microns (it can be set to even nb ranging from 4 to 100 microns).
## Here he also provide the microscope image while he didn't in 1.spaceranger_count

module load bcl2fastq/2.20.0
module load spaceranger/3.0.1

sample=$(head -n ${SLURM_ARRAY_TASK_ID} $1 | tail -n 1)
short_sample=${sample/Sample_/}

datadir="/pasteur/zeus/projets/p02/CSD_hpc/data/lab/spatial/EOM_VisiumHD/"
# Naomie:
datadir_2="/pasteur/zeus/projets/p02/Fast_npz/Naomie/Rstudio_spatial/spatial_EOM/data/"
refdir="/pasteur/zeus/projets/p02/CSD_hpc/data/ref/VisiumHD/refdata-gex-GRCh38-2020-A"
probeset="/pasteur/zeus/projets/p02/CSD_hpc/data/ref/VisiumHD/Probeset_v2_human/"
cytaimgroot="${datadir}/CytAssist_img/CAVG10547_2024-06-07_13-22-04_2024-06-07_13-07-20_H1-P77ZJJX_"
# Naomie output path
output_dir="/pasteur/zeus/projets/p02/Fast_npz/Naomie/Rstudio_spatial/visiumHD_outputs/EOM/"

# Create the output dir if it does not already exist
mkdir -p ${output_dir}counts/${sample}

spaceranger count --id=${sample} \
                    --sample=${sample} \
                    --cytaimage=${cytaimgroot}${short_sample}_sample.tif \
                    --transcriptome=${refdir} \
                    --probe-set=${probeset}Visium_Human_Transcriptome_Probe_Set_v2.0_GRCh38-2020-A.csv \
                    --fastqs=${datadir}fastqs/outs/fastq_path/AAFYHNGM5/ \
                    --output-dir=${output_dir}counts/${sample} \
                    --create-bam=true \
                    --slidefile=${datadir}H1-P77ZJJX.vlf \
                    --slide=H1-P77ZJJX \
                    --area=${short_sample} \
                    --image=${datadir}scan_he/tiff_converted/sample_${short_sample}_highres_rgb.tif \
                    --loupe-alignment=${datadir}CytAssist_img/H1-P77ZJJX-${short_sample}-fiducials-image-registration_highestres_rgb.json \
                    --custom-bin-size=10 

#cytaimage: path to the cytAssist image
#probeset: to be downloaded from 10X website 
#image: path to the microscope image i.e. the H&E, that have been converted to TIF format
#loupe_alignment: json image generated from Loupe Browser when doing the manual alignment of CytAssist image and microscope image 
