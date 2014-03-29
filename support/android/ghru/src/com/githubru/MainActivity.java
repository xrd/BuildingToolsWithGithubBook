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
import org.apache.commons.codec.binary.Base64;
import java.text.SimpleDateFormat;
import java.util.Date;

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
                    EditText utv = (EditText)findViewById( R.id.username ); // <1>
                    EditText ptv = (EditText)findViewById( R.id.password );
                    username = (String)utv.getText().toString();
                    password = (String)ptv.getText().toString();
                    TextView status = (TextView)findViewById( R.id.login_status ); // <2>
                    status.setText( "Logging in, please wait..." );
                    new LoginTask().execute( username, password ); // <3>
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

    class LoginTask extends AsyncTask<String, Void, Boolean> {  // <4>
        @Override
            protected Boolean doInBackground(String... credentials) {
            boolean rv = false;
            UserService us = new UserService();
            us.getClient().setCredentials( credentials[0], credentials[1] ); // <5>
            try {
                User user = us.getUser( credentials[0] ); // <6>
                rv = null != user;
            }
            catch( IOException ioe ) {}
            return rv;
        }
        
        @Override
            protected void onPostExecute(Boolean result) {
            if( result ) {
                loggedIn(); // <7>
            }
            else {
                TextView status = (TextView)findViewById( R.id.login_status );
                status.setText( "Invalid login, please check credentials" ); // <8>
            }
        }
    }

    private void doPost() {
        new PostTask().execute( username, password );
    }

    class PostTask extends AsyncTask<String, Void, Boolean> {  // <4>

        private String getFilename( String post ) {
            String title = post.substring( 0, post.length() > 30 ? 30 : post.length() );
            String jekyllfied = title.toLowerCase().replaceAll( "\\W+", "-").replaceAll( "\\W+$", "" );
            SimpleDateFormat sdf = new SimpleDateFormat( "yyyy-MM-dd-" );
            String prefix = sdf.format( new Date() );
            String filename = "_posts/" + prefix + jekyllfied + ".md";
            return filename;
        }

        @Override 
            protected Boolean doInBackground(String... credentials) {
            String username = credentials[0];
            String password = credentials[1];

            EditText post = (EditText)findViewById( R.id.post );
            String postContents = post.getText().toString();
            String base64ed = new String( Base64.encodeBase64( postContents.getBytes() ) );

            EditText repo = (EditText)findViewById( R.id.repository );
            String repoName = repo.getText().toString();

            String filename = getFilename( postContents );

            return GitHubHelpers.SaveFile( username, password, 
                                           repoName, base64ed, filename );
        }
        
        @Override
            protected void onPostExecute(Boolean result) {
            TextView status = (TextView)findViewById( R.id.post_status );
            if( result ) {
                status.setText( "Successful jekyll post" );
            }
            else {
                status.setText( "Post failed." ); // <8>
            }
        }
    }


    
}
