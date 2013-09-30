pepdb.tableinit = pepdb.tableinit || {};
var asInitVals = new Array();

$(document).ready(function(){
  $.getScript('/script/initshowtable.js');
/* --------------DataTables configuration----------------  */
  /* initialize first table with searchable columns*/
  var oTable = $('#select_table').dataTable({
    "bPaginate": "true",
    "sPaginationType": "full_numbers",
    "bInfo": true,
    "bJQueryUI": true,
  });
  
 
  $('#select_table thead input').click( function(e){
    stopTableSorting(e);
  });

  $('#select_table thead input').keyup( function(e){
    stopTableSorting(e);
    oTable.fnFilter(this.value, $("#select_table thead input").index(this));
  });

  $('#select_table thead input').each( function (i) {
    asInitVals[i] = this.value;
  } );
  
  $('#select_table thead input').focus( function () {
    if ( this.className == "search_init" )
    {
      this.className = "text_filter";
      this.value = "";
    }
  } );
  
  $('#select_table thead input').blur( function (i) {
    if ( this.value == "" )
    {
      $(this).addClass("search_init");
      this.value = asInitVals[$("#select_table thead input").index(this)];
    }
  } );
  
  $('#select_table tr').hover(function(){
    $(this).toggleClass('highlight');
  });

  $('#select_table tr:has(td)').click(function(){
    var selectedID = $(this).find("td:first").html();
    var route = $('#reftype').val();
    var path = document.location.pathname;
    if (path == "/cluster-search"){
      if($('#clsearch').is(':visible')){
        $('#clsearch').toggle();
      }
      $('#clprop').load('/cluster-infos', {selCl: selectedID}, function(){
        $.getScript('/script/initshowtable.js', function(){
          $('#clsearch').toggle();
        });

      });
    } else {
    if ($('#selecteddata').is(':visible')){
      $('#selecteddata').hide();
      $('#datainfo').hide();
    }
    $.get('/info-tables', {infoElem:selectedID}, function(data){
      $('#selectedinfo').html(data);
    });
    $.get('/show_sn_table', {ele_name:selectedID, ref: route}, function(data){
      $('#selecteddata').html(data);
      $.getScript('/script/initshowtable.js', function(){
        $('#selecteddata').show();
      });
    });
    }
  });

});
