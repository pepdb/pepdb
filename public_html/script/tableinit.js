pepdb.tableinit = pepdb.tableinit || {};

jQuery.baseDir =  function baseDir(){
  'use strict';
  var url = document.location.pathname.split('/')[1];
  if (url == 'pepdb'){
    return '/'+url;
  } else {
    return '';
  }
};

jQuery.stopTableSorting = function stopTableSorting(e) {
  'use strict';
  if (!e) {
    var e = window.event;
  }
  e.cancelBubble = true;
  if (e.stopPropagation){
    e.stopPropagation();
  }
};


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
      var selectedDS = $(this).find('td:nth-child(4)').html();
      if($('#clsearch').is(':visible')){
        $('#clsearch').toggle();
      }
      $.get(url+'/cluster-infos', {selCl:selectedID, selDS:selectedDS}, function(data){
        $('#clprop').html(data);
        $.getScript(url+'/script/initshowtable.js', function(){
          $('#clsearch').toggle();
        });
      });
    } else if (path == url+'/motif-search' ) {
        var selectedPep = $(this).find('td:first').html();
        var selectedDS = $(this).find('td:nth-child(3)').html();
        $.get(url +'/peptide-infos', {selDS: selectedDS, selSeq: selectedPep}, function(data){
          $('#motpepinfos').html(data);
        });
    // dealing with a server-side dataTable
    } else if (objID == '#pep_table'){
      var selectedDS = $(this).find('td:nth-child(5)').html();
      var dataType = $('#reftype').val();
      var firstChoice = $('#refelem1').val();
      if (path == url +'/systemic-search' || path == url+'/property-search'){
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

      $.get(url+'/peptide-infos', {selSeq: selectedID, selDS: selectedDS,ref:dataType, ele_name2: firstChoice}, function(data){
        $('#infos').html(data);
        $.getScript(url+'/script/initbutton.js', function(){
          $('#infos').show();
        });
      });
    } else if (objID === '#comppep_table'){
      var maxLen = $('#max_len').val();
      var firstDS = $(this).find('td:nth-child(2)').html();
      var refDS = [firstDS];
      for (var dsCount = 0; dsCount < maxLen; dsCount++){
        var cell = 5 + 3 * dsCount;
        var nextDS = $(this).find('td:nth-child('+cell+')').html();
        refDS.push(nextDS);
      }
      $.get(url+'/peptide-infos', {selSeq: selectedID, refDS: refDS}, function(data){
        $('#infos').html(data);
      });
    } else if (objID == '#show_table'){
      var selectedDS = $(this).find('td:nth-child(2)').html();
      var dataType = $('#reftype').val();
      var firstChoice = $('#refelem1').val();
      if (path.match(/clusters/) !== null ){
        $.get(url+'/show-info', {ele_name: selectedID, ref:'Clusters', ele_name2: firstChoice}, function(data){
          $('#clusterlist_pep').html(data);
        });
      } else if (path == url+'/cluster-search'){
        $.get(url+'/show-info', {ele_name: selectedID, ref:'Clustersearch', ele_name2: firstChoice}, function(data){
          $('#clusterlist_pep').html(data);
        });
      } else {
        $.get(url+'/show-info', {ele_name: selectedID, ref:dataType, ele_name2: firstChoice}, function(data){
          $('#datainfo').html(data);
          $.getScript(url+'/script/initbutton.js', function(){
            $('#datainfo').show();
          });
        });
      }
    } else if (objID === '#compcl_table'){
      var maxLen = $('#max_len').val();
      var selectedDS = [];
      var selectedSeq = [];
      selectedDS.push($('#comp-dataset input[type="radio"]:checked').val());
      selectedSeq.push($(this).find('td:first').html());
      for(var cluster = 0; cluster < maxLen; cluster++){
        var seqCell = 5 + cluster * 6;
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
        $('.clsearchpeps').show();
      });
    } else if (objID.match(/clpeptab/) !== null) {
        var selectedPep = $(this).find('td:first').html();
        var selectedDS = $(objID).data('ds');
        var idx = $(objID).data('idx');
        $.get(url +'/peptide-infos', {selDS: selectedDS, selSeq: selectedPep}, function(data){
          $('#clpepinfos'+idx).html(data);
        });
      
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
