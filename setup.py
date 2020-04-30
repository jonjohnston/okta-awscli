from setuptools import setup, find_packages, os

here = os.path.abspath(os.path.dirname(__file__))
exec(open(os.path.join(here, 'oktaawscli/version.py')).read())

setup(
    name='okta-vault-awscli',
    version=__version__,
    description='Provides a wrapper for Okta authentication to awscli',
    packages=find_packages(),
    license='Apache License 2.0',
    author='Jonathan Johnston',
    author_email='jon.johnston@veeva.com',
    url='https://github.com/jonjohnston/okta-awscli',
    entry_points={
        'console_scripts': [
            'okta-vault-awscli=oktaawscli.okta_awscli:main',
        ],
    },
    install_requires=[
        'requests',
        'click',
        'bs4',
        'boto3',
        'ConfigParser',
        ],
    extras_require={
        'U2F': ['python-u2flib-host']
    },
)
