# zigi
zigi: The git interface for the rest of us!

## Installing zigi

Make sure you have git installed on your Mainframe. 
In order to install git, head on over to https://www.rocketsoftware.com/ and create an account.
Then download git, bash, gzip and perl and bring all those files to one directory in USS.

Then head on over to https://gist.github.com/wizardofzos/897b243d4cbe9fbc471ec1396fbbe174 and stick that installer in the
same directory as the things you downloaded from rocket.

Run that script.

You should now have git installed on you Mainframe.

Clone this repository and run the installer via: 

    git clone git@github.com:wizardofzos/zigi.git
    cd zigi
    sh install.sh
    
### Make sure you can allocate datesets 


## Contributing to zigi?

Yes please!


# Known Issues (maybe solutions...)

### Weird Certificate Errors
When faced with a "SSL Certificate problem: unable to get local issuer" this might 'fix' it.

    git config --global http.sslVerify false

