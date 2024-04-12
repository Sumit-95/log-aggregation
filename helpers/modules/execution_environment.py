"""Provides execution environments for subprocess calls reliant on Cloud variables"""

import logging
import os

import boto3
import adfs # pylint: disable=import-error

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.DEBUG)


class AWSEnvironment():
    """Class for required ADFS AWS Authentication"""

    def __init__(self, username, password, role, switch_role, region): #noqa
        self.username = username
        self.password = password
        self.role = role
        self.switch_role = switch_role
        self.region = region

    def get_aws_tokens(self, session_name=None):
        """A function to generate AWS timed tokens using the ADFS user/pass stored
        in Jenkins for the role specified
        """
        tokens = adfs.getToken(username=self.username,
                               password=self.password,
                               roleName=self.role,
                               region=self.region)

        if self.switch_role:
            try:
                client = boto3.client(
                    'sts', region_name=self.region,
                    aws_access_key_id=tokens['Credentials']['AccessKeyId'],
                    aws_secret_access_key=tokens['Credentials']['SecretAccessKey'],
                    aws_session_token=tokens['Credentials']['SessionToken']
                )
                tokens = client.assume_role(
                    RoleArn=self.switch_role, RoleSessionName=session_name
                )
            except Exception as err:
                LOGGER.error(err)
                raise

        execution_environment = {
            'AWS_ACCESS_KEY_ID': tokens['Credentials']['AccessKeyId'],
            'AWS_SECRET_ACCESS_KEY': tokens['Credentials']['SecretAccessKey'],
            'AWS_SESSION_TOKEN': tokens['Credentials']['SessionToken'],
            'AWS_DEFAULT_REGION': self.region
        }
        execution_environment.update(os.environ)

        return execution_environment
