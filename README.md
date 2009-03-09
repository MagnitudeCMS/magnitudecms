MagnitudeCMS
============

A simple CMS with the primary goal of one login managing many, many sites.
Haml amd Compass as primary citizens.
CouchDB and CouchRest are the starting point.
ORM agnostic? Not a "goal", however much of the heavy lifting will be contained in the models, so...

In the begining it'll be to solve my problems/issues/questions - I can see a path like what Harmony (Sidebar Creative) is going down.
The end goal is as stated above. I'm sick of having to do the same stuff over and over again to setup/configure a new site.
I want to be able to click a button "new site" then point DNS records, presto new site setup, sort out theme, sort out content, ta-da new site live.

Here are the bullet points on functionality, pretty basic/simple.

* Mulipe Sites
    * Site
        * Domain
        * Domain
        * Domain
* Page
    * Meta
        * Title
        * Robots
        * Keywords
        * Description
        * Canonical
    * URL
    * Content
    * Title (html > head > title)
    * Layout
    * Parts
        * Different content for showing up in different places
* Theme (aka template)
    * multiple layouts - so page can look different depending on how you want content layed out
    * themes are global and assigned to sites
* Layout
    * Site has a default layout from a theme
    * Page can pick layout from site theme
* Administration
    * Minimal, Minimal
    * On page editing of everything
        * edit box is out of flow of page, update edit box, content on page updates
        * live preview
        * want content item in a menu on page, drag and drop
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

* Summary of a bunch of pages
* A single page of content
* An idea spread over multiple pages accessed by a tree heirachy, like sub menus
* Different types of content items presented differently

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
    * what about transfering site to another host? If it is in a CouchDB database it wouold be simpler to replicate...
    
What License?
-------------

Umm good question - guess I need to see what I'm using to build this project, then I'll see which fits best and is compatible :)
