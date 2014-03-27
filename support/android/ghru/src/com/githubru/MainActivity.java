package com.githubru;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.EditText;
import android.widget.TextView;
import android.view.View;

public class MainActivity extends Activity
{
    private LinearLayout ll = null;

    private void login() {
        setContentView(R.layout.logged_in);

        Button submit = (Button)findViewById( R.id.submit );
        submit.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    doPost();
                }
            });
    }

    private void doPost() {
        TextView tv = (TextView)findViewById( R.id.status );
        tv.setText( "Successful jekyll post" );
    }


    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main); 
        Button login = (Button)findViewById( R.id.login );
        login.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    login();
                }
            });
    }
}
