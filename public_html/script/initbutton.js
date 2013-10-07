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
    if($('#sysresults').is(':visible')){
      $('#sysresults').toggle();
    }
    if($('.loading').is(':hidden')){
      $('.loading').toggle();
    }
    var checkedDS = [];
    $('#ref-dataset input:checkbox:checked').each(function(){
      var elemVal = this.value;
      if(elemVal != "all_ds"){
        checkedDS.push(elemVal);
      }
    });
    $.get(url+'/systemic-results',{sysDS: checkedDS}, function(data){
      $('#sysresults').html(data);
      $.getScript(url +"/script/initshowtable.js", function(){
        $('.loading').toggle();
        $('#sysresults').toggle();
      });
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
