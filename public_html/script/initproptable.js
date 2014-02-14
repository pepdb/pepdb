$(document).ready(function(){
  'use strict';
  var tables = [];
  var url = $.baseDir();
  // initialzie datatables table
  var aTable = $('.prop_table').dataTable({
    'bPaginate': 'true',
    'sPaginationType': 'full_numbers',
    'bInfo': true,
    'bJQueryUI': true,
    'sDom': '<"H"lfrT>t<"F"ip>',
    'oTableTools':{
      'sSwfPath': url+'/copy_csv_xls_pdf.swf',
      'aButtons': [{
        'sExtends': 'collection',
        'sButtonText': 'save as',
        'aButtons': ['csv', 'pdf'],
      }]
    } 
  });
  $.addTableFunctions('.prop_table', aTable);

  var noOfTabs = $('#clamt').val();
  for (var count = 0; count < noOfTabs; count++){
    var tabID = '#clpeptab'+count;
    tables[count] = $(tabID).dataTable({
      'bPaginate': 'true',
      'sPaginationType': 'full_numbers',
      'bInfo': true,
      'bJQueryUI': true,
      'sDom': '<"H"lfrT>t<"F"ip>',
      'oTableTools':{
        'sSwfPath': url+'/copy_csv_xls_pdf.swf',
        'aButtons': [{
          'sExtends': 'collection',
          'sButtonText': 'save as',
          'aButtons': ['csv', 'pdf'],
        }]
      } 
    });
    $.addTableFunctions(tabID, tables[count]);

  }


});
