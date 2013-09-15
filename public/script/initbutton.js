pepdb.initbutton = pepdb.initbutton || {};

$(document).ready(function(){
  if(!isFirstLoad(pepdb.initbutton, "initbutton.js")){
    return;
  }
  $('#search').click(function(){
    var checkedDS = [];
    $('#ref-dataset input:checkbox:checked').each(function(){
      var elemVal = this.value;
      if(elemVal != "all_ds"){
        checkedDS.push(elemVal);
      }
    });
     //getScript für geladene table
    $('#results').load('/systemic-results', {sysDS: checkedDS}, function(){
      $.getScript("/script/tableinit.js")
    });
  });
});
