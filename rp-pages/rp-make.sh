#!/bin/bash
#
# rp-make.sh
#
# Procedural generation of Ribosomal Protein (Large and Small)
# pages for ribobook
#

# For each RP gene listed in rp.gene.list
# create a markdown file and populate it with generic
# data

# PARAMETERS ----------------------------------------------
template='rp-template.md'
pagedir='./pages'
genelist='rp.gene.list'
yamldir='./yaml'

# Make output directory; clear previous
mkdir -p $pagedir
rm $pagedir/*


# GENERATE PAGES ------------------------------------------
for gene in $(cat $genelist)
do
	echo "Processing: $gene"

	page="$pagedir/rp-$gene".md
	yaml="$yamldir"/"$gene".yaml

	if [ ! -s $yaml ]
	then
		echo "$yaml Does not exist (or is empty)."
		echo "Genenerate yaml-files prior to rp-make.sh"
		exit 1
	fi

	# Copy template to gene page
	cp $template $page

	# Read the gene yaml file
	cp $yaml tmp
	sed -i '/^#.*/d'       tmp
	sed -i 's/^[ ]*//g'    tmp
	sed -i 's/[ ]*$/"/g'   tmp
	sed -i 's/:[ ]*/\="/g' tmp

	# Read YAML keywords as variables
	# gene; description; subunit;
	# HGNC; ENSG; uniprot
	source tmp
	rm tmp

	# Search and replace keywords in template
	sed -i "s/%gene%/$gene/g"        $page
	sed -i "s/%protein%/$protein/g"  $page
	sed -i "s/%subunit%/$subunit/g"  $page
	sed -i "s/%HGNC%/$HGNC/g"        $page

	# If variable is available. Parse sentence.
	if [ $description != 'NA' ]; then
		sed -i "s/%description%/$description/g" $page
	fi

	if [ $summary != 'NA' ]; then
		sed -i "s/%summary%/##RefSeq Summary\n$summary/g" $page
	fi

	if [ $yeast != 'NA' ]; then
		state="Yeast homolog is $yeast".
		sed -i "s/%yeast%/$state/g" $page
	fi

	if [ $bacteria != 'NA' ]; then
		state="Bacterial homolog is $bacteria".
		sed -i "s/%bacteria%/$state/g" $page
	fi
	
	# Clear any un-used variables
	# TODO print that a variable is not found in a gene profile
	sed -i 's/%[A-Za-z0-9\-_]*%//g' $page

	# Edge-cases --------------------------------
	# RACK1 links for COSMIC/TCGA uses gene name GNB2L1
	if [ $gene = 'RACK1' ]
	then
		sed -i "s/=RACK1/=GNB2L1/g" $page
	fi
done