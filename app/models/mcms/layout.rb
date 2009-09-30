# A layout is: a MCV "view", a merb "view"
# It is the page framework, the html of the page in the browser.
# It is where "modules" (Joomla concept) should go for now.
#
# A layout is assigned to to a site and there in a single "default" layout for
# all pages which maybe overiden at the content_item level, also at the
# content_item level an item on the layout could be overidden (not sure how yet)
# but it solves the issue of having to create/assign a new layout
#
module Mcms
  class Layout
  end
end # Mcms
