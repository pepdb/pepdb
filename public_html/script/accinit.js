pepdb.accinit = pepdb.accinit || {};
var asInitVals = new Array();
var tables =  new Array();
// this file initializes the jquery accordions used within some search results (e.g. motif search)
$(document).ready(function(){
  
  var url = $.baseDir();
  $('#compacc').accordion({ heightStyle: "content" },
                          {collapsible:true } );  
  
// initialzie datatables table
  oTable = $('.mot_table').dataTable({
    "bPaginate": "true",
    "sPaginationType": "full_numbers",
    "bInfo": true,
    "aaSorting": [[1, "desc"]],
    "aoColumnDefs": [
      {"iDataSort": 1 , "aTargets":[2]},
      {"bVisible": false , "aTargets":[2]},
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
  $.addTableFunctions(".mot_table", oTable);

  /* init jquery accordion displaying the results */
  $('#motacc').accordion({ heightStyle: "content" },
                          {collapsible:true },
     {activate: function(event, ui){
        oTable.fnDraw();
      }}   
   );  


  // initialzie datatables table
    var pTable = $('.cl_table').dataTable({
    "bPaginate": "true",
    "sPaginationType": "full_numbers",
    "bInfo": true,
    "aaSorting": [[2, "desc"]],
    "aoColumnDefs": [
      {"iDataSort": 2 , "aTargets":[1]},
      {"bVisible": false , "aTargets":[2]},
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

  $.addTableFunctions(".cl_table", pTable);
/*
  // stop table sorting when clicking on the filter-field  
  $('.cl_table thead input').click( function(e){
    stopTableSorting(e);
  });
    
  // the following lines are neccessary for the individual column filtering
  $('.cl_table thead input').keyup( function(e){
    stopTableSorting(e);
    oTable.fnFilter(this.value, $(".cl_table thead input").index(this));
  });
  $('.cl_table thead input').each( function (i) {
    asInitVals[i] = this.value;
  } );

  $('.cl_table thead input').focus( function () {
    if ( this.className == "search_init" )
    {
      this.className = "text_filter";
      this.value = "";
    }
  });
  $('.cl_table').on('mouseenter mouseleave', 'tr', function(){
    $(this).toggleClass('highlight');
  });
  $('.cl_table').on('click', 'tr:has(td)', function(){
    //alert("click");
  });
*/

});

