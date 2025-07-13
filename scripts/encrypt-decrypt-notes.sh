#!/bin/bash

######################################
### !!! IMPORTANT !!! ###
### !!! READ BEFORE PROCEEDING !!! ###
# This script deals with encryption. While the encryption itself
# should be secure (I'm using Open SSL for handling that), the script
# itself might do things that you might not be OK with
# or might not be secure enough for your use-case.
#
# For example, the encryption process, the code first decrypts the encrypted files
# and then does the comparison to see what to add/update/delete.
# If something fails in the process, the decrypted file will stay behind on in the tmp dir.
#
# Also, the file names aren't encrypted, which might be a problem for some.
#
# The above aren't problem for my use-case and I accept the risk in my threat model,
# but that might not be the case for you.
### !!! READ BEFORE PROCEEDING !!! ###
### !!! IMPORTANT !!! ###
######################################

##################################
# --- Beginning of Constants --- #
##################################
# Commands
ENCRYPT="encrypt"
DECRYPT="decrypt"

# Colours
ERR_COLOR='\033[0;31m'
WAR_COLOR='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
# I structure the files, so that handy scripts are in $DEPS_DIR
DEPS_DIR="${SCRIPT_DIR}/encrypt-decrypt-notes"

# Defaults
DEFAULT_DECRYPT_DIR="."
DEFAULT_ENCRYPT_DIR="./.git-backup"
# If you want a path to a default pass file, fill in the below
# TODO: fill in the default password
# DEFAULT_PASS_FILE=""

############################
# --- End of Constants --- #
############################

# Values
DECRYPT_DIR=""
ENCRYPT_DIR=""
PASS_FILE=""
MODE=""
file_num=0

E_CO=0

# --- Help function ---
usage() {
	echo "Usage: $0 [-E | -D] -s <decrypted_directory> -d <encrypted_directory>"
	echo "A CLI tool to encrypt or decrypt files in a directory, preserving structure."
	echo ""
	echo "Modes (choose exactly one):"
	echo "  -E              Encrypt files. Output will be ASCII-armored (.asc extension)."
	echo "                  Excludes '.DS_Store' files"
	echo "  -D              Decrypt files. Searches for files with '.asc' extension."
	echo ""
	echo "Options:"
	echo "  -s <directory>  Decrypted directory. Default: '${DEFAULT_DECRYPT_DIR}'"
	echo "  -d <directory>  Encrypted directory. Default: '${DEFAULT_ENCRYPT_DIR}'"
	echo "  -p <file>       File with a password for encryption/decryption. Default: '${DEFAULT_PASS_FILE}'"
	echo "  -h              Display this help message."
	exit 1
}

decrypt_files() {
	local_decrypt_dir="$1"
	local_encrypt_dir="$ENCRYPT_DIR"

	find "$local_encrypt_dir" \
		-type d -name ".git" -prune -o \
		-path "$local_decrypt_dir" -prune -o \
		-type f -name "*.asc" -print0 | while IFS= read -r -d '' fileName; do

		echo "Processing: $fileName"
		((file_num++))

		relativeFileName="${fileName#$ENCRYPT_DIR/}"
		outputFile="${local_decrypt_dir}/${relativeFileName%.asc}"
		echo "Decrypting '$fileName' -> '$outputFile'"
		mkdir -p "$(dirname "$outputFile")" || {
			echo "${ERR_COLOR}Error:${NC} Could not create destination subdirectory for '$outputFile'."
			exit 1
		}

		openssl enc -d -aes-256-cbc -pbkdf2 -a -in "$fileName" -out "$outputFile" -pass file:$PASS_FILE

		if [[ $? -ne 0 ]]; then
			echo -e "${ERR_COLOR}Error:${NC} Coulnd't decrypt '$fileName'"
			exit 1
		fi
	done
}

