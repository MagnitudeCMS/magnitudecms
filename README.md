<blockquote>
<p>this code is horribly out dated / not finished...</p>

<p>it works for me as I haven't touched anything since I set it up for a multidomain site <em>(I'm not going to reveal, if you break it then I have to fix it...)</em></p>

<p>so how do we get it running??</p>

<p>I think the best solution would be to use the same versions as what I'm running</p>
<ul>
<li>rvm, 0.1.24</li>
<li>ruby, 1.8.7p249</li>
<li>gem, 1.3.6</li>
<li>bundler 0.9.25</li>
</ul>

<p>if you can setup a new user with all these, mcms should work as all the required gems are stored in the repo.</p>

<p>have fun ;)</p>
</blockquote>


MagnitudeCMS
============

Goals
-----
* To be simple, effecient and logical
* One login managing many, many sites.
* To be one step up from hand coding every page in xhtml
* Flexible to manage a network of related sites, multiple sites or just a single website
* Search Engine Friendly
* Haml and Compass as primary citizens.
* CouchDB and CouchRest are the starting point.
* ORM agnostic? Not a "goal", however much of the heavy lifting will be contained in the models, so...

What is it?
-----------
A Ruby Content Management System (CMS). Designed for coder's not mum's and dad's.

In the begining it'll be to solve my problems/issues/questions - I can see a path like what Harmony (Sidebar Creative) is going down. The end goal is as stated above. I'm sick of having to do the same stuff over and over again to setup/configure a new site. I want to be able to click a button "new site" then point DNS records, presto new site setup, sort out theme, sort out content, ta-da new site live.

Who, When, Open Source?
-----------------------
My name is Nicholas Orr I need a CMS that is built for me, not everyone.

I've started a company, ZN Dynamic, that builds & optimizes websites. I use Joomla, it works, I've made it work for me, it's a kludge though and I need something simpler and streamlined for what I do.

Magnitude CMS will be Open Source and I haven't figured out how I'm going to do that yet; Source Forge, Google Code, Trac or something else. I've setup a GitHub repository.

Functionality?
--------------
Here are the bullet points on functionality, pretty basic/simple.

* Mulipe Sites
    * Site
        * Domain, Domain
    * Site
        * Domain
    * Site
        * Domain, Domain, Domain, Domain
* Page
    * Meta
        * Title
        * Robots
        * Keywords
        * Description
        * Canonical
    * URL
    * Content
        * Parts
            * Different content for showing up in different places
        * Maruku gem is used - again simple/basic required.
            * I was going to go pure xhtml however after using maruku, you can have markdown+
            * Then with the wmd-editor.com you get live preview...
                * May need to tweak wmd later to get additional maruku features...
    * Title (html > head > title)
    * Layout
* Theme (aka template)
    * multiple layouts - so page can look different depending on how you want content laid out
    * themes are global and assigned to sites
* Layout
    * Site has a default layout from a theme
    * Page can pick layout from site theme
* Administration
    * Minimal, Minimal
    * There is one type of account, admin, that have access to sites
        * single account, multiple sites
        * don't want someone changing certain parts of the site, tell them to leave them alone, fire them if they do it again - social issue, not a system issue.
    * On page editing of everything
        * edit box is out of flow of page, update edit box, content on page updates
        * live preview
        * want content item in a menu on page, drag and drop (this might be tricky to implement)
        * create new pages by typing new url (ala wiki style)
    * Edit theme in admin area
        * Sass is text
        * Haml is text
        * see point about where to store files, below.

What can be on a page?
----------------------
* Menus
* Content
* Summary of another pages content clicking of which will change pages
* Forms
* Stats Code

How can a Page Look?
--------------------
Summary of a bunch of pages
A single page of content
An idea spread over multiple pages accessed by a tree hierarchy, like sub menus
Different types of content items presented differently

What sort of files are involved?
--------------------------------
* CSS
* Javascript
* Images
* Flash
* PDF / DOC / other misc.

Where could these files be stored?
----------------------------------
* Database
    * cache to disk on first access so web server may serve files quickly
* On disk
    * what about transferring site to another host? If it is in a CouchDB database it would be simpler to replicate...

License?
--------
Umm good question - guess I need to see what I'm using to build this project, then I'll see which fits best and is compatible :)

To Do
-----
* <del>User model</del>
* Figure out how to do the above scenario (create site / add domain)
* Sort out how a site is stored
* Plumbing for creating a site
* Figure out best way to have each request be about a site
* Model Content
* After site is created or added, what next?

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
<dt>Marco Vignolo - info@marco-vignolo.com.ar</dt>
<dd>Sweet logo</dd>
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
