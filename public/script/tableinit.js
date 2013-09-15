pepdb.tableinit = pepdb.tableinit || {};

$(document).ready(function(){
/* --------------DataTables configuration----------------  */
  $('.display').dataTable({
    "bPaginate": false,
    "bInfo": false,
    "bRetrieve": true,
  })
    .columnFilter();
  
  $('.cldisplay').dataTable({
    "bPaginate": false,
    "bInfo": false,
    "bRetrieve": true,
  })
    .columnFilter();

  $('#select_table tr').hover(function(){
    $(this).toggleClass('highlight');
  });

  $('#select_table tr:has(td)').click(function(){
    var selected_id = $(this).find("td:first").html();
    var route = window.location.pathname;
    $('body').load(route + "/" + selected_id);
  });


  $('#show_table tr').hover(function(){
    $(this).toggleClass('highlight');
  });

  $('#show_table tr:has(td)').click(function(){
    var selectedID = $(this).find("td:first").html();
    var selectedDS = $(this).find("td:nth-child(2)").html();
    var route = window.location.pathname;
    var first_choice =  $('#select_table').data('first-choice');
    if(first_choice != null ){
      $('body').load(route + "/" + first_choice + "/" + selectedID);
    } else if (route == "/comp-search"){
      $('#infos').load('/peptide-infos', {selSeq: selectedID, selDS: selectedDS});
    } else if (route == "/cluster-search"){
      if($('#clsearch').is(':visible')){
        $('#clsearch').toggle();
      }
      $('#clprop').load('/cluster-infos', {selCl: selectedID}, function(){
        $.getScript('/script/tableinit.js', function(){
          $('#clsearch').toggle();
        });
        
      });
    } else {
      $('body').load(route + "/" + selectedID);
    }
  });






});
