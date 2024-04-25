if [[ -z "${CODE_SIGN_TOOL_PATH}" ]]; then
 java -jar ./jar/code_sign_tool-1.3.0.jar "$@"
else
 java -jar ${CODE_SIGN_TOOL_PATH}/jar/code_sign_tool-1.3.0.jar "$@"
fi
