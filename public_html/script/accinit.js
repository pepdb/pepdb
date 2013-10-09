pepdb.accinit = pepdb.accinit || {};
var asInitVals = new Array();

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
  
    var oTable = $('.mot_table').dataTable({
    "bPaginate": "true",
    "sPaginationType": "full_numbers",
    "bInfo": true,
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

  $('.mot_table thead input').click( function(e){
    stopTableSorting(e);
  });
    
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

});

