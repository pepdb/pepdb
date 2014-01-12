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
    "aaSorting": [[1, "asc"]],
    "aoColumnDefs":[{"aTargets":[1,2,3],
                    "sClass": "alignRight"
    },
],
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
    var selectedDS = $(this).find("td:nth-child(5)").html();
    var route = document.location.pathname;
    var dataType = $('#reftype').val();
    var firstChoice = $('#refelem1').val();
    if (route == url +"/systemic-search" || route == url+"/property-search"){
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
  });

  // initialzie datatables table
  var aTable = $('.prop_table').dataTable({
    "bPaginate": "true",
    "sPaginationType": "full_numbers",
    "bInfo": true,
    "aaSorting": [[5, "desc"]],
    "aoColumnDefs": [
      {"iDataSort": 6 , "aTargets":[3]},
      {"bVisible": false , "aTargets":[6]},
    ],
    "bJQueryUI": true,
    "sDom": '<"H"lfrT>t<"F"ip>',
    "oTableTools":{
      "sSwfPath": url+"/copy_csv_xls_pdf.swf",
      "aButtons": [
      {
        "sExtends": "collection",
        "sButtonText": "save as",
        "aButtons": ["csv", "pdf"],
        }]
      }
    });

  // stop table sorting when clicking on the filter-field  
  $('.prop_table thead input').click( function(e){
    stopTableSorting(e);
  });

  // the following lines are neccessary for the individual column filtering
  $('.prop_table thead input').keyup( function(e){
    stopTableSorting(e);
    aTable.fnFilter(this.value, $(".prop_table thead input").index(this));
  });
  $('.prop_table thead input').each( function (i) {
    asInitVals[i] = this.value;
  } );

  $('.prop_table thead input').focus( function () {
    if ( this.className == "search_init" )
    {
      this.className = "text_filter";
      this.value = "";
    }
  } );

  $('.prop_table thead input').blur( function (i) {
    if ( this.value == "" )
    {
      $(this).addClass("search_init");
      this.value = asInitVals[$(".prop_table thead input").index(this)];
    }
  } );

  $('.prop_table').on('mouseenter mouseleave', 'tr', function(){
    $(this).toggleClass('highlight');
  });

  $('.prop_table').on('click', 'tr:has(td)', function(){
    var selectedID = $(this).find("td:first").html();
    var selectedDS = $(this).find("td:nth-child(5)").html();
    var route = document.location.pathname;
    var dataType = $('#reftype').val();
    var firstChoice = $('#refelem1').val();
    
    $.get(url+'/show-info', {ele_name: selectedID, ref:dataType, ele_name2: firstChoice}, function(data){
      $('#datainfo').html(data);
      $.getScript(url+'/script/initbutton.js', function(){
        $('#datainfo').show();
      });
    });
  });



/* initialize second table on data browsing pages with searchable columns*/
  var qTable = $('#show_table').dataTable({
    "bJQueryUI": true,
    "sScrollX": "100%",
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

  $('#show_table').on('mouseenter mouseleave', 'tr' ,function(){
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
    stopTableSorting(e);
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
  $('#show_table').on('click', 'tr:has(td)', function(){
    var selectedID = $(this).find("td:first").html();
    var selectedDS = $(this).find("td:nth-child(2)").html();
    var route = document.location.pathname;
    var dataType = $('#reftype').val();
    var firstChoice = $('#refelem1').val();
    if (route == url+"/comparative-search"){
      var refMx = $('#ref_dom_max').val();
      var refMn = $('#ref_dom_min').val();
      var dsMx = $('#ds_dom_max').val();
      var dsMn = $('#ds_dom_min').val();
      var refDS = [];
      var investDS = $("#comp-dataset input[type='radio']:checked").val();
      $('#r_all_ds').closest('fieldset').find(':checkbox').each(function(){
        var elemVal = $(this).attr('value');
        if(this.checked && elemVal != "all_ds"){
          refDS.push(elemVal);
        }
      });
      $.get(url+'/peptide-infos', {selSeq: selectedID, invDS: investDS, refDS: refDS, ref_dom_max: refMx, ref_dom_min: refMn, ds_dom_max: dsMx, ds_dom_min: dsMn}, function(data){
        $('#infos').html(data);
      });
    /*if (route == url+"/comparative-search"){
      var checkedDS = [];
      $('#r_all_ds').closest('fieldset').find(':checkbox').each(function(){
        var elemVal = $(this).attr('value');
        if(this.checked && elemVal != "all_ds"){
          checkedDS.push(elemVal);
        }
      });
      var radioDS = $("#comp-dataset input[type='radio']:checked").val();
      var radioType = $("#comp-buttons input[type='radio']:checked").val();
      checkedDS.push(radioDS);
      $.get(url+'/show-info', {comptype: radioType, selRow:checkedDS, ele_name: selectedID, ref:dataType, ele_name2: selectedDS}, function(data){
        $('#compinfos').html(data);
      });*/
    } else if (route.match(/clusters/) != null || route == url+"/cluster-search"){
      $.get(url+'/show-info', {ele_name: selectedID, ref:"Clusters", ele_name2: firstChoice}, function(data){
        $('#clusterlist_pep').html(data);
      });
    } else if (route == url+"/comparative-cluster-search"){
      var maxLen = $('#max_len').val();
      var selectedDS = [];
      var selectedSeq = [];
      selectedDS.push($("#comp-dataset input[type='radio']:checked").val());
      selectedSeq.push($(this).find("td:first").html());
      for(var cluster = 0; cluster < maxLen; cluster++){
        var seqCell = 4 + cluster * 5;
        var dsCell = seqCell+1;
        var seq = $(this).find("td:nth-child("+seqCell+")").html();
        var ds = $(this).find("td:nth-child("+dsCell+")").html();
        if (seq){
          selectedSeq.push(seq);
          selectedDS.push(ds);
        }
      }      
      $.get(url+"/cluster-infos", {ele_name: selectedSeq, ele_name2: selectedDS}, function(data){
        $('#clusterinfos').html(data);
      }); 
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
