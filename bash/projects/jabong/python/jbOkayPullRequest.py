"""
    http://jira-python.readthedocs.org/en/latest/
    http://jira-python.readthedocs.org/en/latest/
    This will Okay a Pull Request.
"""

import sys
import os
# import json
import ConfigParser
import re

from jira.client import JIRA
from github3 import GitHub

from pprint import pprint

def printSeparator():
    print '#' * 100

def extractIssueKey(issueKey):
    p = re.compile('\w+-\d+')
    issueKey = p.findall(issueKey)
    return issueKey[0]

config = ConfigParser.ConfigParser()
configPath = os.path.dirname(os.path.dirname(__file__))
# print 'configPath: ' + configPath
config.readfp(open(configPath + '/jbCommonBashVars.ini'))

jiraServer = config.get('jira', 'serverUrl')

jiraOptions = {
    'server': jiraServer
}
jiraUser = config.get('jira', 'user')
jiraPassword = config.get('jira', 'password')

jira = JIRA(jiraOptions)

jira = JIRA(options=jiraOptions, basic_auth=(jiraUser, jiraPassword))

# Get all projects viewable by anonymous users.
# projects = jira.projects()

# print(projects)

# Sort available project keys, then return the second, third, and fourth keys.
# keys = sorted([project.key for project in projects])[2:5]

# Get an issue.
# issue = jira.issue('INDFAS-14134')

# Set Defaults.
projectKey = config.get('jira', 'projectMobile')
projectKey = config.get('jira', 'projectPortal')
repositoryName = config.get('github', 'repository')

githubUser = config.get('github', 'user')
githubPassword = config.get('github', 'password')
githubOwner = config.get('github', 'owner')
githubRepository = config.get('github', 'repository')

if len(sys.argv) > 1:
    pullRequestId = sys.argv[1]
else:
    pullRequestId = raw_input("Enter the Pull Request number: ")

if len(sys.argv) > 2:
    repositoryName = sys.argv[2]

# Project Key for JIRA
if len(sys.argv) > 3:
    projectKey = sys.argv[3]

# Get the Pull Request Information
gho = GitHub(githubUser, githubPassword)
oPullRequest = gho.pull_request(githubOwner, githubRepository, str(pullRequestId))
oGithubIssue = gho.issue(githubOwner, githubRepository, str(pullRequestId))
branchName = oPullRequest.head.ref
revisionNo = oPullRequest.head.sha
issueKey = extractIssueKey(branchName)

print "Issue Key is", issueKey

# oGitHub = GitHub(githubUser, githubPassword)

issue = jira.issue(issueKey)
print "Information about Issue:", issueKey
print 'summary:', issue.fields.summary
print 'Reporter:', issue.fields.reporter.name
print 'Assignee:', issue.fields.assignee.name
print 'Description:', issue.fields.description

issueSummary = issue.fields.summary
issueInfo = {
    'summary': issue.fields.summary,
    'assignee': issue.fields.assignee,
    'description': issue.fields.description
}

# Get all projects viewable by anonymous users.
# issues = jira.search_issues('assignee="bijay.rungta"')

commitUrl = 'https://github.com/jabong/' + repositoryName + '/commit/' + revisionNo
githubBranchUrl = 'https://github.com/jabong/' + repositoryName + '/tree/' + branchName
pullRequestUrl = 'https://github.com/jabong/' + repositoryName + '/pull/' + pullRequestId
jiraIssueUrl = jiraServer + '/browse/' + issueKey

strComment = 'h3. {color:green}Code Review @ revision ' + revisionNo + '{color}'
strComment += '\n{color:green}Code is OK @ revision [' + revisionNo + '|' + commitUrl + '] in GitHub{color}'
strComment += '\nBranch @ GitHub: ' + githubBranchUrl
strComment += '\nPull Request can be seen at ' + pullRequestUrl

githubPullRequestCommentBody = '### Code is Ok @ Revision ' + revisionNo
githubPullRequestCommentBody += '\nJira Issue: ' + jiraIssueUrl
githubPullRequestCommentBody += '\nBranch @ GitHub: ' + githubBranchUrl

print "================ Adding Comment to JIRA ====================="
print strComment
jira.add_comment(issue, strComment)
print "================ Added Comment ============================="

print "================ Adding Comment to GitHub Pull Request ====================="
print githubPullRequestCommentBody
oGithubIssue.create_comment(body = githubPullRequestCommentBody)
print "================ Added Comment ============================="

# Verify if the Comment was added successfully
updatedIssue = jira.issue(issueKey)
print "====== Comment Added: ========"
print updatedIssue.fields.comment.comments[updatedIssue.fields.comment.total - 1].body

print "====== Issue Url: ========"
print jiraIssueUrl

print "====== Comment for Pull Request: ========"
print githubPullRequestCommentBody

markAsReadyForQA = raw_input("Mark as Ready for QA? y/n: ")
if markAsReadyForQA == 'y' :
   # 191: Ready for QA (Testsystem)
   newAssignee = raw_input("New Assignee? Type 's' to skip: ")
   meta = jira.editmeta(issue)
   transitions = jira.transitions(issue)
   if newAssignee != 's':
       jira.transition_issue(issue, '191', assignee={'name': newAssignee}, resolution={'id': '1'})
   else :
       jira.transition_issue(issue, '191', resolution={'id': '1'})

   print "====== Issue status changed to 'Ready for QA (Testsystem)': ========"


# print(issues)
