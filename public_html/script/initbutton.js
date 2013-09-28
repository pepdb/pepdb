pepdb.initbutton = pepdb.initbutton || {};

$(document).ready(function(){
  
  $('#continue').click(function(){
    var url = $(this).attr('action');
    var cont = $('#refele2').val();
    url = url + "/"+ cont;
    window.location = url; 
  });
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
    $('#sysresults').load('/systemic-results', {sysDS: checkedDS}, function(){
      $.getScript("/script/tableinit.js")
    });
  });
});
