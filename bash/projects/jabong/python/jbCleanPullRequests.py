"""
    http://github3py.readthedocs.org/en/latest
"""

import sys
import os
import json
import ConfigParser
import re

from github3 import GitHub
from pprint import pprint

from jira.client import JIRA

def printSeparator():
    print '#' * 100

def extractIssueKey(issueKey):
    p = re.compile('\w+-\d+')
    issueKey = p.findall(issueKey)
    return issueKey[0]

def jiraGetIssueInfo(issueKey, config):
    jiraServer = config.get('jira', 'serverUrl')

    jiraOptions = {
        'server': jiraServer
    }
    jiraUser = config.get('jira', 'user')
    jiraPassword = config.get('jira', 'password')

    # jira = JIRA(jiraOptions)

    jira = JIRA(options=jiraOptions, basic_auth=(jiraUser, jiraPassword))
    issue = jira.issue(issueKey)
    jira.create_issue()
    return issue

def fixPullRequestTitle(pullRequestId):
    gho = GitHub(githubUser, githubPassword)
    oPull = gho.pull_request(githubOwner, githubRepository, str(pullRequestId))
    branchName = oPull.head.ref
    issueKey = extractIssueKey(branchName)
    title = oPull.title
    foundIndex = title.find(issueKey)
    updateRequired = 0
    if foundIndex == 0:
        if issueKey == title:
            updateRequired = 1
            print 'Issue Key ' + issueKey + ' Found in Title but Update Required for ' + title
        else:
            print 'Issue Key ' + issueKey + ' found in Title for ' + title
            return
    else:
        updateRequired = 1
        print 'Issue Key ' + issueKey + ' NOT Found in Title for ' + title

    if updateRequired == 1:
        jiraIssue = jiraGetIssueInfo(issueKey, config)
        title = issueKey + ' ' + jiraIssue.fields.summary
        print title
        oPull.update(title)
        print 'Updated the Title for the Pull Request ' + oPull.html_url

# End of method fixPullRequestTitle

config = ConfigParser.ConfigParser()

configPath = os.path.dirname(os.path.dirname(__file__))
config.readfp(open(configPath + '/jbCommonBashVars.ini'))

githubUser = config.get('github', 'user')
githubPassword = config.get('github', 'password')
githubOwner = config.get('github', 'owner')
githubRepository = config.get('github', 'repository')
projectKey = config.get('jira', 'projectPortal')

if len(sys.argv) > 1:
    pullRequestId = sys.argv[1]
    try:
        fixPullRequestTitle(pullRequestId)
    except Exception, e:
        print e
else:
    pulls = json.load(open('/Users/bijay/projects/jabong/patches/pulls.json'))

    for pull in pulls:
        branchName = pull['head']['ref']
        pullRequestId = pull['number']
        strPullRequestId = str(pullRequestId)
        pullStatus = pull['state']
        pullTitle = pull['title']
        printSeparator()
        print "Processing for Pull# " + str(pullRequestId) + " @ Branch # " + branchName + " with Status: " + pullStatus
        # print(json.dumps(pull, indent=4, sort_keys=True))
        try:
            fixPullRequestTitle(pullRequestId)
        except Exception, e:
            print e
            pass
