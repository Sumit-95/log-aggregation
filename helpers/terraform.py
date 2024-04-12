#!/usr/bin/env python3
# -*- coding: utf-8 -*-

""" A python script to facilitate the deployment of Terraform on Jenkins
"""

# Standard Library
import os
import sys
import logging
import subprocess
import argparse
from subprocess import CalledProcessError

#pylint: disable=wrong-import-position
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), ".")))

#pylint: disable=import-error
from modules import execution_environment

# Constants

LOGGER = logging.getLogger()
"""Setting up logging
"""

# Setting debugging level
LOGGER.setLevel(logging.INFO)
logging.getLogger().addHandler(logging.StreamHandler(sys.stdout))

def execute_terraform(
    terraform_bin_path,
    username,
    password,
    role,
    wrk_dir,
    action,
    region,
    switch_role=None,
    backend_config=None,
    var_file=None,
    parallelism=True,
    tfvars=None
):
    """A function to manage the Plan and Apply of Terraform, based of user
    input in Jenkins.

    Arguments:
        terraform_bin_path (str): Terraform path.
        username (str): ADFS service account username.
        password (str): ADFS service account password.
        role (str): Aws ADFS IAM role.
        wrk_dir (str): Terraform working directory.
        action (str): Terraform action.
        region (str): Aws region.
        backend_config (list): List of backend config for terraform
        tfvars (dict): dict of key values to pass to terraform

    Keyword Arguments:
        switchRole (str): Whether to switch role or not
        parallelism (str): Whether to run concurrent Terraform operations or
                           not.

    Raises:
        CalledProcessError: Subprocess execution error.
    """
    aws_env = execution_environment.AWSEnvironment(
        username,
        password,
        role,
        switch_role,
        region
    )
    env = aws_env.get_aws_tokens(session_name="389715306404")

    commands = [terraform_bin_path, action]
    try:
        init_args = [terraform_bin_path, 'init']

        init_args.append('-lock-timeout=10m')

        if backend_config:
            for backend in backend_config:
                init_args.append(f'-backend-config={backend}')

        subprocess.run(init_args, cwd=wrk_dir, env=env, check=True)

        commands.append('-lock-timeout=10m')

        if var_file:
            commands.append('-var-file=' + var_file)

        if action != 'plan':
            commands.append('-auto-approve=true')

        if parallelism:
            commands.append('-parallelism=1')
        
        if tfvars:
            for item in tfvars.split(","):
                commands.append('-var=' + item)

        subprocess.run(commands, cwd=wrk_dir, env=env, check=True)

    except CalledProcessError as terraform_error:
        LOGGER.error("Error running:\n%s\nOutput:\n%s", terraform_error.cmd, terraform_error.stderr)
        raise

def argument_parser():
    """ The argparser for current module
    """
    main_parser = argparse.ArgumentParser(
        description='''
            '''
        )
    main_parser.add_argument('-t',
                            dest="tf_bin_path", action ="store", required=True,
                            type=str, help='Terraform bin path')
    main_parser.add_argument('-u',
                            dest="adfs_user_name", action ="store", required=True,
                            type=str, help='ADFS service account username')
    main_parser.add_argument('-p',
                            dest="adfs_password", action ="store", required=True,
                            type=str, help='ADFS service account password')
    main_parser.add_argument('-i',
                            dest="iam_role", action ="store", required=True,
                            type=str, help='Aws ADFS IAM role')
    main_parser.add_argument('-w',
                            dest="wrk_dir", action ="store", required=True,
                            type=str, help='Terraform working directory')
    main_parser.add_argument('-a',
                            dest="tf_action", action ="store", required=True,
                            type=str, help='Terraform action')
    main_parser.add_argument('-r',
                            dest="aws_region", action ="store", required=True,
                            type=str, help='AWS region')
    main_parser.add_argument('-s',
                            dest="switch_role", action ="store",
                            type=str, help='AWS Account switch IAM role')
    main_parser.add_argument('-b',
                            dest="backend_config", nargs="*", action ="store", required=True,
                            type=str, default=[], help='Terraform backend config')
    main_parser.add_argument('-v',
                            dest="var_file", action ="store", required=False,
                            type=str, default=None, help='Terraform command line variables')
    main_parser.add_argument('-l',
                            dest="parallelism", action ="store",
                            type=str, help='Terraform parallelism indicator')
    main_parser.add_argument('-n',
                            dest="tfvars", action ="store",
                            type=str, help='Terraform additional variables')
    input_args = main_parser.parse_args()

    return input_args

if __name__ == "__main__":

    args = argument_parser()
    if args.switch_role == 'COMMAND_ROLE_NO_SWITCH': args.switch_role = None

    execute_terraform(
        args.tf_bin_path,
        args.adfs_user_name,
        args.adfs_password,
        args.iam_role,
        args.wrk_dir,
        args.tf_action,
        args.aws_region,
        args.switch_role,
        args.backend_config,
        args.var_file,
        args.parallelism,
        args.tfvars
    )
