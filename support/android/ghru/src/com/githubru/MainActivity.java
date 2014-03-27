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
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main); 

        Button login = (Button)findViewById( R.id.login ); // <1>
        login.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    login(); // <2>
                }
            });
    }

    private void login() {

        setContentView(R.layout.logged_in); // <3>

        Button submit = (Button)findViewById( R.id.submit );
        submit.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    doPost(); // <4>
                }
            });
    }

    private void doPost() {
        TextView tv = (TextView)findViewById( R.id.status ); // <5>
        tv.setText( "Successful jekyll post" );
    }

}
