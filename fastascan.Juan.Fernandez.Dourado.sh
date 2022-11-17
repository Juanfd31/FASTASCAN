#We will define as FASTAS the list of directories where we have fasta files (*.fasta or *.fa)

#First of all we are going to check if there is an argument (directory).
# In other words, if the argument ($1) is null or not
#  - In case there is one, we will find in that directory ($1).
#  - In case there is not, we will find in the working directory.

if [[ -n $1 ]];
then
	FASTAS=$(find $1 \( -type l -o -type f \) \( -name "*.fa" -or -name "*.fasta" \) );   	#We could add: -not -path '*/.*' just to avoid  hidden files. 
else																						# but we could have some bugs in case we want to go two directories
	FASTAS=$(find . \( -type l -o -type f \) \( -name "*.fa" -or -name "*.fasta" \)  );		# back. We are adding -type f, and -type l to filter just to files and links, and 	
																							# -name to just find files ending with .fa or .fasta
fi;

#Once we have defined in which directory we are ANALYZING,
#  we will check if there is any found (fasta file) in  that directory:
# - If there are founds we analyze them
# - If not , we print a informative message.
 
if [[ -n $FASTAS  ]];
 then

	#In case there is a found, we will create a temporal file where we will store 
	# all the information in a table.
	#First of all we will print in this file (fastascan.tbl) the headers using the option -e
	#to consider the tabular format

		
		echo -e  "FILE DIRECTORY" '\t' "N_SEQS" '\t' "SEQ_TYPE" '\t' "SEQ_LENGTH" '\t' "¿SYMLINK?" > fastascan.tbl
		
	#We print a message to explain th user that the results will be in a summary table.
		#We will print this big title with some colors, in this case red and blue.
	
	blue='\033[0;34m'
	red='\033[0;31m'  #Here, we are defining the command where bash will color our message.
	nc='\033[0m'	   # and the place where it has to stop changing the color
	
		echo
		echo -e "${blue}  #################################"
		echo -e "  ##   FASTASCAN SUMMARY TABLE   ##"
		echo -e "  ##  by ${nc}${red}Juan Fernández Dourado  ${nc}${blue}##"
		echo -e "  #################################${nc}"
		echo

	#Now, we will create a loop in order to travel throught all the files found
	# and take all the information we need store in some variables:

	for i in $FASTAS;do
	 
	#count the number of sequences on each file found and save the value on $N_SEQS. 
	# We use -I to avoid binary files.
	 
		N_SEQS=$(egrep -Ic '^[>]' $i);  
		
	#check if the file is a symlink or not and save the info on $SYMLINK

		if [[ -h $i ]]
		then
		SYMLINK=$(echo "Yes");
		else
		SYMLINK=$(echo "No");
		fi
		 
	#compute the length of the sequence at each file after removing spaces,
	# "-" and the line with the title and save it on $SEQ_LENGTH
		
		SEQ_LENGTH=$(sed -E '/^>/d; s/ //g; s/-//g' $i | awk '{n = length($0)+n}END{print n }')	
	
	# Check if the file is empty.
	#  - If it is, were saving the seq_type as empty.
	#  - If not, we remove gaps,spaces and titles and we check if it has a  
	#    letter that is not A-C-G-T-U-N .
	#     - If it has its a protein sequence
	#     - If not its a nucleotides one
	
		 if [[ ! -s $i ]];
		 then
		 SEQ_TYPE=$(echo "empty")											
		 elif																
		 sed -E '/^>/d; s/ //g; s/-//g' $i | egrep -q '[^AGCTUNacgtun]' ;								
			then 															
			SEQ_TYPE=$(echo "Aminoacidic");									
		else 															
			SEQ_TYPE=$(echo "Nucleotidic");
		 fi

	#compute the length of the sequence at each file after removing spaces,
	# "-" and the line with the title and save it on $SEQ_LENGTH
		
		SEQ_LENGTH=$(sed -E '/^>/d; s/ //g; s/-//g' $i | awk '{n = length($0)+n}END{print n }')	
		
	#Print the different results (previous save on variables) obtained for each fasta file, 
	# in the file created, separating values with tabs. 
	
		echo -e $i '\t' $N_SEQS '\t' $SEQ_TYPE '\t' $SEQ_LENGTH '\t' $SYMLINK >> fastascan.tbl
		
	done;
	
	
	#PRINTING INFORMATION STORED
	
	#Print results save on the file, using column command to separate
	#columns in a more visual way.
	
	column -t -s $'\t' fastascan.tbl

	#Print a single title without the directory (-h)
	
	echo
	echo " - Title example --> " $(grep -h ">"  $FASTAS | head -n 1)

	#Print total sequences found (obtained by adding all the values on 
	#the "N_SEQS" column)
	
	echo
	awk -F '\t' 'NR>1{n=n+$2}END{print " - Total sequences -->  " n }' fastascan.tbl
	
	#Prtin total sequences length(obtained by adding all the values on 
	#the "#SEG_LENGTH" column)
	
	echo
	awk -F '\t' 'NR>1{n=n+$4}END{print " - Total sequence length -->  " n }' fastascan.tbl

	#Once we finished we remove the file created to avoid storing it on the memory.
	
	rm fastascan.tbl

else # in case there is not a fasta file, we print an informative message.

	echo "##### No fasta file was found :( #####"
	
fi;
