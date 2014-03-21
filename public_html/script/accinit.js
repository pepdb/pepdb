pepdb.accinit = pepdb.accinit || {};
var tables =  [];

// this file initializes the jquery accordions used within some search results (e.g. motif search)
$(document).ready(function(){
  'use strict';
  var url = $.baseDir();
  /*
  $('#compacc').accordion({ heightStyle: 'content' },
                          {collapsible:true });*/
  var noOfResults = $('#resamt').val();
// initialzie datatables table
  for(var count = 0; count < noOfResults; count++){
    var tabID = '#mot_table'+count;
    tables[count] = $(tabID).dataTable({
      'bPaginate': 'true',
      //'sPaginationType': 'full_numbers',
      'bInfo': true,
      'aaSorting': [[1, 'desc']],
      'aoColumnDefs': [
        {'iDataSort': 2 , 'aTargets':[1]},
        {'bVisible': false , 'aTargets':[2]},
      ],
     // 'sDom': '<"H"lfrT>t<"F"ip>',
      'oTableTools':{
        'sSwfPath': url+'/copy_csv_xls_pdf.swf',
        'aButtons': [
        {
          'sExtends': 'collection',
          'sButtonText': 'save as',
          'aButtons': ['csv', 'pdf'],
          }]
        }
      });
    $.addTableFunctions(tabID, tables[count]);
  }
  // init jquery accordion displaying the results 
  /*$('#motacc').accordion({ heightStyle: 'content' },
                          {collapsible:true },
     {activate: function(event, ui){
        tables[0].fnDraw();
      }}
   );*/

  // initialzie datatables table
    var pTable = $('.cl_table').dataTable({
    'bPaginate': 'true',
   // 'sPaginationType': 'full_numbers',
    'bInfo': true,
    'aaSorting': [[2, 'desc']],
    'aoColumnDefs': [
      {'iDataSort': 2 , 'aTargets':[1]},
      {'bVisible': false , 'aTargets':[2]},
    ],
   // 'bJQueryUI': true,
    'sDom': '<"H"lfrT>t<"F"ip>',
    'oTableTools':{
      'sSwfPath': url+'/copy_csv_xls_pdf.swf',
      'aButtons': [
      {
        'sExtends': 'collection',
        'sButtonText': 'save as',
        'aButtons': ['csv', 'pdf'],
        }]
      }
    });

  $.addTableFunctions('.cl_table', pTable);
});
