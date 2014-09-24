"""
    http://jira-python.readthedocs.org/en/latest/
    http://jira-python.readthedocs.org/en/latest/
    editmeta
"""
# This script shows how to use the client in anonymous mode
# against jira.atlassian.com.
import sys
import os
# import json
# import github3
import ConfigParser

from jira.client import JIRA
from github3 import GitHub
from pprint import pprint

config = ConfigParser.ConfigParser()
configPath = os.path.dirname(os.path.dirname(__file__))
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
    issueNumber = sys.argv[1]
else:
    issueNumber = raw_input("Enter the Issue Number (e.g, 15295): ")

if len(sys.argv) > 2:
    revisionNo = sys.argv[2]
else:
    # Take Revision Number as input and add a Comment.
    revisionNo = raw_input("Enter the Revision Number (e.g, 8d1ff38): ")

if len(sys.argv) > 3:
    pullRequestId = sys.argv[3]
else:
    # Take Revision Number as input and add a Comment.
    pullRequestId = raw_input("Enter the Pull Request Id (e.g, 12): ")

# Project Key for JIRA
if len(sys.argv) > 4:
    projectKey = sys.argv[4]

issueKey = projectKey + '-' + issueNumber
print "Issue Key is", issueKey

# oGitHub = GitHub(githubUser, githubPassword)

issue = jira.issue(issueKey)

print "Information about Issue:", issueKey
print 'summary:', issue.fields.summary
print 'Reprter:', issue.fields.reporter.name
print 'assignee:', issue.fields.assignee.name
print 'description:', issue.fields.description

issueSummary = issue.fields.summary
issueInfo = {
    'summary': issue.fields.summary,
    'assignee': issue.fields.assignee,
    'description': issue.fields.description
}

# Get all projects viewable by anonymous users.
# issues = jira.search_issues('assignee="bijay.rungta"')

commitUrl = 'https://github.com/jabong/' + repositoryName + '/commit/' + revisionNo
branchUrl = 'https://github.com/jabong/' + repositoryName + '/tree/' + issueKey
pullRequestUrl = 'https://github.com/jabong/' + repositoryName + '/pull/' + pullRequestId
jiraIssueUrl = jiraServer + '/browse/' + issueKey

strComment = 'h3. {color:green}Code Review @ revision ' + revisionNo + '{color}'
strComment += '\n{color:green}Code is OK @ revision [' + revisionNo + '|' + commitUrl + '] in GitHub{color}'
strComment += '\nBranch @ GitHub: ' + branchUrl
strComment += '\nPull Request can be seen at ' + pullRequestUrl

githubPullRequestCommentBody = 'Code is Ok @ Revision ' + revisionNo
githubPullRequestCommentBody += '\nJira Issue can be seen at ' + jiraIssueUrl

githubPullRequestMergeCommitLog = issueKey + ' ' + issueSummary

print "Comment to be added: \n" + strComment
print "================ Adding Comment ============================="
jira.add_comment(issue, strComment)

# Verify if the Comment was added successfully
updatedIssue = jira.issue(issueKey)
print "====== Comment Added: ========"
print updatedIssue.fields.comment.comments[updatedIssue.fields.comment.total - 1].body

print "====== Issue Url: ========"
print jiraIssueUrl

print "====== Comment for Pull Request: ========"
print githubPullRequestCommentBody

#
#markAsReadyForQA = raw_input("Mark as Ready for QA? y/n: ")
#if markAsReadyForQA == 'y' :
#    # 191: Ready for QA (Testsystem)
#    newAssignee = raw_input("New Assignee? Type 's' to skip: ")
#    meta = jira.editmeta(issue)
#    transitions = jira.transitions(issue)
#    if newAssignee != 's':
#        jira.transition_issue(issue, '191', assignee={'name': newAssignee}, resolution={'id': '1'})
#    else :
#        jira.transition_issue(issue, '191', resolution={'id': '1'})
#
#    print "====== Issue status changed to 'Ready for QA (Testsystem)': ========"
#

# print(issues)
