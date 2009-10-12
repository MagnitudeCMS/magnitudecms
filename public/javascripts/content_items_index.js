Ext.onReady(function(){
  Ext.select('.delete').on('click', function(e, t) {
    e.stopEvent();
    var answer = confirm ("Ok to Delete, Cancel to Keep...");
    if(answer){
      Ext.Ajax.request({
        url: Ext.fly(t).getAttribute("href")
        ,method: "DELETE"
        ,success: function(response, opts) {
          Ext.fly(t).findParentNode("tr",null,true).remove();
        }
        ,failure: function(response, opts) {
          console.log("server-side failure with status code " + response.status);
        }
      });
    }
  });
});
