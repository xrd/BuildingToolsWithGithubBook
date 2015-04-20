#!/usr/bin/env python

import wx, subprocess, os
from agithub import Github

# Change this to use an Enterprise installation
GITHUB_HOST = 'github.com'

class LoginPanel(wx.Panel):
    def __init__(self, *args, **kwargs):
        self.callback = kwargs.pop('onlogin', None)
        wx.Panel.__init__(self, *args, **kwargs)
        sizer = wx.GridBagSizer(3,3)

        self.userLabel = wx.StaticText(self, label='Username:')
        self.userBox = wx.TextCtrl(self)
        self.passLabel = wx.StaticText(self, label='Password (or token):')
        self.passBox = wx.TextCtrl(self) #, style=wx.TE_PASSWORD)
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
        self.SetSizerAndFit(sizer)

    def doLogin(self):
        u = self.userBox.GetValue()
        p = self.passBox.GetValue()
        g = Github(u, p)
        status,data = g.issues.get()
        if status != 200:
            self.error.SetLabel('ERROR: ' + data['message'])
        elif callable(self.callback):
            self.callback(u, p)

class SearchPanel(wx.Panel):
    def __init__(self, *args, **kwargs):
        wx.Panel.__init__(self, *args, **kwargs)
        wx.StaticText(self, label='search panel')

class SearchFrame(wx.Frame):
    def __init__(self, *args, **kwargs):
        self.panel = None
        
        kwargs.setdefault('size', (600,500))
        wx.Frame.__init__(self, *args, **kwargs)

        self.credentials = {}
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # Set up a menu. We only need the "exit" item
        filemenu = wx.Menu()
        filemenu.Append(wx.ID_EXIT, '&Exit')
        menuBar = wx.MenuBar()
        menuBar.Append(filemenu, '&File')
        self.SetMenuBar(menuBar)

        # Two client panels
        self.login_panel = LoginPanel(self, onlogin=lambda u,p: self.login(u, p))
        self.sizer.Add(self.login_panel, flag=wx.EXPAND | wx.ALL, border=20)
        self.search_panel = SearchPanel(self)
        self.sizer.Add(self.search_panel, flag=wx.EXPAND | wx.ALL, border=20)
        self.sizer.Hide(self.search_panel)

        # Try to pre-load credentials from Git's cache
        self.loadCredentials()
        if 'username' in self.credentials and 'password' in self.credentials:
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
        self.switchToSearchPanel()

    def loadCredentials(self):
        env = os.environ
        env['GIT_ASKPASS'] = 'true'
        p = subprocess.Popen(['git', 'credential', 'fill'],
                             stdout=subprocess.PIPE,
                             stdin=subprocess.PIPE,
                             stderr=subprocess.PIPE)
        stdout,stderr = p.communicate('host=github.com\n\n')
        for line in stdout.split('\n'):
            try:
                k,v = line.split('=')
                self.credentials[k] = v
            except ValueError:
                return

        # Test out the credentials
        g = Github(self.credentials['username'], self.credentials['password'])
        status,data = g.issues.get()
        if status != 200:
            print('bad credentials in store')
            self.credentials = {}

if __name__ == '__main__':
    app = wx.App(False)
    SearchFrame(None)
    app.MainLoop()
