MagnitudeCMS
============

For information about this project refer to the 
[MagnitudeCMS](http://magnitudecms.com/ "MagnitudeCMS - CMS running on Ruby via Merb and CouchDB") website or 
[GitHub](http://github.com/MagnitudeCMS/magnitudecms/ "MagnitudeCMS - GitHub Repository")


Installing / Running
====================

Installing
----------
    
    git clone git://github.com/MagnitudeCMS/magnitudecms.git
    gem install bundler
    gem bundle --cached

Dependencies
------------

Since this is a merb application I'm using the bundler. To rebundle on your system (including native gems), just run:

    gem bundle --cached

Note not using Datamapper or any other ORM. Using straight CouchRest.

Running
-------

Modify the config file so it is pointing at your CouchDB server.  

    config/application.yml

The first time the app is run there are no websites or users configured.  
Also there is only one type of user, full access.  
For now use the rake task gogogooo
    
    bin/rake gogogooo
    bin/merb -athin -p4050
    edit your hosts file: ip site1
    open browser http://site1:4050
    ctrl+f5 (refresh) - race condition on generating the css on the first hit
    you should now have bright pink "home page" text on the screen
    
You need to hit the site with the domain you want your website to appear as.  
So if you want your site called _localhost_ then hit it with _localhost_  
Otherwise create a DNS record or hosts entry.  

Since the site doesn't exist yet you need to create it.  
Login with the user you created before and you will be presented with a form to create a new site.  
Submit the form (a new couchdb is created, site is added to main db)

Ta-Da - This how simple CMS should be!  

Thanks / Kudos
==============

<dl>
<dt>Jacques Crocker</dt>
<dd>Updating Merb to 1.1 and sorting out the bundler</dd>
</dl>
