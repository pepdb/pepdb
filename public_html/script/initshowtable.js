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
});
