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

MagnitudeCMS uses the bundler. To redeploy the gems on your system (including native gems), just run:

    gem bundle --cached

Note not using Datamapper or any other ORM. Using straight CouchRest.

Running
-------

Modify the config file so it is pointing at your CouchDB server.  

    config/application.yml

The first time the app is run there are no websites or users configured.  
Also there is only one type of user, full access.  
Simply start the app and hit up the site and follow the prompts
    
    bin/merb -athin -p4050
    open browser http://localhost:4050
    
Upon hitting MagnitudeCMS the first time you'll be asked to create a user.
Then it'll create the couchdb you specified in the config and you'll be able to create a new site.
Now click the link and login as the user you just created.
Once that is all done you'll see the homepage of the new site you just created

Ta-Da - This how simple CMS should be!  

Thanks / Kudos
==============

<dl>
<dt>Jacques Crocker</dt>
<dd>Updating Merb to 1.1 and sorting out the bundler</dd>
</dl>

Copyright / License
===================

Copyright (C) 2009 [Nicholas Orr](http://nicholasorr.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
