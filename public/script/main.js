$(document).ready(function(){
  $('#select_table').dataTable({
    "bPaginate": false,
    "bInfo": false,
  })
    .columnFilter();
} );

/*
$(document).ready(function(){
  $('#select_table tr').hover(function(){
    $(this).toggleClass('highlight');
  });

  $('#show_table tr').hover(function(){
    $(this).toggleClass('highlight');
  });

  $('#select_table tr:has(td)').click(function(){
    var selected_id = $(this).find("td:first").html();
    var route = window.location.pathname;
    $('body').load(route + "/" + selected_id); 
  });

  $('#show_table tr:has(td)').click(function(){
    var first_choice =  $('#select_table').data('first-choice');
    var selected_id = $(this).find("td:first").html();
    var route = window.location.pathname;
    $('body').load(route+ "/" + first_choice + "/" + selected_id); 
  });
  
});
*/
