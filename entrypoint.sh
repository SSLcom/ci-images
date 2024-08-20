#!/usr/bin/env bash
set -e

echo "Run CodeSigner"

CURRENT_ENV="Production"
JVM_OPTS=$(echo "$JVM_OPTS" | tr -d '"')
ENVIRONMENT_NAME=$(echo "$ENVIRONMENT_NAME" | tr -d '"')
if [[ $ENVIRONMENT_NAME != "PROD" ]]; then
    cp /codesign/conf/code_sign_tool.properties /codesign/conf/code_sign_tool.properties.production
    cp /codesign/conf/code_sign_tool_demo.properties /codesign/conf/code_sign_tool.properties
    CURRENT_ENV="Sandbox"
fi

echo "Running ESigner.com CodeSign Action on $CURRENT_ENV [$JVM_OPTS]"
echo ""

# Exec the specified command or fall back on bash
if [ $# -eq 0 ]; then
    CMD=( "bash" )
else
    CMD=( "$@" )
fi

COMMAND="java ${JVM_OPTS} -jar ${CODE_SIGN_TOOL_PATH}/jar/code_sign_tool-1.3.1.jar"

# CMD Args
COMMAND="$COMMAND ${CMD[@]}"

# Authentication Info
if [[ ! "${CMD[@]}" =~ .*"--help".* ]]; then
  [ ! -z "$USERNAME" ] && COMMAND="$COMMAND -username=$(echo $USERNAME | awk '{gsub( /[(`$)]/, "\\\\&"); print $0}')"
  [ ! -z "$PASSWORD" ] && COMMAND="$COMMAND -password=$(echo $PASSWORD | awk '{gsub( /[(`$)]/, "\\\\&"); print $0}')"

  if [[ ! "${CMD[@]}" =~ .*"get_credential_ids".* ]]; then
      [ ! -z $CREDENTIAL_ID ] && COMMAND="${COMMAND} -credential_id=${CREDENTIAL_ID}"
      if [[ ! "${CMD[@]}" =~ .*"credential_info".* ]]; then
        [ ! -z $TOTP_SECRET ]  && COMMAND="${COMMAND} -totp_secret=${TOTP_SECRET}"
        [ ! -z $PROGRAM_NAME ] && COMMAND="${COMMAND} -program_name=${PROGRAM_NAME}"
        [ ! -z $FILE_PATH ]    && COMMAND="${COMMAND} -input_file_path=${FILE_PATH}"
        [ ! -z $OUTPUT_PATH ]  && COMMAND="${COMMAND} -output_dir_path=${OUTPUT_PATH}"
      fi
  fi
fi

RESULT=$(bash -c "set -e; $COMMAND 2>&1")
if [[ "$RESULT" =~ .*"Error".* || "$RESULT" =~ .*"Exception".* || "$RESULT" =~ .*"Missing required option".* || $RESULT =~ .*"Unmatched arguments from".* || $RESULT =~ .*"Unmatched argument".* || $RESULT =~ .*"Not a valid output directory".* ]]; then
  echo "Something Went Wrong. Please try again."
  echo "$RESULT"
  exit 1
else
  if [[ "${CMD[@]}" =~ .*"sign".* ]]; then
    LOG_USERNAME=$(echo $USERNAME | sed "s/\"//g")
    LOG_CREDENTIAL_ID=$(echo $CREDENTIAL_ID | sed "s/\"//g")
    echo "Code signed successfully by ${LOG_USERNAME} using ${LOG_CREDENTIAL_ID} credential id"
  fi
  echo "$RESULT"
fi

exit 0
