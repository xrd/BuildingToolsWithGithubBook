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
                    String username = (String)utv.getText().toString();
                    String password = (String)ptv.getText().toString();
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
        TextView tv = (TextView)findViewById( R.id.post_status ); 
        tv.setText( "Successful jekyll post" );
    }
    
}
