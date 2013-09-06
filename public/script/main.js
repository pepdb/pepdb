$(document).ready(function(){
  var formAll = ["#all_lib", "#all_sel", "#all_ds" ];
  
  $('#clear-button').click(function(){
    localStorage.clear();
    $('body').load(window.location.pathname);
    //$('#libform').submit();
  });
   
  $(':checkbox').each(function(){
    var yolo2 = localStorage[$(this).attr("id")];
    if (yolo2 == "true"){
      $(this).attr('checked', true);
    } else {
      $(this).attr('checked', false);
    }
  });
 
  $.each(formAll, function(index, value){
    $(value).click(function(){
      var marked = this.checked;
      $(this).closest('fieldset').find(':checkbox').each(function(){
        localStorage[$(this).attr("id")] = marked;
        //$.cookie($(this).attr("id"), marked); 
        $(this).prop('checked', marked);
      });
    });  
  }); 
  
  $('#libform input:checkbox').click(function(){
    if($(this).attr("name") == "checked_lib[]"){
      if(!localStorage["libs"]){
        var content = [];
        localStorage["libs"] = JSON.stringify(content);
      }
      var selectedLibs = JSON.parse(localStorage["libs"]);
        
      localStorage["sels"] = null; 
      localStorage["datasets"] = null; 
    } else if ($(this).attr("name") == "checked_sel[]"){
      localStorage["datasets"] = null; 
    } else if ($(this).attr("name") == "checked_sel[]"){
    } else {
    }
    localStorage[$(this).attr("id")] = this.checked;
    $('#libform').submit();
  });



  $('#select_table').dataTable({
    "bPaginate": false,
    "bInfo": false,
  })
    .columnFilter();
  
  $('#show_table').dataTable({
    "bPaginate": false,
    "bInfo": false,
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
    var selected_id = $(this).find("td:first").html();
    var route = window.location.pathname;
    var first_choice =  $('#select_table').data('first-choice');
    if(first_choice != null ){
      $('body').load(route + "/" + first_choice + "/" + selected_id); 
    } else {
      $('body').load(route + "/" + selected_id);
    }
  });
 
  $('#clusterlist').bind("loaded.jstree", function(){
   var opennode = document.location.pathname.split("/").pop(); 
   $('#' + opennode).parents(".jstree-closed").each(function(){
      $('#clusterlist').jstree("open_node", this, false, true);
    }); 
  });  
 
  $('#clusterlist').bind('before.jstree', function(event,data){
    switch(data.plugin){
      case 'ui':
        if(!data.inst.is_leaf(data.args[0])){
          return false;
        }
        break;
      default:
        break;
    }
  }) 
    .jstree( {"plugins" : ["themes", "html_data"] })
    .delegate("a", "click", function(event, data){
     // event.preventDefault();
     // var select = data.rslt.obj.attr("id"); 
     // $('body').load(select);
     // alert(select);

   } );


/*
   .bind("select_node.jstree", function(event, data){
    var leafpath = data.rslt.obj.attr('id');
    document.location = "/clusters/" + leafpath;
  });
*/
} );

