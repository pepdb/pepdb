pepdb.initbutton = pepdb.initbutton || {};

$(document).ready(function(){
   function baseDir(){
    var url = document.location.pathname.split('/')[1];
    if (url == "pepdb"){
      return '/'+url;
    }else{
      return '';
    }
  };

  var url = baseDir();
 
  $('#continue').click(function(){
    var url2 = $(this).attr('action');
    var cont = $('#refele2').val();
    url2 = url2 + '/'+ cont;
    window.location = url2; 
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
    $('#sysresults').load(url +'/systemic-results', {sysDS: checkedDS}, function(){
      $.getScript(url +"/script/tableinit.js")
    });
  });

  $('#delbut').click(function(){
    var tab = $('#tab').val();
    var element = $('#eleid').val();
    $.ajax({
      type: "DELETE",
      url: url+'/delete-entry',
      data: {table: tab, id: element},
      success: function(response){
        $('#respage').html(response);
      }
    });
  });
});
