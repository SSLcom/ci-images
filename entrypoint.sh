#!/usr/bin/env bash
set -e

echo "Run CodeSigner"

echo "Running ESigner.com CodeSign Action"
echo ""

if [[ "$ENVIRONMENT_NAME" != "PROD" ]]; then
    cp /codesign/conf/code_sign_tool.properties /codesign/conf/code_sign_tool.properties.production
    cp /codesign/conf/code_sign_tool_demo.properties /codesign/conf/code_sign_tool.properties 
fi

# Exec the specified command or fall back on bash
if [ $# -eq 0 ]; then
    CMD=( "bash" )
else
    CMD=( "$@" )
fi

COMMAND="/usr/bin/codesign"

# CMD Args
COMMAND="$COMMAND ${CMD[@]}"

# Authentication Info
if [[ ! "${CMD[@]}" =~ .*"--help".* ]]; then
  [ ! -z $USERNAME ] && COMMAND="$COMMAND -username=$USERNAME"
  [ ! -z $PASSWORD ] && COMMAND="$COMMAND -password=\"$PASSWORD\""

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

RESULT=$(bash -c "set -e; $COMMAND")
if [[ "$RESULT" =~ .*"Error".* ]]; then
  echo "Something Went Wrong. Please try again."
  echo "$RESULT"
  exit 1
else
  echo "$RESULT"
fi

exit 0
