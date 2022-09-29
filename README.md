![logo](https://d1smxttentwwqu.cloudfront.net/wp-content/uploads/2019/04/ssl-logo.png)

[![GitHub Actions Status](https://github.com/SSLcom/ci-images/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/SSLcom/ci-images)

# What is CodeSignTool?

CodeSignTool is a secure, privacy-oriented multi-platform Java command line utility for remotely signing Microsoft Authenticode and Java code objects with eSigner EV code signing certificates. Hashes of the files are sent to SSL.com for signing so that the code itself is not sent. This is ideal where sensitive files need to be signed, but should not be sent over the wire for signing. CodeSignTool is also ideal for automated batch processes for high volume signings or integration into existing CI/CD pipeline workflows.

For more information and related downloads for CodeSignTool, please visit <https://www.ssl.com/guide/esigner-codesigntool-command-guide>.

</br>

# How to use this image

## Command options
The supported commands are:

```console
$ docker run -it --rm --env-file .env ghcr.io/sslcom/codesigner:latest --help

Run CodeSigner
Running ESigner.com CodeSign Action

Usage: CodeSignTool [-hV] [COMMAND]
  -h, --help      Show this help message and exit.
  -V, --version   Print version information and exit.
Commands:
  get_credential_ids  Returns list of credential IDs associated with the user
  credential_info     Returns signing credential information
  sign                Sign code
  hash                Pre-compute hash(es) to sign
  batch_sign_hash     Batch sign of pre-computed hash(es)
  batch_sign          Batch sign
  sign_hash           Sign the hash(es)
  get_certs           Returns the certificate chain
```

## 1-) get_credential_ids
It outputs the list of eSigner credential IDs associated with a particular user.

```console
$ docker run -it --rm --env-file .env ghcr.io/sslcom/codesigner:latest get_credential_ids --help

Run CodeSigner
Running ESigner.com CodeSign Action

Usage: CodeSignTool get_credential_ids [-hV] -password=<password>
                                       -username=<username>
Returns list of credential IDs associated with the user
  -h, --help                 Show this help message and exit.
      -password=<password>   RA password
      -username=<username>   RA username
  -V, --version              Print version information and exit.
```
### Example:
```console
$ docker run -it --rm --env-file .env ghcr.io/sslcom/codesigner:latest get_credential_ids

Run CodeSigner
Running ESigner.com CodeSign Action

Credential ID(s):
- 8b072e22-7685-4771-b5c6-48e46614915f
```

## 2-) credential_info
It outputs the list of eSigner credential IDs associated with a particular user.

```console
$ docker run -it --rm --env-file .env ghcr.io/sslcom/codesigner:latest credential_info --help

Run CodeSigner
Running ESigner.com CodeSign Action

Usage: CodeSignTool credential_info [-hV] -credential_id=<credentialId>
                                    -password=<password> -username=<username>
Returns signing credential information
      -credential_id=<credentialId>
                             Credential ID
  -h, --help                 Show this help message and exit.
      -password=<password>   RA password
      -username=<username>   RA username
  -V, --version              Print version information and exit.
```
### Example:
```console
$ docker run -it --rm --env-file .env ghcr.io/sslcom/codesigner:latest credential_info

Run CodeSigner
Running ESigner.com CodeSign Action

EVCS Certificate Subject Information:
- Subject DN: OID.1.3.6.1.4.1.311.60.2.1.3=US, OID.1.3.6.1.4.1.311.60.2.1.2=Texas, OID.2.5.4.15=Private Organization, CN=Esigner LLC, SERIALNUMBER=123456, OU=Cloud Signing Demo, O=Esigner LLC, L=HOUSTON, ST=United States, C=US
- Certificate Expiry: Wed Jun 28 16:34:31 UTC 2023
- Issuer DN: CN=SSL.com EV Code Signing Intermediate CA RSA R2, O=SSL Corp, L=Houston, ST=Texas, C=US
```

## 3-) sign
It signs and timestamps the code. In case only one valid credential ID is available, the sign option defaults to that without requiring the -credential_id option. In case there are multiple credential IDs for the same user, the sign command shows all the credential ids associated with the user. User can then choose which one to use. If totp secret is passed in command line, then it computes the OTP value internally otherwise asks the user to enter the OTP value.

```console
$ docker run -it --rm --env-file .env ghcr.io/sslcom/codesigner:latest sign --help

Run CodeSigner
Running ESigner.com CodeSign Action

Usage: CodeSignTool sign [-hV] [-override] [-credential_id=<credentialId>]
                         -input_file_path=<inputFilePath>
                         [-output_dir_path=<outputDirPath>]
                         -password=<password> [-program_name=<programName>]
                         [-totp_secret=<totpSecret>] -username=<username>
Sign code
      -credential_id=<credentialId>
                             Credential ID
  -h, --help                 Show this help message and exit.
      -input_file_path=<inputFilePath>
                             Path of the code object to be signed
      -output_dir_path=<outputDirPath>
                             Directory where signed code object will be written
      -override              Overrides the input file after signing, if this
                               parameter is set and no -output_dir_path
                               parameter
      -password=<password>   RA password
      -program_name=<programName>
                             Program name
      -totp_secret=<totpSecret>
                             TOTP secret
      -username=<username>   RA username
  -V, --version              Print version information and exit.
```
### Example:
```console
$ docker run -it --rm --env-file .env ghcr.io/sslcom/codesigner:latest sign -input_file_path=/codesign/examples/codesign.ps1 -output_dir_path=/codesign/output

Run CodeSigner
Running ESigner.com CodeSign Action

Code signed successfully: /codesign/output/codesign.ps1
```

## Environment Variables

#### `Sample Environment File`

```properties
USERNAME="SSL.com account username"
PASSWORD="SSL.com account password"
CREDENTIAL_ID="Credential ID for signing certificate"
TOTP_SECRET="OAuth TOTP Secret"
ENVIRONMENT_NAME="PROD"
```

### `USERNAME`

This variable is mandatory and specifies the SSL.com account username.

### `PASSWORD`

This variable is mandatory and specifies the SSL.com account password.

### `CREDENTIAL_ID`

Credential ID for signing certificate. If credential_id is omitted and the user has only one eSigner code signing certificate, CodeSignTool will default to that. If the user has more than one code signing certificate, this parameter is mandatory.

### `TOTP_SECRET`

OAuth TOTP Secret. You can access detailed information on https://www.ssl.com/how-to/automate-esigner-ev-code-signing

### `ENVIRONMENT_NAME`

These variables are optional, and specify the environment name. If omitted, the environment name will be set to `PROD` and use production code_sign_tool.properties file. For signing artifact with demo account, the environment name will be set to `TEST`.