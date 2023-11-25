#!/bin/bash

# Check if an argument is provided
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <filepath>"
    exit 1
fi

# Get the filepath from the command-line argument
filename="$1"


while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ ${line:0:1} =~ "@" ]]; then
	inside_entry=true
	if [[ $line =~ \{([^,]+), ]]; then
            key="${BASH_REMATCH[1]}"
	fi
    fi
    if $inside_entry; then
	trimmed_line="${line#"${line%%[![:space:]]*}"}"
	IFS="=" read -r item value <<< "$trimmed_line"
	# author
	if [[ $item =~ author ]]; then
	    author="${value//[^[:alnum:] .,]/}"
	    author="${author%%[.,]}"
	fi

	# collaboration
	if [[ $item =~ collaboration ]]; then
	    collab="${value//[^[:alnum:] .,]/}"
	    collab="${collab%%[.,]}"
	fi
	
	# title
	if [[ $item =~ title ]]; then
	    title="${value#"${value%%[![:space:]]*}"}"
	    title="${title//[^[:alnum:] .,-]/}"
	    title="${title%%[.,Th ,]}"
	    # title="${title#?}"

	fi
	    

	# eprint
	if [[ $item =~ eprint ]]; then
	    eprint="${value//[^[:alnum:] .,-]/}"
	    eprint="${eprint%%[.,]}"
	    eprint="${eprint#??}"
	fi

	# archivePrefix
	if [[ $item =~ archivePrefix ]]; then
	    apre="${value//[^[:alnum:] .,]/}"
	    apre="${apre%%[.,]}"
	    apre="${apre#?}"
	    # apre="${apre%?}"
	fi	

	# primaryclass
 	if [[ $item =~ primaryClass ]]; then
	    primcl="${value//[^[:alnum:] .,-]/}"
	    primcl="${primcl%%[.,]}"
	    primcl="${primcl#?}"
	fi	

	
	# doi
	if [[ $item =~ doi ]]; then
	    # doi="${value//[^[:alnum:] .,/-]/}"
	    # doi="${doi%%[.,]}"
	    doi="${value#??}"
	    doi="${doi%??}"

	    
	fi
 
	# journal
	if [[ $item =~ journal ]]; then
	    journal="${value//[^[:alnum:] .,-]/}"
	    journal="${journal%%[.,]}"
	fi

	# volume
	if [[ $item =~ volume ]]; then
	    volume="${value//[^[:alnum:] .,]/}"
	    volume="${volume%%[.,]}"
	fi

	# pages
	if [[ $item =~ pages ]]; then
	    pages="${value//[^[:alnum:] .,-]/}"
	    pages="${pages%%[.,]}"
	fi

	# year
	if [[ $item =~ year ]]; then
	    year="${value//[^0-9]/}"
	    # year="${year%%[.,]}"
	    # year="${year##*( )}"
	    # echo "($year)"

	    
	fi

    fi

    if [[ $line == "}" ]]; then
	inside_entry=false
	# Built the \bibitem one variable at a time
	printf "\\\bibitem{%s} %s. " "$key" "$author"
	# test for collab
	if [[ -n $collab ]]; then
	    printf "(%s) " "$collab"
	fi

	# test for journal
	if [[ -n $journal ]]; then
	    printf "{\\\bf %s}. " "$journal"
	fi

	# test for volume
	if [[ -n $volume ]]; then
	    printf "{\\\bf %s} " "$volume"
	fi

	# test for year
	if [[ -n $year ]]; then
	    printf "(%s) " "$year"
	fi

	# test for pages
	if [[ -n $pages ]]; then
	    printf "%s; " "$pages"
	fi

	# test for doi
	if [[ -n $doi ]]; then
	    printf "doi:%s " "$doi"
	fi

	# test for title
	if [[ -n $title ]]; then
	    printf "\`\`%s\'\' " "$title"
	fi

	# test for archive prefix
	if [[ -n $apre ]]; then
	    printf "%s:" "$apre"
	fi

	# test for primary class
	if [[ -n $primcl ]]; then
	    printf "%s/" "$primcl" 
	fi

	# test for eprint
	if [[ -n $eprint ]]; then
	    printf "%s" "$eprint"
	fi
	
	printf "\n" 

	# printf "\`\`%s\'\'" "$title"
	# printf "\n" 
	unset key author collab title eprint apre doi journal volume pages year primcl
    fi
done < "$filename"


# \bibitem{PRL112-061802} K. Abe et al. (The T2K Collaboration), {\bf Phys. Rev. Lett. {\bf 112} (2014) 061802; doi: 10.1103/PhysRevLett.112.061802}; ``Observation of Electron Neutrino Appearance in a Muon Neutrino Beam'' (arXiv:hep-ex/1311.4750)\\

