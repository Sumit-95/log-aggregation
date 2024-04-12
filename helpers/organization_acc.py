""" A python module to facilitate the aws switch role function."""

# None Standard Libraries
import boto3
from .modules import execution_environment


def get_organization_accs(username, password, role, region, switch_role=None):
    """A function to rerurn a list of AWS accounts from the AWS Organizations
    servce.

    Arguments:
        username (str): ADFS service account username.
        password (str): ADFS service account password.
        role (str): Aws ADFS IAM role.
        region (str): Aws region.

    Keyword Arguments:
        switch_role (str): The account to switch into.

    Returns:
        (list): A list of AWS Accounts.
    """

    aws_env = execution_environment.AWSEnvironment(username,
                                                   password,
                                                   role,
                                                   switch_role,
                                                   region
                                                   )
    env = aws_env.get_aws_tokens(session_name='389715306404')

    client = boto3.client(
        'organizations',
        aws_access_key_id=env['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key=env['AWS_SECRET_ACCESS_KEY'],
        aws_session_token=env['AWS_SESSION_TOKEN']
    )

    list_accounts = []
    paginator = client.get_paginator('list_accounts')
    page_iterator = paginator.paginate()
    for page in page_iterator:
        list_accounts = list_accounts + page['Accounts']
    return list_accounts


def get_account_id(name, username, password, role, region):
    """A function to match the provided account name with an account id from the
    passed in list from get_organization_accs

    Arguments:
        name (str): A provided AWS account name.
        username (str): ADFS service account username.
        password (str): ADFS service account password.
        role (str): Aws ADFS IAM role.
        region (str): Aws region.

    Returns:
        (str): The matching account ID of the provided name.
    """

    list_accounts = get_organization_accs(username, password, role, region)

    account_id = ""
    for account in list_accounts:
        if name.upper() == account['Name']:
            account_id = account["Id"]
            break
    return account_id