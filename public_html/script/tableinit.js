pepdb.tableinit = pepdb.tableinit || {};

jQuery.addTableFunctions = function addTableFunctions(objID, tabVar){
  'use strict';
  var asInitVals = [];
  var url = $.baseDir();
  $(objID + ' thead input').click( function(e){
    $.stopTableSorting(e);
  });

  $(objID +' thead input').keyup( function(e){
    $.stopTableSorting(e);
    tabVar.fnFilter(this.value, $(objID + ' thead input').index(this));
  });

  $(objID+' thead input').each( function (i) {
    asInitVals[i] = this.value;
  } );
  
  $(objID+' thead input').focus( function () {
    if ( this.className == 'search_init' )
    {
      this.className = 'text_filter';
      this.value = '';
    }
  } );
  
  $(objID+' thead input').blur( function (i) {
    if ( this.value === '' )
    {
      $(this).addClass('search_init');
      this.value = asInitVals[$(objID+' thead input').index(this)];
    }
  } );
  
  $(objID).on('mouseenter mouseleave', 'tr', function(){
    $(this).toggleClass('highlight');
  });

  $(objID).on('click', 'tr:has(td)', function(){
    var selectedID = $(this).find('td:first').html();
    var route = $('#reftype').val();
    var path = document.location.pathname;
    if (path == url+'/cluster-search' && objID == '#select_table'){
      if($('#clsearch').is(':visible')){
        $('#clsearch').toggle();
      }
      $.get(url+'/cluster-infos', {selCl:selectedID}, function(data){
        $('#clprop').html(data);
        $.getScript(url+'/script/initshowtable.js', function(){
          $('#clsearch').toggle();
        });
      });
    } else if (path == url+'/motif-search' ) {
      $(objID).on('click', 'tr:has(td)', function(){
        var selectedPep = $(this).find('td:first').html();
        var selectedDS = $(this).find('td:nth-child(3)').html();
        $.get(url +'/peptide-infos', {selDS: selectedDS, selSeq: selectedPep}, function(data){
          $('#motpepinfos').html(data);
        });
      });
    // dealing with a server-side dataTable
    } else if (objID == '#pep_table'){
      var selectedDS = $(this).find('td:nth-child(5)').html();
      var dataType = $('#reftype').val();
      var firstChoice = $('#refelem1').val();
      if (route == url +'/systemic-search' || route == url+'/property-search'){
        $.get(url+'/peptide-infos', {selSeq: selectedID, selDS: selectedDS}, function(data){
          $('#infos').html(data);
        });
      } else {
        $.get(url+'/show-info', {ele_name: selectedID, ref:dataType, ele_name2: firstChoice}, function(data){
          $('#datainfo').html(data);
          $.getScript(url+'/script/initbutton.js', function(){
            $('#datainfo').show();
          });
        });
      }
    } else if (objID == '.prop_table'){
      var selectedDS = $(this).find('td:nth-child(5)').html();
      var dataType = $('#reftype').val();
      var firstChoice = $('#refelem1').val();

      $.get(url+'/show-info', {ele_name: selectedID, ref:dataType, ele_name2: firstChoice}, function(data){
        $('#datainfo').html(data);
        $.getScript(url+'/script/initbutton.js', function(){
          $('#datainfo').show();
        });
      });
    } else if (objID == '#show_table'){
      var selectedDS = $(this).find('td:nth-child(2)').html();
      var dataType = $('#reftype').val();
      var firstChoice = $('#refelem1').val();
      if (route == url+'/comparative-search'){
        var refMx = $('#ref_dom_max').val();
        var refMn = $('#ref_dom_min').val();
        var dsMx = $('#ds_dom_max').val();
        var dsMn = $('#ds_dom_min').val();
        var refDS = [];
        var investDS = $('#comp-dataset input[type="radio"]:checked').val();
        $('#r_all_ds').closest('fieldset').find(':checkbox').each(function(){
          var elemVal = $(this).attr('value');
          if(this.checked && elemVal != 'all_ds'){
            refDS.push(elemVal);
          }
        });
        $.get(url+'/peptide-infos', {selSeq: selectedID, invDS: investDS, refDS: refDS, ref_dom_max: refMx, ref_dom_min: refMn, ds_dom_max: dsMx, ds_dom_min: dsMn}, function(data){
          $('#infos').html(data);
        });
      } else if (route.match(/clusters/) !== null || route == url+'/cluster-search'){
        $.get(url+'/show-info', {ele_name: selectedID, ref:'Clusters', ele_name2: firstChoice}, function(data){
          $('#clusterlist_pep').html(data);
        });
      } else if (route == url+'/comparative-cluster-search'){
        var maxLen = $('#max_len').val();
        var selectedDS = [];
        var selectedSeq = [];
        selectedDS.push($('#comp-dataset input[type="radio"]:checked').val());
        selectedSeq.push($(this).find('td:first').html());
        for(var cluster = 0; cluster < maxLen; cluster++){
          var seqCell = 4 + cluster * 5;
          var dsCell = seqCell+1;
          var seq = $(this).find('td:nth-child('+seqCell+')').html();
          var ds = $(this).find('td:nth-child('+dsCell+')').html();
          if (seq){
            selectedSeq.push(seq);
            selectedDS.push(ds);
          }
        }
        $.get(url+'/cluster-infos', {ele_name: selectedSeq, ele_name2: selectedDS}, function(data){
          $('#clusterinfos').html(data);
          $.getScript(url+'/script/initproptable.js', function(){
            $('#clusterinfos').show();
          });
        });
      } else {
        $.get(url+'/show-info', {ele_name: selectedID, ref:dataType, ele_name2: firstChoice}, function(data){
          $('#datainfo').html(data);
          $.getScript(url+'/script/initbutton.js', function(){
            $('#datainfo').show();
          });
        });
      }
    } else {
      if ($('#selecteddata').is(':visible')){
        $('#selecteddata').hide();
        $('#datainfo').hide();
      }
      $.get(url+'/info-tables', {infoElem:selectedID}, function(data){
        $('#selectedinfo').html(data);
      });
      $.get(url+'/show_sn_table', {ele_name:selectedID, ref: route}, function(data){
        $('#selecteddata').html(data);
        $.getScript(url+'/script/initshowtable.js', function(){
          $('#selecteddata').show();
        });
      });
    }
  });
};




$(document).ready(function(){
  'use strict';
  var url = $.baseDir();

  $.getScript(url+'/script/initshowtable.js');
/* --------------DataTables configuration----------------  */
  /* initialize first table with searchable columns*/
  var oTable = $('#select_table').dataTable({
    'bPaginate': 'true',
    'sPaginationType': 'full_numbers',
    'bInfo': true,
    'bJQueryUI': true,
  });
  
  $.addTableFunctions('#select_table', oTable);
});
