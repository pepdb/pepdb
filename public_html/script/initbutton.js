pepdb.initbutton = pepdb.initbutton || {};
// this file initializes the continue buttons displayed within the data browsing
// additionally it hides previous search results when a new search is send
$(document).ready(function(){
  'use strict';
  var url = $.baseDir();

  if(!isFirstLoad(pepdb.initbutton, 'initbutton.js')){
    $('#delbut').off();
    $('#updds').off();
    $('#search').off();
    $('#continue').off();
  }
 
  $('#continue').click(function(){
    var url2 = $(this).attr('action');
    var cont = $('#refele2').val();
    url2 = url2 + '/'+ cont;
    window.location = url2;
  });
  $('#delbut').click(function(){
    var tab = $('#tab').val();
    var element = $('#eleid').val();
    if (confirm('Are you sure?')){
      $.ajax({
        type: 'DELETE',
        url: url+'/delete-entry',
        data: {table: tab, id: element},
        success: function(response){
          $('#respage').html(response);
        }
      });
      if (tab === "peptide_performances"){
        $('#editselect').change();
      } else if (tab === "clusters"){
        $('#editselect').change();
      } else {
        $('#edittype').change();
      }
    }
  });
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
      if(elemVal != 'all_ds'){
        checkedDS.push(elemVal);
      }
    });
    $.get(url+'/systemic-results',{sysDS: checkedDS}, function(data){
      $('#sysresults').html(data);
      $.getScript(url +'/script/initshowtable.js', function(){
        $('.loading').toggle();
        $('#sysresults').toggle();
      });
    });
  });

  $('#updds').click(function(event){
    var old_file = $('#statpath').val();
    var new_file = $('#statfile').val();
    if (old_file !== undefined && new_file !== ""){
      if (!confirm('This will overwrite the current statistic file')){
        event.preventDefault();
      }
    }
  }); 


});
