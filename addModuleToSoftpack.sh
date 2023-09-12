#!/bin/bash

set -euo pipefail;

help() {
	echo "Usage: $0 [-u] path_to_module_file module_load_path environment_path" >&2;
	echo;
	echo "  -u: Update existing environment instead of creating it."
	echo;
	echo "The SOFTPACK_CORE_URL environmental variable must be set to the graphql endpoint for Softpack Core."
	exit 1;
}

declare mutationName="createFromModule";
declare successType="CreateEnvironmentSuccess";
declare failType="EnvironmentAlreadyExistsError";

if [ $# -gt 0 -a $1 = "-u" ]; then
	mutationName="updateFromModule";
	successType="UpdateEnvironmentSuccess";
	failType="EnvironmentNotFoundError";

	shift;
fi;

if [ $# -lt 3 ]; then
	help;
fi;

if [ ! -v "SOFTPACK_CORE_URL" ]; then
	help;
fi;

declare url=${SOFTPACK_CORE_URL};
declare modFilePath="$(realpath "$1")";
declare modPath="$2";
declare envPath="$3";

if [ -z "$modPath" -o ! -f "$modFilePath" -o -z "$envPath" ]; then
	help;
fi;

module load "$modPath" &> /dev/null || {
	echo "Error: module $modPath does not exist." >&2;

	exit 1;
}

declare graphQL="$(while read line; do echo -n "$line\n";done <<HEREDOC
mutation (\\\$file: Upload!, \\\$modulePath: String!, \\\$envPath: String!) {
	$mutationName(
		file: \\\$file
		modulePath: \\\$modulePath
		environmentPath: \\\$envPath
	) {
		... on $successType {
			message
		}
		... on InvalidInputError {
			message
		}
		... on $failType {
			message
			path
			name
		}
	}
}
HEREDOC
)";

curl "$url" -F operations="{ \"query\": \"$graphQL\", \"variables\": {\"file\": null, \"modulePath\": \"\", \"envPath\": \"\"} }" -F map='{ "0": ["variables.file"], "1": ["variables.modulePath"], "2": ["variables.envPath"] }' -F 0=@$modFilePath -F 1="$modPath" -F 2="$envPath";
echo;
