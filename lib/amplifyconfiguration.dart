const amplifyconfig = ''' {
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "us-east-1_oDBGh8hef",
            "AppClientId": "7e381s8r9gd2dntnuchems6epv",
            "Region": "us-east-1"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "socialProviders": [],
            "usernameAttributes": [
                "EMAIL"
            ],
            "signupAttributes": [
                "EMAIL"
            ],
            "passwordProtectionSettings": {
                "passwordPolicyMinLength": 8,
                "passwordPolicyCharacters": []
            },
            "mfaConfiguration": "OFF",
            "mfaTypes": [
                "SMS"
            ],
            "verificationMechanisms": [
                "EMAIL"
            ]
          }
        }
      }
    }
  }
}''';
