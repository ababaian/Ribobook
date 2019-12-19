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
pagedir='pages'
genelist='rp.gene.list'

# Make output directory; clear previous
mkdir -p $pagedir
rm $pagedir/*


# GENERATE PAGES ------------------------------------------
for GENE in $(cat $genelist)
do
	PAGE="$pagedir/rp-$GENE".md

	# Copy template to gene page
	cp $template $PAGE

	# Search and replace keyword %GENE% with $GENE
	sed "s/%GENE%/$GENE/g" $template > $PAGE 

	# Edge-cases --------------------------------
	# RACK1 links for COSMIC/TCGA should be GNB2L1
	if [ $GENE == 'RACK1' ]
	then
		sed -i "s/=RACK1/=GNB2L1/g" $PAGE
	fi
done