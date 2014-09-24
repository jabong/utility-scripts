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

ideaFile = '/Users/bijay/projects/jabong/patches/App_Ideas.csv'
revisedIdeaFile = '/Users/bijay/projects/jabong/patches/App_Ideas_JIRA.csv';

index = 0;
with open(ideaFile, 'rb') as csvfile:
    csvreader = csv.reader(csvfile, delimiter=',', quotechar='"')
    for idea in csvreader:
        index += 1;
        if index <= 1:
            with open(revisedIdeaFile, 'ab') as revisedFile:
                csvwriter = csv.writer(revisedFile, delimiter=',',
                                        quotechar='"', quoting=csv.QUOTE_MINIMAL)
                csvwriter.writerow([idea[0], 'JIRA'] + idea[1:])
            continue;
        printSeparator()
        issueDescription = idea[1] = cleanString(idea[1])
        idea[2] = cleanString(idea[2])
        issueSummary = issueDescription.split('\n')
        issueSummary = issueSummary[0][0:250]
        if idea[2] != '':
            issueDescription += '\n\n' + '=' * 100 + '\n' + idea[2]
        issue = {
            "project": {
              "id": str(projectIdMobile)
            },
            "summary": issueSummary,
            "description": issueDescription,
            "issuetype": {
              "id": "6" # Story
            },
            "components": [{
                "name": "Mobile Ideas"
            }]
        }
        pprint(issue)

        jiraIssue = jira.create_issue(fields = issue)
        jiraIssueKey = jiraIssue.key

        ideaWithJira = [idea[0], jiraIssueKey] + idea[1:]

        pprint(ideaWithJira)

        with open(revisedIdeaFile, 'ab') as revisedFile:
            csvwriter = csv.writer(revisedFile, delimiter=',',
                                    quotechar='"', quoting=csv.QUOTE_MINIMAL)
            csvwriter.writerow([idea[0], jiraIssueKey] + idea[1:])
