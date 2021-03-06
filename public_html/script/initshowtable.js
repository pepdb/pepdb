/* Formating function for row details */
function fnFormatDetails ( mTable, nTr ){
  'use strict';
  var aData = mTable.fnGetData( nTr );
  var sOut = '<table cellpadding ="5", cellspacing = "0", class = detailtab>';
  sOut += '<tr><td>target:</td><td>'+aData[2]+'</td></tr>';
  sOut += '<tr><td>receptor:</td><td>'+aData[3]+'</td></tr>';
  sOut += '<tr><td>source:</td><td>'+aData[4]+'</td></tr>';
  sOut += '</table>';

  return sOut;
}
$(document).ready(function(){
  'use strict';
  var url = $.baseDir();

  /* setup and function for datatables using server-side data, used with large tables (e.g. dataset-peptides browsing)  */
  var route = document.location.pathname;
  var datasetURL = /\/datasets.*/;
  var elem;
  if(route.match(datasetURL) !== null){
    elem = $('#refelem1').val();
  } else if (route == url+'/systemic-search'){
    var checkedDS = [];
    $('#ref-dataset input:checkbox').closest('fieldset').find(':checkbox').each(function(){
      var elemVal = $(this).attr('value');
      if(this.checked && elemVal != 'all_ds'){
        checkedDS.push(elemVal);
      }
    });
    elem = checkedDS;
  } else if (route == url+'/property-search'){
    elem = $('#qry_id').val();
  }
  var pTable = $('#pep_table').dataTable({
    'bProcessing': true,
    'bInfo': true,
    'bSearchable': true,
    'bPaginate': true,
    'aaSorting': [[1, 'asc']],
    'aoColumnDefs':[{'aTargets':[1,2,3],
                    'sClass': 'text-right'
      },
    ],
    'sDom': '<"H"lfrT>t<"F"ip>',
    'oTableTools':{
      'sSwfPath': url+'/copy_csv_xls_pdf.swf',
      'aButtons': [{
        'sExtends': 'collection',
        'sButtonText': 'save as',
        'aButtons': ['csv', 'pdf'],
      }]
    },
    'bServerSide': true,
    'sAjaxSource': url+'/datatables',
    'fnServerParams': function(aoData){
      aoData.push({ 'name': 'selElem', 'value': elem});
    }
  
  });
  $.addTableFunctions('#pep_table', pTable);

  // initialzie datatables table
  var aTable = $('#prop_table').dataTable({
    'bPaginate': 'true',
    'bInfo': true,
    'aaSorting': [[5, 'desc']],
    'aoColumnDefs': [
      {'iDataSort': 6 , 'aTargets':[3]},
      {'bVisible': false , 'aTargets':[6]},
    ],
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

  $.addTableFunctions('#prop_table', aTable);


/* initialize second table on data browsing pages with searchable columns*/
  var qTable = $('#show_table').dataTable({
    'bInfo': true,
    'bPaginate': true,
    'sDom': '<"H"lfrT>t<"F"ip>',
    'oTableTools':{
      'sSwfPath': url+'/copy_csv_xls_pdf.swf',
      'aButtons': [{
        'sExtends': 'collection',
        'sButtonText': 'save as',
        'aButtons': ['csv', 'pdf'],
      }]
    },
  });
  $.addTableFunctions('#show_table', qTable);

  var maxLen = $('#max_len').val();
  var sortCols = [ {'iDataSort':2, 'aTargets':[3]}, {'bVisible':false, 'aTargets':[2]} ];
  for(var domRow = 0; domRow<maxLen;domRow++){
    var realDomCol = 6 + domRow * 4;
    sortCols.push({'iDataSort':realDomCol, 'aTargets':[realDomCol+1]});
    sortCols.push({'bVisible':false, 'aTargets':[realDomCol]});
  }
  var peTable = $('#comppep_table').dataTable({
    'bInfo': true,
    'aaSorting':[[4,'desc'],[3, 'desc']],
    'aoColumnDefs':sortCols,
    'bPaginate': true,
    'sDom': '<"H"lfrT>t<"F"ip>',
    'oTableTools':{
      'sSwfPath': url+'/copy_csv_xls_pdf.swf',
      'aButtons': [{
        'sExtends': 'collection',
        'sButtonText': 'save as',
        'aButtons': ['csv', 'pdf'],
      }]
    },
  });
  $.addTableFunctions('#comppep_table', peTable);

  sortCols = [ {'iDataSort':1, 'aTargets':[2]}, {'bVisible':false, 'aTargets':[1]} ];
  for(var domRow = 0; domRow<maxLen;domRow++){
    var realDomCol = 7 + domRow * 6;
    sortCols.push({'iDataSort':realDomCol, 'aTargets':[realDomCol+1]});
    sortCols.push({'bVisible':false, 'aTargets':[realDomCol]});
  }
  var clTable = $('#compcl_table').dataTable({
    'bInfo': true,
    'aaSorting':[[3,'desc'],[2, 'desc']],
    'aoColumnDefs':sortCols,
    'bPaginate': true,
    'sDom': '<"H"lfrT>t<"F"ip>',
    'oTableTools':{
      'sSwfPath': url+'/copy_csv_xls_pdf.swf',
      'aButtons': [{
        'sExtends': 'collection',
        'sButtonText': 'save as',
        'aButtons': ['csv', 'pdf'],
      }]
    },
  });
  $.addTableFunctions('#compcl_table', clTable);

  /* setup for table with collapsible rows in motif list table  */
  var nCloneTh = document.createElement('th');
  var nCloneTd = document.createElement('td');
  var imgurl = url + '/images/details_open.png';
  nCloneTd.innerHTML = '<img src = '+imgurl+'>';
  nCloneTd.className  = 'center';

  $('#motinfos thead tr').each( function () {
    this.insertBefore( nCloneTh, this.childNodes[0] );
  });

  $('#motinfos tbody tr').each( function () {
    this.insertBefore(  nCloneTd.cloneNode( true ), this.childNodes[0] );
  });

  /* motif-search motif table with collapsible detail rows*/
  var mTable = $('#motinfos').dataTable({
    'bPaginate': 'true',
    'bInfo': true,
    'bAutoWidth': false,
    'aoColumns': [
      {'sWidth': '5%'},
      {'sWidth': '95%'},
    ],
    'aoColumnDefs': [
      {'bSortable': false, 'aTargets': [0]},
      {'bVisible': false, 'aTargets':[2]},
      {'bVisible': false, 'aTargets':[3]},
      {'bVisible': false, 'aTargets':[4]},
    ],
    'aaSorting': [[1, 'asc']]
  });

  $('#motinfos_length').find("select").addClass('form-control');
  $('#motinfos_length').children().addClass('control-label');

  
  $('#motinfos').on('click','tbody td img' ,function () {
    var nTr = $(this).parents('tr')[0];
    if ( mTable.fnIsOpen(nTr) ){
      /* This row is already open - close it */
      this.src = url+'/images/details_open.png';
      mTable.fnClose( nTr );
    }
    else {
      /* Open this row*/
      this.src =url+'/images/details_close.png';
      mTable.fnOpen( nTr, fnFormatDetails(mTable, nTr), 'details' );
    }
  });
});
