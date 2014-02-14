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
    'bJQueryUI': true,
    'bProcessing': true,
    'bInfo': true,
    'bSearchable': true,
    'sPaginationType': 'full_numbers',
    'bPaginate': true,
    'aaSorting': [[1, 'asc']],
    'aoColumnDefs':[{'aTargets':[1,2,3],
                    'sClass': 'alignRight'
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


/* initialize second table on data browsing pages with searchable columns*/
  var qTable = $('#show_table').dataTable({
    'bJQueryUI': true,
    //'sScrollX': '100%',
    'bInfo': true,
    'sPaginationType': 'full_numbers',
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
    'sPaginationType': 'full_numbers',
    'bInfo': true,
    'bAutoWidth': false,
    'aoColumns': [
      {'sWidth': '5%'},
      {'sWidth': '95%'},
    ],
    'bJQueryUI': true,
    'aoColumnDefs': [
      {'bSortable': false, 'aTargets': [0]},
      {'bVisible': false, 'aTargets':[2]},
      {'bVisible': false, 'aTargets':[3]},
      {'bVisible': false, 'aTargets':[4]},
    ],
    'aaSorting': [[1, 'asc']]
  });

  
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
