#!/bin/bash

set -euo pipefail;

help() {
	echo "Usage: $0 path_to_module_file module_load_path environment_path" >&2;
	exit 1;
}

if [ $# -lt 3 ]; then
	help;
fi;

declare url="http://127.0.0.1:8000/graphql";
declare modFilePath="$(realpath "$1")";
declare modPath="$2";
declare envPath="$3";

if [ -z "$modPath" -o ! -f "$modFilePath" -o -z "$envPath" ]; then
	help;
fi;

declare graphQL="$(while read line; do echo -n "$line\n";done <<HEREDOC
mutation (\\\$file: Upload!, \\\$modulePath: String!, \\\$envPath: String!) {
	createFromModule(
		file: \\\$file
		modulePath: \\\$modulePath
		environmentPath: \\\$envPath
	) {
		... on CreateEnvironmentSuccess {
			message
		}
		... on InvalidInputError {
			message
		}
		... on EnvironmentAlreadyExistsError {
			message
			path
			name
		}
	}
}
HEREDOC
)";

curl "$url" -F operations="{ \"query\": \"$graphQL\", \"variables\": {\"file\": null, \"modulePath\": \"\", \"envPath\": \"\"} }" -F map='{ "0": ["variables.file"], "1": ["variables.modulePath"], "2": ["variables.envPath"] }' -F 0=@$modFilePath -F 1="$modPath" -F 2="$envPath";