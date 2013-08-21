$(document).ready(function(){
  $('#select_table tr').hover(function(){
    $(this).toggleClass('highlight');
  });

  $('#select_table tr:has(td)').click(function(){
    var selected_id = $(this).find("td:first").html();
    var route = window.location.pathname;
    $('body').load(route + "/" + selected_id); 
  });
  
});
