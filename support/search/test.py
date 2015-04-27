#!/usr/bin/env python

import wx
from agithub import Github
from collections import defaultdict
import webbrowser
from pprint import pprint

# Change this to use an Enterprise installation
GITHUB_HOST = 'github.com'

def credentials():
    """
    Tries to load GitHub credentials from Git's credential store.
    Returns a dictionary with all of the values returned, e.g.:
    {
        'host': 'github.com',
        'username': 'jim',
        'password': 's3krit'
    }
    Note that username and password will not be included if
    git-credential doesn't have any login information for github.com.
    """

    import os, subprocess
    creds = {}
    env = os.environ
    env['GIT_ASKPASS'] = 'true'
    p = subprocess.Popen(['git', 'credential', 'fill'],
                         stdout=subprocess.PIPE,
                         stdin=subprocess.PIPE,
                         stderr=subprocess.PIPE)
    stdout,stderr = p.communicate('host=github.com\n\n')
    for line in stdout.split('\n')[:-1]:
        k,v = line.split('=')
        creds[k] = v
    return creds

class LoginPanel(wx.Panel):
    def __init__(self, *args, **kwargs):
        self.callback = kwargs.pop('onlogin', None)
        wx.Panel.__init__(self, *args, **kwargs)
        sizer = wx.GridBagSizer(3,3)

        self.userLabel = wx.StaticText(self, label='Username:')
        self.userBox = wx.TextCtrl(self)
        self.passLabel = wx.StaticText(self, label='Password (or token):')
        self.passBox = wx.TextCtrl(self, style=wx.TE_PASSWORD)
        self.login = wx.Button(self, label='Login')
        self.Bind(wx.EVT_BUTTON, lambda x: self.doLogin(), self.login)

        self.error = wx.StaticText(self, label='')
        self.error.SetForegroundColour((200,0,0))

        sizer.Add(self.userLabel, pos=(0,0),
                  flag=wx.TOP | wx.LEFT | wx.BOTTOM, border=5)
        sizer.Add(self.userBox, pos=(0,1),
                  flag=wx.EXPAND | wx.LEFT | wx.RIGHT, border=5)
        sizer.Add(self.passLabel, pos=(1,0),
                  flag=wx.TOP | wx.LEFT | wx.BOTTOM, border=5)
        sizer.Add(self.passBox, pos=(1,1),
                  flag=wx.EXPAND | wx.LEFT | wx.RIGHT, border=5)
        sizer.Add(self.login, pos=(2,0), span=(1,2),
                  flag=wx.EXPAND | wx.LEFT | wx.RIGHT, border=5)
        sizer.Add(self.error, pos=(3,0), span=(1,2),
                  flag=wx.EXPAND | wx.LEFT | wx.RIGHT, border=5)

        sizer.AddGrowableCol(1)
        self.SetSizer(sizer)

    def doLogin(self):
        u = self.userBox.GetValue()
        p = self.passBox.GetValue()
        g = Github(u, p)
        status,data = g.issues.get()
        if status != 200:
            self.error.SetLabel('ERROR: ' + data['message'])
        elif callable(self.callback):
            self.callback(u, p)

class SearchResult(wx.Panel):
    def __init__(self, *args, **kwargs):
        self.result = kwargs.pop('result', defaultdict(str))
        self.callback = kwargs.pop('onclick', None)
        wx.Panel.__init__(self, *args, **kwargs)

        self.Bind(wx.EVT_LEFT_UP, self.onClick)

        titlestr = self.result['title']
        textstr = self.firstLine(self.result['body'])

        vbox = wx.BoxSizer(wx.VERTICAL)
        title = wx.StaticText(self, label=titlestr)
        titleFont = wx.Font(16, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_BOLD)
        title.SetFont(titleFont)
        text = wx.StaticText(self, label=textstr)

        vbox.Add(title, flag=wx.EXPAND | wx.BOTTOM, border=2)
        vbox.Add(text, flag=wx.EXPAND)

        self.SetSizer(vbox)

    def onClick(self, event):
        pprint(self.result)
        webbrowser.open(self.result['html_url'])

    def firstLine(self, body):
        return body.split('\n')[0].strip() or '(no body)'

