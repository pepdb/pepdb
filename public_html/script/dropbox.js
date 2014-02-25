pepdb.dropbox = pepdb.dropbox|| {};
// this file is nearly obsolete since the target selection was changed so now additional
// data needs to be loaded after one part of the target was selected (e.g. adding a selection)
$(document).ready(function(){
  'use strict';

  var url = $.baseDir();
  if(!isFirstLoad(pepdb.dropbox, 'dropbox.js')){
    $('#editselect').off();
    $('#clusterselect').off();
    $('#peptideselect').off();
  }

  $('#clusterselect').change(function(){
    var selected = $(this).children('option:selected').val();
    $.get(url+'/editclusters', {selElem:selected},function(data){
      $('#editform').html(data);
      $('#editform').show();
      $.getScript(url+'/script/initbutton.js');
    });
  });

  $('#peptideselect').change(function(){
    var selected_pep = $(this).children('option:selected').val();
    var selected_lib = $('#editselect').children('option:selected').text();
    $.get(url+'/editperformances', {selElem:selected_pep, selLib:selected_lib},function(data){
      $('#editform').html(data);
      $('#editform').show();
      $.getScript(url+'/script/initbutton.js');
    });
  });

  $('#editselect').change(function(){
    var table = $(this).children('option:selected').val();
    var selected = $(this).children('option:selected').text();
    if(table == 'clusters'){
      if (selected.size == 1){
        $('#clusterselection').html('');
      } else {
        $.get(url+ '/clusterdrop', {selElem:selected}, function(data){
          $('#clusterselection').html(data);
          $.getScript(url+'/script/dropbox.js');
          $('#clusterselection').show();
        });
      }
      return false;
    }
    if(table == 'peptide-performances'){
      if (selected.size == 1){
        $('#peptideselection').html('');
      } else {
        $.get(url+ '/performancesdrop', {selElem:selected}, function(data){
          $('#peptideselection').html(data);
          $.getScript(url+'/script/dropbox.js');
          $('#peptideselection').show();
        });
      }
      return false;
    }
    if (table.match(/targets/) !== null){
      var tmpStr = table.split(',');
      table = tmpStr[0];
      selected = tmpStr[tmpStr.length-1];
    }
    $.get(url+'/edit'+table, {selElem:selected},function(data){
      $('#editform').html(data);
      $('#editform').show();
      $.getScript(url+'/script/initbutton.js'); 
      $('#dspecies').change(function(){
        var valSel = $(this).children('option:selected').text();
        $.get(url+'/formdrop', {columnname: 'tissue', selected1: valSel, table:'targets', where1:'species', boxID:'dtissue'}, function(data){
          $('#dtissue').html(data);
          $('#dtissue').prop('selectedIndex', -1);
          $('#dcell').html('');
        });
      });
      $('#dtissue').change(function(){
        var valSel1 = $('#dspecies').children('option:selected').text();
        var valSel2 = $(this).children('option:selected').text();
        $.get(url+'/formdrop', {columnname: 'cell', selected1: valSel1, selected2: valSel2,table:'targets', where2:'tissue', where1:'species',boxID:'dcell'}, function(data){
          $('#dcell').html(data);
        });
      });
    });
  });
});
