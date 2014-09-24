"""
    http://jira-python.readthedocs.org/en/latest/
    http://jira-python.readthedocs.org/en/latest/
    editmeta
"""
# This script shows how to use the client in anonymous mode
# against jira.atlassian.com.
import sys
import os
import csv
import re
# import json
# import github3
import ConfigParser

from jira.client import JIRA
from github3 import GitHub
from pprint import pprint

def printSeparator():
    print '#' * 100

def cleanString(str):
    str = str.strip()
    str = str.replace(' ,', ',')
    str = str.replace(' :', ':')
    str = str.replace('i.e.', 'i.e,')

    return str

config = ConfigParser.ConfigParser()
configPath = os.path.dirname(os.path.dirname(__file__))
config.readfp(open(configPath + '/jbCommonBashVars.ini'))

jiraServer = config.get('jira', 'serverUrl')
jiraUser = config.get('jira', 'user')
jiraPassword = config.get('jira', 'password')
projectKeyMobile = config.get('jira', 'projectMobile')
projectIdMobile = config.get('jira', 'projectIdMobile')
projectKey = config.get('jira', 'projectMobile')
projectKey = config.get('jira', 'projectPortal')
repositoryName = config.get('github', 'repository')

githubUser = config.get('github', 'user')
githubPassword = config.get('github', 'password')
githubOwner = config.get('github', 'owner')
githubRepository = config.get('github', 'repository')

jiraOptions = {
    'server': jiraServer
}

jira = JIRA(jiraOptions)

jira = JIRA(options=jiraOptions, basic_auth=(jiraUser, jiraPassword))