class SearchResultsPanel(wx.PyScrolledWindow):
    def __init__(self, *args, **kwargs):
        results = kwargs.pop('results', [])
        wx.PyScrolledWindow.__init__(self, *args, **kwargs)

        vbox = wx.BoxSizer(wx.VERTICAL)
        for r in results:
            vbox.Add(SearchResult(self, result=r), flag=wx.TOP|wx.BOTTOM, border=8)

        self.SetSizer(vbox)
        self.SetScrollbars(0, 4, 0, 0)
        
class SearchPanel(wx.Panel):
    def __init__(self, *args, **kwargs):
        wx.Panel.__init__(self, *args, **kwargs)

        self.scrollPanel = None
        self.searchTerm = wx.TextCtrl(self, style=wx.TE_PROCESS_ENTER)
        searchButton = wx.Button(self, label="Search")

        searchButton.Bind(wx.EVT_BUTTON, self.DoSearch)
        self.searchTerm.Bind(wx.EVT_TEXT_ENTER, self.DoSearch)

        # Arrange the query box and "search" button horizontally
        hbox = wx.BoxSizer(wx.HORIZONTAL)
        hbox.Add(self.searchTerm, 1, wx.EXPAND)
        hbox.Add(searchButton, 0, wx.EXPAND | wx.LEFT, 5)

        # Stack the search group and the results panel vertically
        self.vbox = wx.BoxSizer(wx.VERTICAL)
        self.vbox.Add(hbox, 0, wx.EXPAND)
        
        self.SetSizer(self.vbox)

    def DoSearch(self, event):
        term = self.searchTerm.GetValue()
        g = Github(self.Parent.credentials['username'], self.Parent.credentials['password'])
        code,result = g.search.issues.get(q=term)
        self.setResults(result['items'])

    def setResults(self, results):
        if self.scrollPanel:
            self.scrollPanel.Destroy()
        self.scrollPanel = SearchResultsPanel(self, -1, results=results)
        # self.scrollPanel.SetBackgroundColour(wx.RED)
        self.vbox.Add(self.scrollPanel, 1, wx.EXPAND | wx.TOP, 5)
        self.vbox.Layout()

class SearchFrame(wx.Frame):
    def __init__(self, *args, **kwargs):
        self.panel = None
        
        kwargs.setdefault('size', (600,500))
        wx.Frame.__init__(self, *args, **kwargs)

        self.credentials = {}
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # Set up a menu. This is mainly for "Cmd-Q" behavior on OSX
        filemenu = wx.Menu()
        filemenu.Append(wx.ID_EXIT, '&Exit')
        menuBar = wx.MenuBar()
        menuBar.Append(filemenu, '&File')
        self.SetMenuBar(menuBar)

        # Two client panels
        self.login_panel = LoginPanel(self, onlogin=lambda u,p: self.login(u, p))
        self.sizer.Add(self.login_panel, 1, flag=wx.EXPAND | wx.ALL, border=20)
        self.search_panel = SearchPanel(self)
        self.sizer.Add(self.search_panel, 1, flag=wx.EXPAND | wx.ALL, border=20)
        self.sizer.Hide(self.search_panel)

        # Try to pre-load credentials from Git's cache
        self.credentials = credentials()
        if self.testCredentials():
            self.switchToSearchPanel()

        self.SetSizer(self.sizer)
        self.Show()

    def switchToSearchPanel(self):
        self.sizer.Hide(self.login_panel)
        self.sizer.Show(self.search_panel)
        self.Layout()

    def login(self, username, password):
        self.credentials['username'] = username
        self.credentials['password'] = password
        if self.testCredentials():
            self.switchToSearchPanel()

    def testCredentials(self):
        if 'username' not in self.credentials or 'password' not in self.credentials:
            return False
        g = Github(self.credentials['username'], self.credentials['password'])
        status,data = g.issues.get()
        if status != 200:
            print('bad credentials in store')
            return False
        return True

if __name__ == '__main__':
    app = wx.App(False)
    SearchFrame(None)
    app.MainLoop()