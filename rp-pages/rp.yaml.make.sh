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
	
	# ensure 1 empty line at end of file
	if [ ! -z $(tail -n1 $TSV) ]
	then
		echo "\n" >> $TSV
	fi

	# Iterate through TSV (rp-gene)
	N=$(wc -l $TSV | cut -f1 -d' ' -)
	for line in $(seq 2 $N)
	do
		# For each gene ===================================
		entry=$(sed -n "$line"p $TSV)
		gene=$(echo $entry | cut -f1 -)
		echo $gene

		# Read GENEID CSV file ============================
		desc=$(echo $entry | cut -f2 -)
		subu=$(echo $entry | cut -f3 -)
		ncbi=$(echo $entry | cut -f4 -)
		hgnc=$(echo $entry | cut -f5 -)
		ensg=$(echo $entry | cut -f6 -)
		unip=$(echo $entry | cut -f7 -)
		
		pdbc=$(echo $entry | cut -f8 - )
		prot=$(echo $entry | cut -f9 - )
		yeas=$(echo $entry | cut -f10 - )
		bact=$(echo $entry | cut -f11 - )
		omim=$(echo $entry | cut -f12 - )

		# Scrub NCBI Page =================================
		ncbi_page=ncbi"/$ncbi".html

		if [ -e "$ncbi_page" ]
		then
			# Also Known As -----------
			aka_n=$( grep -n '<dt>Also known as</dt>' $ncbi_page |\
			  cut -f1 -d":" - )
			
			if [ -z $aka_n ]
			then
				# if AKA not found
				aka='NA'
			else
				# if AKA is found. Parse
				(( aka_n = $aka_n + 1 ))
				aka=$( sed -n "$aka_n"p $ncbi_page |\
				  sed 's/^[ ]*//g' - |\
				  sed 's/<.\{1,3\}>//g' - )
			fi

			# Refseq Summary ----------
			summary_n=$( grep -n '<dt>Summary</dt>' $ncbi_page |\
			  cut -f1 -d":" - )
			if [ -z $summary_n ]
			then
				# if AKA not found
				summary='NA'
			else
				# if summary is found. Parse
				(( summary_n = $summary_n + 1 ))
				summary=$( sed -n "$summary_n"p $ncbi_page |\
				  sed 's/^[ ]*//g' - |\
				  sed 's/<.\{1,3\}>//g' - )
			fi
		else
			# echo no ncbi page
			echo "No NCBI page found for $gene : $ncbi."
		fi

		# Generate YAML-rp File ===========================
		rpfile=yaml/"$gene".yaml

		# Add annotation
		echo "  description: $desc" >> $rpfile
		echo "  subunit: $subu"     >> $rpfile
		echo "  summary: $summary"  >> $rpfile
		echo "  aka: $aka"          >> $rpfile
		echo "  ncbi: $ncbi"        >> $rpfile
		echo "  ensg: $ensg"        >> $rpfile
		echo "  omim: $omim"        >> $rpfile
		echo "  hgnc: $hgnc"        >> $rpfile
		echo "  uniprot: $unip"     >> $rpfile

		echo "  protein: $prot"     >> $rpfile
		echo "  pdb_chain: $pdbc"   >> $rpfile
		echo "  yeast: $yeas"       >> $rpfile
		echo "  bacteria: $bact"    >> $rpfile

	done
fi

# cleanup empty files
rm yaml/.yaml