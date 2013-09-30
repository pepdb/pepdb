/* Formating function for row details */
function fnFormatDetails ( mTable, nTr )
{
    var aData = mTable.fnGetData( nTr );
    var sOut = '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">';
    sOut += '<tr><td>target:</td><td>'+aData[1]+' '+aData[4]+'</td></tr>';
    sOut += '<tr><td>receptor:</td><td>Could provide a link here</td></tr>';
    sOut += '<tr><td>source:</td><td>And any further details here (images etc)</td></tr>';
    sOut += '</table>';

    return sOut;
}
$(document).ready(function(){
/* initialize second table with searchable columns*/
  var qTable = $('#show_table').dataTable({
    "bJQueryUI": true,
    "bInfo": true,
    "sPaginationType": "full_numbers",
    "bPaginate": true,
    "sDom": '<"H"lfrT>t<"F"ip>',
    "oTableTools":{
      "sSwfPath": "/copy_csv_xls_pdf.swf",
      "aButtons": [
      {
        "sExtends": "collection",
        "sButtonText": "save as",
        "aButtons": ["csv", "pdf"],
        }]
    },
  });
  var elem = $('#refelem1').val();
  var route = document.location.pathname;

  var pTable = $('#pep_table').dataTable({
    "bJQueryUI": true,
    "bProcessing": true,
    "bInfo": true,
    "bSearchable": true,
    "sPaginationType": "full_numbers",
    "bPaginate": true,
    "sDom": '<"H"lfrT>t<"F"ip>',
    "oTableTools":{
      "sSwfPath": "/copy_csv_xls_pdf.swf",
      "aButtons": [
      {
        "sExtends": "collection",
        "sButtonText": "save as",
        "aButtons": ["csv", "pdf"],
        }]
    },
    "bServerSide": true,
    "sAjaxSource": "/datatables",
    "fnServerParams": function(aoData){
      aoData.push({ "name": "selElem", "value": elem});
    }
  
  });

  $('#pep_table thead input').click( function(e){
    stopTableSorting(e);
  });

  $('#pep_table thead input').keyup( function(){
    pTable.fnFilter(this.value, $("#pep_table thead input").index(this));
  });

  $('#pep_table thead input').each( function (i) {
    asInitVals[i] = this.value;
  } );

  $('#pep_table thead input').focus( function () {
    if ( this.className == "search_init" )
    {
      this.className = "text_filter";
      this.value = "";
    }
  } );

  $('#pep_table thead input').blur( function (i) {
    if ( this.value == "" )
    {
      $(this).addClass("search_init");
      this.value = asInitVals[$("#pep_table thead input").index(this)];
    }
  });

  $('#show_table thead input').click( function(e){
    stopTableSorting(e);
  });
  $('#show_table thead input').keyup( function(){
    qTable.fnFilter(this.value, $("#show_table thead input").index(this));
  });

  $('#show_table thead input').each( function (i) {
    asInitVals[i] = this.value;
  } );

  $('#show_table thead input').focus( function () {
    if ( this.className == "search_init" )
    {
      this.className = "text_filter";
      this.value = "";
    }
  } );

  $('#show_table thead input').blur( function (i) {
    if ( this.value == "" )
    {
      $(this).addClass("search_init");
      this.value = asInitVals[$("#show_table thead input").index(this)];
    }
  });

  
  $('#pep_table tr').hover(function(){
    $(this).toggleClass('highlight');
  });

  $('#show_table tr').hover(function(){
    $(this).toggleClass('highlight');
  });
  $('#pep_table tr:has(td)').click(function(){
    var selectedID = $(this).find("td:first").html();
    var selectedDS = $(this).find("td:nth-child(2)").html();
    var route = document.location.pathname;
    var dataType = $('#reftype').val();
    var firstChoice = $('#refelem1').val();
   // var first_choice =  $('#select_table').data('first-choice');
    if (route == "/comparative-search" || route == "/systemic-search"){
      $('#infos').load('/peptide-infos', {selSeq: selectedID, selDS: selectedDS});
    } else if (route == "/cluster-search"){
    /*  if($('#clsearch').is(':visible')){
        $('#clsearch').toggle();
      }
      $('#pepprop').load('/peptide-infos', {selCl: selectedID}, function(){
        $.getScript('/script/initshowtable.js', function(){
          $('#clsearch').toggle();
        });
        
      });*/
    } else {
      $.get('/show-info', {ele_name: selectedID, ref:dataType, ele_name2: firstChoice}, function(data){
        $('#datainfo').html(data);
        $.getScript('/script/initbutton.js', function(){
          $('#datainfo').show();
        });
      });
    }     
  });

  $('#show_table tr:has(td)').click(function(){
    var selectedID = $(this).find("td:first").html();
    var selectedDS = $(this).find("td:nth-child(2)").html();
    var route = document.location.pathname;
    var dataType = $('#reftype').val();
    var firstChoice = $('#refelem1').val();
   // var first_choice =  $('#select_table').data('first-choice');
    if (route == "/comparative-search" || route == "/systemic-search"){
      $('#infos').load('/peptide-infos', {selSeq: selectedID, selDS: selectedDS});
    } else if (route == "/cluster-search"){
    /*  if($('#clsearch').is(':visible')){
        $('#clsearch').toggle();
      }
      $('#pepprop').load('/peptide-infos', {selCl: selectedID}, function(){
        $.getScript('/script/initshowtable.js', function(){
          $('#clsearch').toggle();
        });
        
      });*/
    } else {
      $.get('/show-info', {ele_name: selectedID, ref:dataType, ele_name2: firstChoice}, function(data){
        $('#datainfo').html(data);
        $.getScript('/script/initbutton.js', function(){
          $('#datainfo').show();
        });
      });
    }     
  });

  var nCloneTh = document.createElement('th');
  var nCloneTd = document.createElement('td');
  nCloneTd.innerHTML = '<img src = "/images/details_open.png">';
  nCloneTd.className  = "center";

  $('#motinfos thead tr').each( function () {
        this.insertBefore( nCloneTh, this.childNodes[0] );
    } );

  $('#motinfos tbody tr').each( function () {
      this.insertBefore(  nCloneTd.cloneNode( true ), this.childNodes[0] );
  } );

  /* motif-search motif table with collapsible detail rows*/
  var mTable = $('#motinfos').dataTable({
    "bPaginate": "true",
    "sPaginationType": "full_numbers",
    "bInfo": true,
    "bJQueryUI": true,
    "aoColumnDefs": [
      {"bSortable": false, "aTargets": [0]}
    ],
      "aaSorting": [[1, 'asc']]
  });

  $('#motinfos tbody td img').on('click', function () {
    var nTr = $(this).parents('tr')[0];
    if ( mTable.fnIsOpen(nTr) )
    {
      /* This row is already open - close it */
      this.src = "/images/details_open.png";
      mTable.fnClose( nTr );
    }
    else
    {
      /* Open this row*/ 
      this.src = "/images/details_close.png";
      mTable.fnOpen( nTr, fnFormatDetails(mTable, nTr), 'details' );
    }
    } );

});
