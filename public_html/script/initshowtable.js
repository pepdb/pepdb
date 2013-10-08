/* Formating function for row details */
function fnFormatDetails ( mTable, nTr )
{
    var aData = mTable.fnGetData( nTr );
    var sOut = '<table cellpadding ="5", cellspacing = "0", class = detailtab>';
    sOut += '<tr><td>target:</td><td>'+aData[2]+'</td></tr>';
    sOut += '<tr><td>receptor:</td><td>'+aData[3]+'</td></tr>';
    sOut += '<tr><td>source:</td><td>'+aData[4]+'</td></tr>';
    sOut += '</table>';

    return sOut;
}
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

  /* setup and function for datatables using server-side data, used with large tables (e.g. dataset-peptides browsing)  */
  var route = document.location.pathname;
  var datasetURL = /\/datasets.*/;
  if(route.match(datasetURL) != null){ 
    var elem = $('#refelem1').val();
  } else if (route == url+'/systemic-search'){
    var checkedDS = [];
    $('#ref-dataset input:checkbox').closest('fieldset').find(':checkbox').each(function(){
      var elemVal = $(this).attr('value');
      if(this.checked && elemVal != "all_ds"){
        checkedDS.push(elemVal);
      }
    });
    var elem = checkedDS;
  } else if (route == url+'/property-search'){
    var elem = $('#qry_id').val();
  }
  var pTable = $('#pep_table').dataTable({
    "bJQueryUI": true,
    "bProcessing": true,
    "bInfo": true,
    "bSearchable": true,
    "sPaginationType": "full_numbers",
    "bPaginate": true,
    "sDom": '<"H"lfrT>t<"F"ip>',
    "oTableTools":{
      "sSwfPath": url+"/copy_csv_xls_pdf.swf",
      "aButtons": [
      {
        "sExtends": "collection",
        "sButtonText": "save as",
        "aButtons": ["csv", "pdf"],
        }]
    },
    "bServerSide": true,
    "sAjaxSource": url+"/datatables",
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

  $('#pep_table').on('mouseenter mouseleave', 'tr', function(){
    $(this).toggleClass('highlight');
  });

  $('#pep_table').on('click', 'tr:has(td)', function(){
    var selectedID = $(this).find("td:first").html();
    var selectedDS = $(this).find("td:nth-child(2)").html();
    var route = document.location.pathname;
    var dataType = $('#reftype').val();
    var firstChoice = $('#refelem1').val();
    if (route == url+"/comparative-search" || route == url +"/systemic-search" || route == url+"/property-search"){
      $('#infos').load(url+'/peptide-infos', {selSeq: selectedID, selDS: selectedDS});
    } else if (route == url+"/cluster-search"){
    /*  if($('#clsearch').is(':visible')){
        $('#clsearch').toggle();
      }
      $('#pepprop').load('/peptide-infos', {selCl: selectedID}, function(){
        $.getScript('/script/initshowtable.js', function(){
          $('#clsearch').toggle();
        });
        
      });*/
    } else {
      $.get(url+'/show-info', {ele_name: selectedID, ref:dataType, ele_name2: firstChoice}, function(data){
        $('#datainfo').html(data);
        $.getScript(url+'/script/initbutton.js', function(){
          $('#datainfo').show();
        });
      });
    }     
  });


/* initialize second table on data browsing pages with searchable columns*/
  var qTable = $('#show_table').dataTable({
    "bJQueryUI": true,
    "bInfo": true,
    "sPaginationType": "full_numbers",
    "bPaginate": true,
    "sDom": '<"H"lfrT>t<"F"ip>',
    "oTableTools":{
      "sSwfPath": url+"/copy_csv_xls_pdf.swf",
      "aButtons": [
      {
        "sExtends": "collection",
        "sButtonText": "save as",
        "aButtons": ["csv", "pdf"],
        }]
    },
  });
  var route = document.location.pathname;

  $('#show_table tr').hover(function(){
    $(this).toggleClass('highlight');
  });

  $('#show_table thead input').blur( function (i) {
    if ( this.value == "" )
    {
      $(this).addClass("search_init");
      this.value = asInitVals[$("#show_table thead input").index(this)];
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
  });
  $('#show_table tr:has(td)').click(function(){
    var selectedID = $(this).find("td:first").html();
    var selectedDS = $(this).find("td:nth-child(2)").html();
    var route = document.location.pathname;
    var dataType = $('#reftype').val();
    var firstChoice = $('#refelem1').val();
   // var first_choice =  $('#select_table').data('first-choice');
    if (route == url+"/comparative-search" || route == url+"/systemic-search"){
      $('#infos').load(url+'/peptide-infos', {selSeq: selectedID, selDS: selectedDS});
    } else if (route == url+"/cluster-search"){
    /*  if($('#clsearch').is(':visible')){
        $('#clsearch').toggle();
      }
      $('#pepprop').load('/peptide-infos', {selCl: selectedID}, function(){
        $.getScript('/script/initshowtable.js', function(){
          $('#clsearch').toggle();
        });
        
      });*/
    } else {
      $.get(url+'/show-info', {ele_name: selectedID, ref:dataType, ele_name2: firstChoice}, function(data){
        $('#datainfo').html(data);
        $.getScript(url+'/script/initbutton.js', function(){
          $('#datainfo').show();
        });
      });
    }     
  });

  /* setup for table with collapsible rows in motif list table  */
  var nCloneTh = document.createElement('th');
  var nCloneTd = document.createElement('td');
  var imgurl = url + '/images/details_open.png';
  nCloneTd.innerHTML = '<img src = '+imgurl+'>';
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
    "bAutoWidth": false,
    "aoColumns": [
      {"sWidth": "5%"},
      {"sWidth": "95%"},
    ],
    "bJQueryUI": true,
    "aoColumnDefs": [
      {"bSortable": false, "aTargets": [0]},
      {"bVisible": false, "aTargets":[2]},
      {"bVisible": false, "aTargets":[3]},
      {"bVisible": false, "aTargets":[4]},
    ],
      "aaSorting": [[1, 'asc']]
  });

  
  //$('#motinfos tbody td img').on('click','#motinfos tbody td img' ,function () {
  $('#motinfos').on('click','tbody td img' ,function () {
    var nTr = $(this).parents('tr')[0];
    if ( mTable.fnIsOpen(nTr) )
    {
      /* This row is already open - close it */
      this.src = url+'/images/details_open.png';
      mTable.fnClose( nTr );
    }
    else
    {
      /* Open this row*/ 
      this.src =url+'/images/details_close.png';
      mTable.fnOpen( nTr, fnFormatDetails(mTable, nTr), 'details' );
    }
    } );

});