encrypt_file() {
	fileName="$1"

	file_num=$((file_num + 1))

	relativeFileName="${fileName#$DECRYPT_DIR/}"
	outputFile="$ENCRYPT_DIR/${relativeFileName}.asc"
	echo "Encrypting '$fileName' -> '$outputFile'"
	mkdir -p "$(dirname "$outputFile")" || {
		echo -e "${ERR_COLOR}Error:${NC} Could not create destination subdirectory for '$outputFile'."
		exit 1
	}

	openssl enc -aes-256-cbc -pbkdf2 -a -in "$fileName" -out "$outputFile" -pass file:$PASS_FILE

	if [[ $? -ne 0 ]]; then
		echo -e "${ERR_COLOR}Error:${NC} Coulnd't encrypt '$fileName'"
		exit 1
	fi
}

remove_files() {
	DIR_1="$1"
	DIR_2="$2"

	# --- Find files missing in $DIR_1 (present in $DIR_2 only) ---
	# Use find to get full paths, then sed to strip the directory prefix
	# sort is necessary for comm to work correctly
	comm -13 <(find $DIR_1 \
		-path "$IGNORE_DIR" -prune -o \
		-type f -not -name ".DS_Store" | sed "s|^$DIR_1/||" | sort) \
		<(find "$DIR_2" -type f | sed "s|^$DIR_2/||" | sort) | while IFS= read -r fileToRemove; do
		fullFileToRemove="${ENCRYPT_DIR}/${fileToRemove}.asc"
		echo "Removing file: '$fullFileToRemove'"
		rm -r "$fullFileToRemove"
	done
}

update_files() {
	DIR_1="$1"
	DIR_2="$2"

	# --- Find files with different content ---
	# Iterate over files in $DIR_1
	find "$DIR_1" -type f -print0 | while IFS= read -r -d $'\0' file1; do
		# Get the relative path of the file
		relative_path="${file1#$DIR_1/}"
		file2="$DIR_2/$relative_path"

		# Check if the corresponding file exists in $DIR_2
		if [ -f "$file2" ]; then
			# Compare the content of the two files
			if ! cmp -s "$file1" "$file2"; then
				fullFileToUpdate="${DIR_1}/${relative_path}"
				echo "Updating file: '$fullFileToUpdate'"
				encrypt_file "$fullFileToUpdate"
			fi
		fi
	done
}

add_files() {
	DIR_1="$1"
	DIR_2="$2"
	IGNORE_DIR="$ENCRYPT_DIR"

	comm -23 <(find $DIR_1 \
		-path "$IGNORE_DIR" -prune -o \
		-type f -not -name ".DS_Store" | sed "s|^$DIR_1/||" | sort) \
		<(find "$DIR_2" -type f | sed "s|^$DIR_2/||" | sort) | while IFS= read -r fileToAdd; do
		# I have some weird bug, where the directory with encrypted content is in the result
		# This is weird, because the find is supposed to ignore it.
		# As a result, I skip it.
		if [[ "$fileToAdd" == "${IGNORE_DIR#$DIR_1/}" ]]; then
			continue
		fi
		fullFileToAdd="${DECRYPT_DIR}/${fileToAdd}"
		echo "Adding file: '$fullFileToAdd'"
		encrypt_file "$fullFileToAdd"
	done
}

# --- Argument Parsing using getopts ---
while getopts "EDs:d:h" opt; do
	case ${opt} in
	E)
		if [[ -n "$MODE" ]]; then
			echo -e "${ERR_COLOR}Error:${NC} Cannot specify both -E and -D. Choose one mode."
			usage
		fi
		MODE="$ENCRYPT"
		;;
	D)
		if [[ -n "$MODE" ]]; then
			echo -e "${ERR_COLOR}Error:${NC} Cannot specify both -E and -D. Choose one mode."
			usage
		fi
		MODE="$DECRYPT"
		;;
	s)
		DECRYPT_DIR=$(realpath "$OPTARG")
		;;
	d)
		ENCRYPT_DIR=$(realpath "$OPTARG")
		;;
	p)
		PASS_FILE=$(realpath "$OPTARG")
		;;
	h)
		usage
		;;
	\?) # Invalid option
		echo -e "${ERR_COLOR}Error:${NC} Invalid option: -$OPTARG"
		usage
		;;
	:) # Missing argument for an option
		echo "${ERR_COLOR}Error:${NC} Option -$OPTARG requires an argument."
		usage
		;;
	esac
done
shift $((OPTIND - 1)) # Shift positional parameters

