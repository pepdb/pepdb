$(document).ready(function(){
  var formAll = ["#all_lib", "#all_sel", "#all_ds" ];

  /* retrieve checkbox state from localStorage  */
  function checkCheckbox(storageName, itemID){
      if(localStorage[storageName]){
        var checkedItems = JSON.parse(localStorage[storageName]);
        var marked = false;
        checkedItems.forEach(function(element){
          if(element == itemID){
            marked = true;
            return false;
          }
        });
        return marked
      } 
  }
  
  /* save checkbox state to localStorage */
  function saveCheckbox(storageName, itemID, checkStatus){
    if(!localStorage[storageName]){
      var content = [];
      localStorage[storageName] = JSON.stringify(content);
    }
    var selectedItems = JSON.parse(localStorage[storageName]);
    if(checkStatus){
      selectedItems.push(itemID);
    } else {
      for (var elementCounter = 0; elementCounter < selectedItems.length; elementCounter = elementCounter +1){
        if(selectedItems[elementCounter] == itemID){
          selectedItems.splice(elementCounter, 1);
          break;
        }
      }
    }      
    localStorage[storageName] = JSON.stringify(selectedItems);
  } 


  $('#clear-button').click(function(){
    localStorage.clear();
    $('body').load(window.location.pathname);
  });
   
  $(':checkbox').each(function(){
    storage = $(this).attr("name").slice(0,-2);
    itemID = $(this).attr("id");
    $(this).prop('checked', checkCheckbox(storage, itemID));
  });
  
  /*(un)check all checkboxes on checking "all" */ 
  $.each(formAll, function(index, value){
    $(value).click(function(){
      var marked = this.checked;
      $(this).closest('fieldset').find(':checkbox').each(function(){
        storage = $(this).attr("name");
        saveCheckbox(storage.slice(0,-2), $(this).attr("id"), marked); 
        $(this).prop('checked', marked);
      });
    });  
  }); 
  
  $('#libform input:checkbox').click(function(){
    storage = $(this).attr("name");
    saveCheckbox(storage.slice(0,-2), $(this).attr("id"), this.checked); 

    if(storage == "checked_lib[]"){
      localStorage.removeItem("checked_sel"); 
      localStorage.removeItem("checked_ds");

    } else if (storage == "checked_sel[]"){
      localStorage.removeItem("checked_ds");
    }
    $('#libform').submit();
  });


  /* --------------DataTables configuration----------------  */
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
 

  /* -----------jsTree configuration------------------- */  
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
   } );


} );

