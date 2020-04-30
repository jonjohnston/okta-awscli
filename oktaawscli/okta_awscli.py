""" Wrapper script for awscli which handles Okta auth """
# pylint: disable=C0325,R0913,R0914
import os
import datetime
from subprocess import call
import logging
import click
from oktaawscli.version import __version__
from oktaawscli.okta_auth import OktaAuth
from oktaawscli.okta_auth_config import OktaAuthConfig
from oktaawscli.aws_auth import AwsAuth

def _serialize_if_needed(value, iso=False):
    if isinstance(value, datetime.datetime):
        if iso:
            return value.isoformat()
        return value.strftime('%Y-%m-%dT%H:%M:%SZ')
    return value

def get_credentials(aws_auth, okta_profile, profile,
                    verbose, logger, totp_token, cache):
    """ Gets credentials from Okta """

    okta_auth_config = OktaAuthConfig(logger)
    okta = OktaAuth(okta_profile, verbose, logger, totp_token, okta_auth_config)

    _, assertion = okta.get_assertion()
    if verbose:
        print("Getting aliases can take time")
    print("Please wait while role list generated")
    role = aws_auth.choose_aws_role(assertion)
    principal_arn, role_arn = role

    okta_auth_config.save_chosen_role_for_profile(okta_profile, role_arn)
    duration = okta_auth_config.duration_for(okta_profile)

    sts_token = aws_auth.get_sts_token(
        role_arn,
        principal_arn,
        assertion,
        duration=duration,
        logger=logger
    )
    access_key_id = sts_token['AccessKeyId']
    secret_access_key = sts_token['SecretAccessKey']
    session_token = sts_token['SessionToken']
    session_token_expiry = sts_token['Expiration']
    logger.info("Session token expires on: %s" % session_token_expiry)
    if not profile:
        exports = console_output(access_key_id, secret_access_key,
                                 session_token, session_token_expiry, verbose)
        if cache:
            cache = open("%s/.okta-credentials.cache" %
                         (os.path.expanduser('~'),), 'w')
            cache.write(exports)
            cache.close()
        exit(0)
    else:
        print("Not permitted to output to file")
        sys.exit()
        #aws_auth.write_sts_token(profile, access_key_id,
        #                         secret_access_key, session_token)


def console_output(access_key_id, secret_access_key, session_token, session_expiry, verbose):
    """ Outputs STS credentials to console """
    if verbose:
        print("Use these to set your environment variables:")
    expire_date = _serialize_if_needed(session_expiry)
    exports = "\n".join([
        "{",
        "    \"AccessKeyId\":\"%s\"," % access_key_id,
        "    \"SecretAccessKey\":\"%s\"," % secret_access_key,
        "    \"SessionToken\":\"%s\"," % session_token,
        "    \"Expiration\":\"%s\"" % expire_date,
        "}"
    ])
    print(exports)

    return exports


# pylint: disable=R0913
@click.command()
@click.option('-v', '--verbose', is_flag=True, help='Enables verbose mode')
@click.option('-V', '--version', is_flag=True,
              help='Outputs version number and exits')
@click.option('-d', '--debug', is_flag=True, help='Enables debug mode')
@click.option('-f', '--force', is_flag=True, help='Forces new STS credentials. \
Skips STS credentials validation.')
@click.option('--okta-profile', help="Name of the profile to use in .okta-aws. \
If none is provided, then the default profile will be used.\n")
@click.option('--profile', help="Name of the profile to store temporary \
credentials in ~/.aws/vault-credentials. If profile doesn't exist, it will be \
created. If omitted, credentials will output to console.\n")
@click.option('-c', '--cache', is_flag=True, help='Cache the default profile credentials \
to ~/.okta-credentials.cache\n')
@click.option('-t', '--token', help='TOTP token from your authenticator app')
@click.option('-l', '--lookup', is_flag=True, help='Look up AWS account names')
@click.argument('awscli_args', nargs=-1, type=click.UNPROCESSED)
def main(okta_profile, profile, verbose, version,
         debug, force, cache, lookup, awscli_args, token):
    """ Authenticate to awscli using Okta """
    if version:
        print(__version__)
        exit(0)
    # Set up logging
    logger = logging.getLogger('okta-awscli')
    logger.setLevel(logging.DEBUG)
    handler = logging.StreamHandler()
    handler.setLevel(logging.WARN)
    formatter = logging.Formatter('%(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    if verbose:
        handler.setLevel(logging.INFO)
    if debug:
        handler.setLevel(logging.DEBUG)
    logger.addHandler(handler)

    if not okta_profile:
        okta_profile = "default"
    aws_auth = AwsAuth(profile, okta_profile, lookup, verbose, logger)
    if not aws_auth.check_sts_token(profile) or force:
        if force and profile:
            logger.info("Force option selected, \
                getting new credentials anyway.")
        elif force:
            logger.info("Force option selected, but no profile provided. \
                Option has no effect.")
        get_credentials(
            aws_auth, okta_profile, profile, verbose, logger, token, cache
        )

    if awscli_args:
        cmdline = ['aws', '--profile', profile] + list(awscli_args)
        logger.info('Invoking: %s', ' '.join(cmdline))
        call(cmdline)


if __name__ == "__main__":
    # pylint: disable=E1120
    main()
    # pylint: enable=E1120
