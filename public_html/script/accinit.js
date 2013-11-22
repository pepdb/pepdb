pepdb.accinit = pepdb.accinit || {};
var asInitVals = new Array();
// this file initializes the jquery accordions used within some search results (e.g. motif search)
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
  $('#motacc').accordion({ heightStyle: "content" },
                          {collapsible:true } );  
  $('#compacc').accordion({ heightStyle: "content" },
                          {collapsible:true } );  
  
// initialzie datatables table
  var oTable = $('.mot_table').dataTable({
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

  // stop table sorting when clicking on the filter-field  
  $('.mot_table thead input').click( function(e){
    stopTableSorting(e);
  });
    
  // the following lines are neccessary for the individual column filtering
  $('.mot_table thead input').keyup( function(e){
    stopTableSorting(e);
    oTable.fnFilter(this.value, $(".mot_table thead input").index(this));
  });
  $('.mot_table thead input').each( function (i) {
    asInitVals[i] = this.value;
  } );

  $('.mot_table thead input').focus( function () {
    if ( this.className == "search_init" )
    {
      this.className = "text_filter";
      this.value = "";
    }
  } );

  $('.mot_table thead input').blur( function (i) {
    if ( this.value == "" )
    {
      $(this).addClass("search_init");
      this.value = asInitVals[$(".mot_table thead input").index(this)];
    }
  } );

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
    alert("click");
  });


});

