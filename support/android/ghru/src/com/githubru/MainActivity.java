package com.githubru;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.EditText;
import android.widget.TextView;
import android.view.View;
import android.os.AsyncTask;
import org.eclipse.egit.github.core.service.UserService;
import org.eclipse.egit.github.core.User;
import java.io.IOException;

public class MainActivity extends Activity
{
    String username, password;

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main); 

        Button login = (Button)findViewById( R.id.login ); 
        login.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    EditText utv = (EditText)findViewById( R.id.username ); 
                    EditText ptv = (EditText)findViewById( R.id.password );
                    username = (String)utv.getText().toString();
                    password = (String)ptv.getText().toString();
                    TextView status = (TextView)findViewById( R.id.login_status ); 
                    status.setText( "Logging in, please wait..." );
                    new LoginTask().execute( username, password ); 
                }
            });
    }

    private void loggedIn() {

        setContentView(R.layout.logged_in); 

        Button submit = (Button)findViewById( R.id.submit );
        submit.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    doPost(); 
                }
            });
    }

    class LoginTask extends AsyncTask<String, Void, Boolean> {  
        @Override
            protected Boolean doInBackground(String... credentials) {
            boolean rv = false;
            UserService us = new UserService();
            us.getClient().setCredentials( credentials[0], credentials[1] ); 
            try {
                User user = us.getUser( credentials[0] ); 
                rv = null != user;
            }
            catch( IOException ioe ) {}
            return rv;
        }
        
        @Override
            protected void onPostExecute(Boolean result) {
            if( result ) {
                loggedIn(); 
            }
            else {
                TextView status = (TextView)findViewById( R.id.login_status );
                status.setText( "Invalid login, please check credentials" ); 
            }
        }
    }

    private void doPost() {
        new PostTask().execute( username, password ); 
    }

    class PostTask extends AsyncTask<String, Void, Boolean> {  

        @Override 
            protected Boolean doInBackground(String... credentials) {
            String login = credentials[0]; 
            String password = credentials[1];

            EditText post = (EditText)findViewById( R.id.post );
            String postContents = post.getText().toString();

            EditText repo = (EditText)findViewById( R.id.repository ); 
            String repoName = repo.getText().toString();

            GitHubHelper ghh = new GitHubHelper( login, password );
            return ghh.SaveFile( repoName, postContents );
        }
        
        @Override
            protected void onPostExecute(Boolean result) {
            TextView status = (TextView)findViewById( R.id.post_status );
            if( result ) {
                status.setText( "Successful jekyll post" );
            }
            else {
                status.setText( "Post failed." ); 
            }
        }
    }


    
}
