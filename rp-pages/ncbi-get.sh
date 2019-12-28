#!/bin/zsh
#
# NCBI page download batch
#
# wget each RP gene page for scrubbing meta-data
# 

mkdir -p ncbi

# gene id csv
TSV='rp.geneid.csv'

# Iterate through each line of input-tsv
N=$(wc -l $TSV | cut -f1 -d' ' -)

DOWNLOAD='FALSE'
if [ "$DOWNLOAD" = 'TRUE' ]
then
	for line in $(seq 2 $N)
	do
		entry=$(sed -n "$line"p $TSV)

		# Gene id + hgnc
		gene=$(echo $entry | cut -f1 -)
		ncbi=$(echo $entry | cut -f4 -)

		echo "Downloading $gene : $ncbi"
		url='https://www.ncbi.nlm.nih.gov/gene/'$ncbi
		curl $url > ncbi/"$ncbi".html
	done
fi