$(document).ready(function(){
  'use strict';
  var url = $.baseDir();

  // initialzie datatables table
  var aTable = $('.prop_table').dataTable({
    'bPaginate': 'true',
    'sPaginationType': 'full_numbers',
    'bInfo': true,
    'aaSorting': [[5, 'desc']],
    'aoColumnDefs': [
      {'iDataSort': 6 , 'aTargets':[3]},
      {'bVisible': false , 'aTargets':[6]},
    ],
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
});
