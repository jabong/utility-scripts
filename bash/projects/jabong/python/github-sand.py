"""
    http://github3py.readthedocs.org/en/latest
"""
# This script shows how to use the client in anonymous mode
# against jira.atlassian.com.
import sys
import os
# import json
import github3
import ConfigParser

config = ConfigParser.ConfigParser()

configPath = os.path.dirname(os.path.dirname(__file__))
config.readfp(open(configPath + '/jbCommonBashVars.ini'))

githubUser = config.get('github', 'user')
githubPassword = config.get('github', 'password')
githubOwner = config.get('github', 'owner')
githubRepository = config.get('github', 'repository')
projectKey = config.get('jira', 'projectPortal')

gh = github3.login(githubUser, githubPassword)