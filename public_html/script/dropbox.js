
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
  $('#clusterselect').change(function(){
    var selected = $(this).children("option:selected").val();
    $.get(url+'/editclusters', {selElem:selected},function(data){
      $('#editform').html(data);
    });
  });

  $('#editselect').change(function(){
    var table = $(this).children("option:selected").val();
    var selected = $(this).children("option:selected").text();
    if(table == "clusters"){
      $.get(url+ '/clusterdrop', {selElem:selected}, function(data){
        $('#clusterselection').html(data);
        $.getScript(url+'/script/dropbox.js');
      });
      return false;
    }
    $.get(url+'/edit'+table, {selElem:selected},function(data){
      $('#editform').html(data);
      $.getScript(url+'/script/initbutton.js', function(){
      });
      $('#dspecies').change(function(){
          var valSel = $(this).children("option:selected").text();
          $.get(url+'/formdrop', {columnname: "tissue", selected1: valSel, table:"targets", where1:"species", boxID:"dtissue"}, function(data){
            $('#dtissue').html(data);
            $('#dtissue').prop('selectedIndex', -1);
            $('#dcell').html('');
          });
        });
        $('#dtissue').change(function(){
          var valSel1 = $('#dspecies').children("option:selected").text();
          var valSel2 = $(this).children("option:selected").text();
          $.get(url+'/formdrop', {columnname: "cell", selected1: valSel1, selected2: valSel2,table:"targets", where2:"tissue", where1:"species",boxID:"dcell"}, function(data){
            $('#dcell').html(data);
          });
        });
    });
  });


});
