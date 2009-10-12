var _editor;
var _active;

function init(){
  _editor = new bespin.editor.Component("editor", {
    language: "html"
    ,loadfromdiv: true
    ,set: {
      strictlines: "on"
    }
  });
  
  fitEditor();
  Ext.EventManager.addListener(window, "resize", fitEditor);

  Ext.select('.editors').on('click', function(e, t) {
       Ext.fly(t).radioClass('active');
       setEditorContent(Ext.fly(t).getAttribute("id").substring(1));
   }, null, {delegate: 'a'});
   
  Ext.fly("_form").on("submit", function(e,t) {
    e.stopEvent();
    var btn = Ext.getDom("btn");
    btn.disabled = true;
    btn.value = "saving...";
    save(btn);
  });
}

function fitEditor() {
  Ext.fly("editor").setHeight(window.innerHeight-100, true);
}
function setEditorContent(what) {
  setFieldContent(_active);
  _editor.setContent(Ext.fly(what).getValue());
  _active = what;
}
function setFieldContent(what) {
  if(what) {
    Ext.fly(what).update(_editor.getContent());
  }
}
function save(btn) {
  setFieldContent(_active);
  Ext.Ajax.request({
    url: Ext.fly("_form").getAttribute("action")
    ,form: "_form"
    ,method: Ext.fly("_method").getValue()
    ,success: function(response, opts) {
      var obj = Ext.decode(response.responseText);
      btn.disabled = false;
      btn.value = "save";
      switch(obj.action) {
        case "created":
          window.location = obj.url
          break;
        case "updated":
          Ext.getDom("rev").value = obj.rev;
          break;
      }
    }
    ,failure: function(response, opts) {
      console.log("server-side failure with status code " + response.status);
      btn.disabled = false;
      btn.value = "save";
    }
  });
}
Ext.onReady(init);
