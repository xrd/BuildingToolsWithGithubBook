#!/usr/bin/env python

import wx
from agithub import Github

# Change this to use an Enterprise installation
GITHUB_HOST = 'github.com'

def git_credentials():
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
    stdout,stderr = p.communicate('host={}\n\n'.format(GITHUB_HOST))
    for line in stdout.split('\n')[:-1]:
        k,v = line.split('=')
        creds[k] = v
    return creds

class LoginPanel(wx.Panel):
    def __init__(self, *args, **kwargs):
        self.callback = kwargs.pop('onlogin', None)
        wx.Panel.__init__(self, *args, **kwargs)
        sizer = wx.GridBagSizer(3,3)

        # Create controls
        self.userLabel = wx.StaticText(self, label='Username:')
        self.userBox = wx.TextCtrl(self, style=wx.TE_PROCESS_ENTER)
        self.passLabel = wx.StaticText(self, label='Password (or token):')
        self.passBox = wx.TextCtrl(self, style=wx.TE_PROCESS_ENTER)
        self.login = wx.Button(self, label='Login')
        self.error = wx.StaticText(self, label='')
        self.error.SetForegroundColour((200,0,0))

        # Bind events
        self.login.Bind(wx.EVT_BUTTON, self.do_login)
        self.userBox.Bind(wx.EVT_TEXT_ENTER, self.do_login)
        self.passBox.Bind(wx.EVT_TEXT_ENTER, self.do_login)

        # Layout in grid pattern
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

    def do_login(self, _):
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
        self.result = kwargs.pop('result', {})
        wx.Panel.__init__(self, *args, **kwargs)

        # Bind click events on this whole control
        self.Bind(wx.EVT_LEFT_UP, self.on_click)

        # Hover effect
        self.Bind(wx.EVT_ENTER_WINDOW, self.enter)
        self.Bind(wx.EVT_LEAVE_WINDOW, self.leave)

        # Extract strings and create controls
        titlestr = self.result['title']
        if self.result['state'] != 'open':
            titlestr += ' ({})'.format(self.result['state'])
        textstr = self.first_line(self.result['body'])
        self.title = wx.StaticText(self, label=titlestr)
        self.text = wx.StaticText(self, label=textstr)

        # Adjust the title font
        titleFont = wx.Font(16, wx.FONTFAMILY_DEFAULT,
                            wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_BOLD)
        self.title.SetFont(titleFont)

        # Layout
        vbox = wx.BoxSizer(wx.VERTICAL)
        vbox.Add(self.title, flag=wx.EXPAND | wx.BOTTOM, border=2)
        vbox.Add(self.text, flag=wx.EXPAND)
        self.SetSizer(vbox)

    def enter(self, _):
        self.title.SetForegroundColour(wx.BLUE)
        self.text.SetForegroundColour(wx.BLUE)

    def leave(self, _):
        self.title.SetForegroundColour(wx.BLACK)
        self.text.SetForegroundColour(wx.BLACK)

    def on_click(self, event):
        import webbrowser
        webbrowser.open(self.result['html_url'])

    def first_line(self, body):
        return body.split('\n')[0].strip() or '(no body)'

class SearchResultsPanel(wx.PyScrolledWindow):
    def __init__(self, *args, **kwargs):
        results = kwargs.pop('results', [])
        wx.PyScrolledWindow.__init__(self, *args, **kwargs)

        # Layout search result controls inside scrollable area
        vbox = wx.BoxSizer(wx.VERTICAL)
        if not results:
            vbox.Add(wx.StaticText(self, label="(no results)"), 0, wx.EXPAND)
        for r in results:
            vbox.Add(SearchResult(self, result=r), flag=wx.TOP|wx.BOTTOM, border=8)
        self.SetSizer(vbox)
        self.SetScrollbars(0, 4, 0, 0)
        
class SearchPanel(wx.Panel):
    def __init__(self, *args, **kwargs):
        self.orgs = kwargs.pop('orgs', [])
        wx.Panel.__init__(self, *args, **kwargs)

        # Create controls
        self.scrollPanel = None
        self.orgChoice = wx.Choice(self, choices=self.orgs, style=wx.CB_SORT)
        self.searchTerm = wx.TextCtrl(self, style=wx.TE_PROCESS_ENTER)
        self.searchTerm.SetFocus()
        searchButton = wx.Button(self, label="Search")

        # Bind events
        searchButton.Bind(wx.EVT_BUTTON, self.do_search)
        self.searchTerm.Bind(wx.EVT_TEXT_ENTER, self.do_search)

        # Layout: arrange choice, query box, and button horizontally
        hbox = wx.BoxSizer(wx.HORIZONTAL)
        hbox.Add(self.orgChoice, 0, wx.EXPAND)
        hbox.Add(self.searchTerm, 1, wx.EXPAND | wx.LEFT, 5)
        hbox.Add(searchButton, 0, wx.EXPAND | wx.LEFT, 5)

        # Layout: stack everything vertically, leaving room for the results
        self.vbox = wx.BoxSizer(wx.VERTICAL)
        self.vbox.Add(hbox, 0, wx.EXPAND)
        self.SetSizer(self.vbox)

    def do_search(self, event):
        term = self.searchTerm.GetValue()
        org = self.orgChoice.GetString(self.orgChoice.GetCurrentSelection())
        g = Github(self.Parent.credentials['username'], self.Parent.credentials['password'])
        code,data = g.search.issues.get(q="user:{} {}".format(org, term))
        results = data['items']

        if self.scrollPanel:
            self.scrollPanel.Destroy()
        self.scrollPanel = SearchResultsPanel(self, -1, results=results)
        self.vbox.Add(self.scrollPanel, 1, wx.EXPAND | wx.TOP, 5)
        self.vbox.Layout()

class SearchFrame(wx.Frame):
    def __init__(self, *args, **kwargs):
        kwargs.setdefault('size', (600,500))
        wx.Frame.__init__(self, *args, **kwargs)

        self.credentials = {}
        self.orgs = []
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # Set up a menu. This is mainly for "Cmd-Q" behavior on OSX
        filemenu = wx.Menu()
        filemenu.Append(wx.ID_EXIT, '&Exit')
        menuBar = wx.MenuBar()
        menuBar.Append(filemenu, '&File')
        self.SetMenuBar(menuBar)

        # Start with a login UI
        self.login_panel = LoginPanel(self, onlogin=self.login)
        self.sizer.Add(self.login_panel, 1, flag=wx.EXPAND | wx.ALL, border=10)
        self.SetSizer(self.sizer)

        # Try to pre-load credentials from Git's cache
        self.credentials = git_credentials()
        if self.test_credentials():
            self.switch_to_search_panel()

        self.Show()

    def login(self, username, password):
        self.credentials['username'] = username
        self.credentials['password'] = password
        if self.test_credentials():
            self.switch_to_search_panel()

    def test_credentials(self):
        if any(k not in self.credentials for k in ['username', 'password']):
            return False
        g = Github(self.credentials['username'], self.credentials['password'])
        status,data = g.user.orgs.get()
        if status != 200:
            print('bad credentials in store')
            return False
        self.orgs = [o['login'] for o in data]
        return True

    def switch_to_search_panel(self):
        self.login_panel.Destroy()
        self.search_panel = SearchPanel(self, orgs=self.orgs)
        self.sizer.Add(self.search_panel, 1, flag=wx.EXPAND | wx.ALL, border=10)
        self.sizer.Layout()

if __name__ == '__main__':
    app = wx.App(False)
    SearchFrame(None)
    app.MainLoop()