# --- Validate Arguments ---
if [[ -z "$MODE" ]]; then
	echo -e "${ERR_COLOR}Error:${NC} You must specify either -E (encrypt) or -D (decrypt) mode."
	usage
fi

if [[ -z "$DECRYPT_DIR" ]]; then
	echo -e "${WAR_COLOR}Warning:${NC} Decrypted directory not specified. Using default: ${DEFAULT_DECRYPT_DIR}"
	DECRYPT_DIR="${DEFAULT_DECRYPT_DIR}"
fi

if [[ -z "$ENCRYPT_DIR" ]]; then
	echo -e "${WAR_COLOR}Warning:${NC} Encrypted directory not specified. Using default: ${DEFAULT_ENCRYPT_DIR}"
	ENCRYPT_DIR="${DEFAULT_ENCRYPT_DIR}"
fi

if [[ -z "$PASS_FILE" ]]; then
	if [[ -z "$DEFAULT_PASS_FILE" ]]; then
		echo -e "${ERR_COLOR}Error:${NC} Password file not specified and no default provided."
		exit 1
	else
		echo -e "${WAR_COLOR}Warning:${NC} Password file not specified. Using default: ${DEFAULT_PASS_FILE}"
		PASS_FILE="${DEFAULT_PASS_FILE}"
	fi
fi

if [[ ! -d "$DECRYPT_DIR" ]]; then
	echo -e "${ERR_COLOR}Error:${NC} Decrypted directory '$DECRYPT_DIR' does not exist or is not a directory."
	exit 1
fi

if [[ ! -d "$ENCRYPT_DIR" ]]; then
	echo -e "${ERR_COLOR}Error:${NC} Encrypted directory '$ENCRYPT_DIR' does not exist or is not a directory."
	exit 1
fi

if [[ ! -f "$PASS_FILE" ]]; then
	echo -e "${ERR_COLOR}Error:${NC} Password file '$PASS_FILE' does not exist or is not a file."
	exit 1
fi

# Prevent operations that might overwrite source files unexpectedly
if [[ "$DECRYPT_DIR" == "$ENCRYPT_DIR" ]]; then
	echo -e "${ERR_COLOR}Error:${NC} Encrypt directory cannot be the same as the decrypt directory."
	exit 1
fi

if [[ "$ENCRYPT_DIR" == "$DECRYPT_DIR"/* ]]; then
	echo -e "${WAR_COLOR}Warning:${NC} Encrypt directory is a subdirectory of the decrypt directory. We will try to ignore it's content best-effort during the encryption"
fi

if [[ "$DECRYPT_DIR" == "$ENCRYPT_DIR"/* ]]; then
	echo -e "${WAR_COLOR}Warning:${NC} Decrypt directory is a subdirectory of the encrypt directory. We will try to ignore it's content best-effort during the encryption. However, keep in mind that the tool intends to help you encrypt and decrypt files for git storage, so you might accidentally commit uncecrypted files."
fi

echo "Configuration for $MODE:"
echo -e "\tDECRYPT_DIR='$DECRYPT_DIR'"
echo -e "\tENCRYPT_DIR='$ENCRYPT_DIR'"
echo -e "\tPASS_FILE='$PASS_FILE'"

if [[ "$MODE" == "$ENCRYPT" ]]; then
	echo "Encrypting files"
	tmp_directory=$(mktemp -d)
	echo "Decrypting the files into tmp directory '$tmp_directory'"
	decrypt_files "$tmp_directory"
	echo "Decryption into '$tmp_directory' done."
	echo "Comparing the directories of '$DECRYPT_DIR' and '$tmp_directory' to find the files to update."

	remove_files "$DECRYPT_DIR" "$tmp_directory"
	update_files "$DECRYPT_DIR" "$tmp_directory"
	add_files "$DECRYPT_DIR" "$tmp_directory"

	echo "Removing '$tmp_directory'..."
	rm -r $tmp_directory
elif [[ "$MODE" == "$DECRYPT" ]]; then
	decrypt_files "$DECRYPT_DIR"
fi

# $file_num counting doesn't work for some reason
echo "Done. Processed ${file_num} files."
