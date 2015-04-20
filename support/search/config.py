import os, subprocess

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
    creds = {}
    env = os.environ
    env['GIT_ASKPASS'] = 'true'
    p = subprocess.Popen(['git', 'credential', 'fill'],
                         stdout=subprocess.PIPE,
                         stdin=subprocess.PIPE,
                         stderr=subprocess.PIPE)
    stdout,stderr = p.communicate('host=github.com\n\n')
    for line in stdout.split('\n')[:-1]:
        try:
            k,v = line.split('=')
            if v:
                creds[k] = v
        except ValueError:
            pass

    return creds
