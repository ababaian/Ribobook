#!/bin/zsh
# rp.yaml.make.sh
#
# Perform a line-by-line lookup for gene name
# dump column matches into the yaml rpfile
#
# i.e.
#
# RPSS HGNC:6502
# -->
# gene: RPSA
#   HGNC: 6502

INIT='TRUE'
LIST='rp.gene.list'
if [ "$INIT" = 'TRUE' ]
then
	# Initialize YAML rpfiles for each RP in rp.gene.list
	mkdir -p yaml

	for line in $(cat $LIST)
	do
		rpfile=yaml/"$line".yaml
		rm -f $rpfile; touch $rpfile

		echo "#YAML 1.2" >> $rpfile
		echo "#Ribosomal Protein Template" >> $rpfile

		echo "gene: $line" >> $rpfile
	done
fi


GENEID='TRUE'
TSV='rp.geneid.csv'
if [ "$GENEID" = 'TRUE' ]
then
	# Convert CSV to TSV
	sed -i 's/\"//g' $TSV
	sed -i 's/,/\t/g' $TSV
	echo "\n" >> $TSV

	# Iterate through each line of input-tsv
	N=$(wc -l $TSV | cut -f1 -d' ' -)

	for line in $(seq 1 $N)
	do
		entry=$(sed -n "$line"p $TSV)

		# rp_geneid.csv: gene	description	subunit	HGNC	ENSG	uniprot
		gene=$(echo $entry | cut -f1 -)
		echo $gene

		desc=$(echo $entry | cut -f2 -)
		subu=$(echo $entry | cut -f3 -)
		hgnc=$(echo $entry | cut -f4 -)
		ensg=$(echo $entry | cut -f5 -)
		unip=$(echo $entry | cut -f6 -)
		
		# yaml-rpfile
		rpfile=yaml/"$gene".yaml

		# Add annotation
		echo "  description: $desc" >> $rpfile
		echo "  subunit: $subu" >> $rpfile
		echo "  HGNC: $hgnc" >> $rpfile
		echo "  ENSG: $ensg" >> $rpfile
		echo "  uniprot: $unip" >> $rpfile

	done
fi