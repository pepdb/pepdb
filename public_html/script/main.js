// define namespace to prevent loading js files multiple times
var pepdb = pepdb || {};

$.ajaxSetup ({
  cache: false 
});

var isFirstLoad = function(namesp, jsFile) {
  'use strict';
  var isFirst = namesp.firstLoad === undefined;
  namesp.firstLoad = false;
  
  return isFirst;
};

jQuery.baseDir =  function baseDir(){
  'use strict';
  var url = document.location.pathname.split('/')[1];
  if (url == 'pepdb'){
    return '/'+url;
  } else {
    return '';
  }
};


/* get url parameter 'name' or return '' if does not exist */
function urlParam(name){
  'use strict';
  var result = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
  return result && unescape(result[1]) || '';
}

$(document).ready(function(){
  'use strict';

  var url = $.baseDir();
  var formAll = ['#all_lib', '#all_sel', '#all_ds', '#c_all_lib', '#r_all_lib', '#all_motl'];
  var propSelect = ['#l', '#s', '#ds', '#c', '#ts', '#tt', '#tc', '#ss', '#st', '#sc'];
  var species = ['#ss', '#ts'];
  var tissue = ['#st', '#tt'];
  var cell = ['#sc', '#tc'];
/*
  $('.optbut').button();
  $('#navigation').menu();
  $('.editlink').button();
  $('.deletelink').button();
*/
  $('#clear-button').click(function(){
    $('body').load(window.location.pathname);
  });
   
  var navbarSec = $('#navbarsec').val();
  $('#'+navbarSec).addClass('active');
  $.each(formAll, function(index, value){
    $(value).click(function(){
      var marked = this.checked;
      $(this).closest('fieldset').find(':checkbox').each(function(){
        $(this).prop('checked', marked);
      });
    });
  });
  
  $('#comp-library input:checkbox').click(function(){
    var checkedLibs = [];
    $(this).closest('fieldset').find(':checkbox').each(function(){
      var elemVal = $(this).attr('value');
      if(this.checked && elemVal != 'all_lib'){
        checkedLibs.push(elemVal);
      }
    });
    $('#comp-selection').load(url+'/checklist',{checkedElem: checkedLibs, allElem: 'c_all_sel', allElemVal: 'all_sel', selector: 'sel', sec: 'c_', elemName: 'sels[]' }, function(){
        $.getScript(url+'/script/checkbox.js');
      } );
  });
  

  $('#ref-library input:checkbox').click(function(){
    var checkedLibs = [];
    $(this).closest('fieldset').find(':checkbox').each(function(){
      var elemVal = $(this).attr('value');
      if(this.checked && elemVal != 'all_lib'){
        checkedLibs.push(elemVal);
      }
    });
    $('#ref-selection').load(url+'/checklist',{checkedElem: checkedLibs, allElem: 'r_all_sel', allElemVal: 'all_sel', selector: 'sel', sec: 'r_', elemName: 'sels[]' }, function(){
        $.getScript(url+'/script/checkbox.js');
      } );
  });

  $('#motif-list input:radio').click(function(){
    if($('#motifs').is(':visible')){
      $('#motifs').toggle();
    }
    var checkedList = $(this).val();
    $.get('mot-checklist', {checkedElem: checkedList},function(data){
      $('#motifs').html(data);
      $.getScript(url+'/script/initshowtable.js', function(){
        $('#motifs').toggle();
      });

    });
  });

  $('#compdata').submit(function(){
    if($('#comppepresults').is(':visible')){
      $('#comppepresults').toggle();
    }
    if($('.loading').is(':hidden')){
      $('.loading').toggle();
    }
    $('#infos').html('');
    $.ajax({
      data: $(this).serialize(),
      type: $(this).attr('method'),
      url: $(this).attr('action'),
      error: function(response,error1,error2){
        $.get(url+'/error', {error:error2},function(response){
          $('#comppepresults').html(response);
          $('#comppepresults').toggle();
          $('.loading').toggle();
        });
      },
      success: function(response){
        $('#comppepresults').html(response);
        $.getScript(url+'/script/initshowtable.js', function(){
          $('#comppepresults').toggle();
          $('.loading').toggle();
        });
      }
    });
    return false;
  });

  $('#motsearch').submit(function(){
    if($('#motresults').is(':visible')){
      $('#motresults').toggle();
    }
    if($('.loading').is(':hidden')){
      $('.loading').toggle();
    }
    $.ajax({
      data: $(this).serialize(),
      type: $(this).attr('method'),
      url: $(this).attr('action'),
      error: function(response,error1,error2){
        $.get(url+'/error', {error:error2},function(response){
          $('#motresults').html(response);
          $('#motresults').toggle();
          $('.loading').toggle();
        });
      },

      success: function(response){
        $('#motresults').html(response);
        $.getScript(url+'/script/accinit.js', function(){
          $('#motresults').toggle();
          $('.loading').toggle();
        });
      }
    });
    return false;
  });
   
  $('#cl-search').submit(function(){
    if($('#clpepresults').is(':visible')){
      $('#clpepresults').toggle();
    }
    /*
    if($('.clsearch').is(':visible')){
      $('.clsearch').toggle();
    }*/
    
    $('.clsearch').html('');
    $('#clpepresults').html('');
    $('.clsearchpeps').html('');
    $.ajax({
      data: $(this).serialize(),
      type: $(this).attr('method'),
      url: $(this).attr('action'),
      error: function(response,error1,error2){
        $.get(url+'/error', {error:error2},function(response){
          $('#clpepresults').html(response);
          $('#clpepresults').toggle();
         // $('.clsearch').toggle();
          $('.loading').toggle();
        });
      },
      success: function(response){
        $('#clpepresults').html(response);
        $.getScript(url+'/script/tableinit.js', function(){
          //$('.clsearch').toggle();
          $('#clpepresults').toggle();
        });
      }
    });
    return false;
  });

  $('#datatype').change(function(){
    var selected = $(this).children('option:selected').text();
    if(selected == 'sequencing dataset'){
      selected = 'dataset';
    }
    if(selected == 'motif list'){
      selected = 'motif';
    }
    if(selected == 'peptide performance'){
      selected = 'performance';
    }
    $('#dataform').load(url+'/add'+ selected, function(){
      var boxNames = ['#dlibname', '#dselname', '#ddsname', '#dspecies'];

      $.each(boxNames, function(index, value){
        $(value).prop('selectedIndex', -1);
      });

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
      $('#dlibname').change(function(){
        var valSel = $(this).children('option:selected').text();
        $.get(url+'/formdrop', {columnname: 'selection_name', selected1: valSel, table:'selections', where1:'library_name', boxID:'dselname'}, function(data){
          $('#dselname').html(data);
          $('#dselname').prop('selectedIndex', -1);
          $('#ddsname').prop('selectedIndex', -1);
        });
      });
      $('#dselname').change(function(){
        var valSel1 = $('#dlibname').children('option:selected').text();
        var valSel2 = $(this).children('option:selected').text();
        $.get(url+'/formdrop', {columnname: 'dataset_name', selected1: valSel1, selected2: valSel2, table:'sequencing_datasets', where1:'library_name', where2:'selection_name',boxID:'dselname'}, function(data){
          $('#ddsname').html(data);
          $('#ddsname').prop('selectedIndex', -1);
        });
      });
    });
  });
    
  $.each(propSelect, function(index, value){
    var paramName = $(value).attr('name');
    if(urlParam(paramName) === ''){
      $(value).prop('selectedIndex', -1);
    }
    $(value).on('beforeunload', function(){
      if ($(this).attr('selectedIndex') == -1){
        $(this).prop('name', '');
      }
    });
  });

  $('#edittype').change(function(){
    var selected = $(this).children('option:selected').val();
    if (selected.length == 1){
      $('#elementselection').hide();
      $('#clusterselection').hide();
      $('#peptideselection').hide();
      $('#editform').hide();
      
      return false;
    }
    $.get(url+'/editdrop', {table:selected}, function(data){
      $('#elementselection').html(data);
      $.getScript(url+'/script/dropbox.js');
      $('#elementselection').show();
      
      if (selected !== 'clusters'){
        $('#clusterselection').hide();
      }
      if (selected !== 'peptide performances'){
        $('#peptideselection').hide();
      }
    });
  });
    

  $('#propsearch').submit(function(){
    if($('#propresults').is(':visible')){
      $('#propresults').toggle();
      $('#infos').html('');
    }
    if($('.loading').is(':hidden')){
      $('.loading').toggle();
    }
    $.ajax({
      data: $(this).serialize(),
      type: $(this).attr('method'),
      url: $(this).attr('action'),
      error: function(response,error1,error2){
        $.get(url+'/error', {error:error2},function(response){
          $('#propresults').html(response);
          $('#propresults').toggle();
          $('.loading').toggle();
        });
      },
      success: function(response){
        $('#propresults').html(response);
        $.getScript(url+'/script/initshowtable.js', function(){
          $('#propresults').toggle();
          $('.loading').toggle();
        });
      }
    });
    return false;
  });

  $.each(species, function(index, value){
    $(value).change(function(){
      var valSel = $(this).children('option:selected').text();
      $.get(url+'/formdrop', {columnname: 'tissue', selected1: valSel, table:'targets', where1:'species', boxID:tissue[index].substring(1)}, function(data){
        $(tissue[index]).html(data);
        $(tissue[index]).prop('selectedIndex', -1);
        $(cell[index]).html('');
      });
    });
  });

  $.each(tissue, function(index, value){
    $(value).change(function(){
      var valSel1 = $(species[index]).children('option:selected').text();
      var valSel2 = $(this).children('option:selected').text();
      $.get(url+'/formdrop', {columnname: 'cell', selected1: valSel1, selected2: valSel2,table:'targets', where2:'tissue', where1:'species',boxID:cell[index].substring(1)}, function(data){
        $(cell[index]).html(data);
      });
    });
  });

  $('#l').change(function(){
    var valSel = $(this).children('option:selected').text();
    $.get(url+'/formdrop', {columnname: 'selection_name', selected1: valSel, table:'selections', where1:'library_name', boxID:'s'}, function(data){
      $('#s').html(data);
      $('#s').prop('selectedIndex', -1);
      $('#ds').prop('selectedIndex', -1);
    });
  });

  $('#s').change(function(){
    var valSel1 = $(this).children('option:selected').text();
    $.get(url+'/formdrop', {columnname: 'dataset_name', selected1: valSel1,table:'sequencing_datasets', where1:'selection_name',boxID:'ds'}, function(data){
      $('#ds').html(data);
      $('#ds').prop('selectedIndex', -1);
    });
  });
      
  $('#compclsub').submit(function(){
    if($('#compclresults').is(':visible')){
      $('#compclresults').toggle();
    }
    if($('.loading').is(':hidden')){
      $('.loading').toggle();
    }
    $.ajax({
      data: $(this).serialize(),
      type: $(this).attr('method'),
      url: $(this).attr('action'),
      error: function(response,error1,error2){
        $.get(url+'/error', {error:error2},function(response){
          $('#compclresults').html(response);
          $('#compclresults').toggle();
          $('.loading').toggle();
        });
      },
      success: function(response){
        $('#compclresults').html(response);
        $.getScript(url+'/script/initshowtable.js', function(){
          $('#compclresults').toggle();
          $('.loading').toggle();
        });
      }
    });
    return false;
  });
      
  $('#type').change(function(){
    if ($(this).val() == 'complete sequence'){
      $('#blossum').show();
      $('#wchelp').hide();
      $('#bshelp').show();
    } else if ($(this).val() == 'wildcard sequence'){
      $('#blossum').hide();
      $('#wchelp').show();
      $('#bshelp').hide();
    } else {
      $('#blossum').hide();
      $('#wchelp').hide();
      $('#bshelp').hide();
    }
  });

  $('#wcicon').tooltip({
    content: function(callback){
      callback($(this).prop('title').replace(/\|/g, '<br />'));
    }
  });

  $('#bsicon').tooltip({
    content: function(callback){
      callback($(this).prop('title').replace(/\|/g, '<br />'));
    }
  });
  
  $('.editlink').click(function(e){
    e.preventDefault();
    var link = $(this).attr('href');
    $.get(link, function(response){
      $('#editusers').html(response);
    });
  });
/*
  $('#clusterlist').jstree({
    'plugins': ['html_data','ui','themes','crrm'],
    'themes': {'theme':'proton',
                'dots':true,
                'icons':false,
                'url': './themes/proton/style.css'
              } 

  });*/

  /* -----------jsTree configuration------------------- */
  $('#clusterlist').bind('loaded.jstree', function(){
    var opennode = document.location.pathname.split('/').pop();
    $('#' + opennode).parents('.jstree-closed').each(function(){
      $('#clusterlist').jstree('open_node', this, false, true);
    });
  });

  $('#clusterlist').bind('before.jstree', function(event,data){
    switch(data.plugin){
      case 'ui':
        if(!data.inst.is_leaf(data.args[0])){
          return false;
        }
        break;
      default:
        break;
    }
  }).jstree({'plugins' : ['html_data', 'ui', 'themes'],
    'themes': {'theme':'proton',
                'dots':true,
                'icons':false,
                'url': './themes/proton/style.css'
              } 
      })
    .delegate('a', 'click', function(event, data){
      var link = $(this).attr("href");
      if (link !== "#"){
        if($('#clusterlist_sel').is(':visible')){
          $('#clusterlist_sel').toggle();
        }
        if($('#clusterlist_pep').is(':visible')){
          $('#clusterlist_pep').html('');
        }
        var cluster = $(this).attr('href').split('/')[2];
        $.get(url+'/cluster-infos',{selCl:cluster}, function(data){
          $('#clusterlist_sel').html(data);
          $.getScript(url+'/script/initshowtable.js', function(){
            $('#clusterlist_sel').toggle();
          });
        });
        return false;
      } else {
        return false;
      }
    });

  $('#disp-res').bind('loaded.jstree', function(){
    var opennode = document.location.pathname.split('/').pop();
    $('#' + opennode).parents('.jstree-closed').each(function(){
      $('#disp-res').jstree('open_node', this, false, true);
    });
  });
  $('#disp-res').bind('before.jstree', function(event,data){
    switch(data.plugin){
      case 'ui':
        if(!data.inst.is_leaf(data.args[0])){
          return false;
        }
        break;
      default:
        break;
    }
  }).jstree( {'plugins' : ['html_data', 'ui', 'themes'],
    'themes': {'theme':'proton',
                'dots':true,
                'icons':false,
                'url': './themes/proton/style.css'
              }, 
              'item_leaf': false, }).delegate('a', 'click', function(event, data){
  });
  

});
